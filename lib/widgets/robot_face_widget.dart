import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../services/robot_voice_service.dart';
import 'alive_face.dart';
import 'classic_face.dart';
import 'haze_face.dart';
import 'looi_face.dart';
import 'minimal_face.dart';
import 'bean_face.dart';

class RobotFaceWidget extends StatefulWidget {
  const RobotFaceWidget({super.key});

  @override
  State<RobotFaceWidget> createState() => _RobotFaceWidgetState();
}

class _RobotFaceWidgetState extends State<RobotFaceWidget> {
  StreamSubscription<AccelerometerEvent>? _motion;
  final Set<int> _pointers = {};
  bool _twoFingerTriggered = false;

  @override
  void initState() {
    super.initState();
    final isFlutterTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    if (isFlutterTest ||
        kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    _motion =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen((event) {
          // Gravity contributes ~9.8 m/s². A magnitude well above that is a
          // deliberate shake, with the cubit handling debounce and animation.
          final magnitude = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          if (magnitude > 20 && mounted) {
            context.read<RobotFaceCubit>().onShake();
          }
        });
  }

  @override
  void dispose() {
    _motion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final isV2 = state.config.faceType == FaceType.hazeV2;
        final isV3 = state.config.faceType == FaceType.hazeV3;
        // V3 is a full "screen face" — let it take most of the display, the
        // way mall companion robots do.
        final media = MediaQuery.sizeOf(context);
        return LayoutBuilder(
          builder: (context, constraints) {
            // Size against whatever box we're given (main screen body, game
            // screen slot, ...) instead of assuming the whole display.
            final maxW = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : media.width;
            final maxH = constraints.hasBoundedHeight
                ? constraints.maxHeight
                : media.height;
            final width = isV3
                ? math.min(maxW * 0.94, 540.0)
                : math.min(isV2 ? 360.0 : 300.0, maxW);
            final height = isV3
                ? math.min(maxH * 0.8, 640.0)
                : math.min(isV2 ? 440.0 : 400.0, maxH);
            final cubit = context.read<RobotFaceCubit>();

            // Convert a touch position into a normalized look direction so
            // the eyes can track the user's finger.
            void lookAt(Offset local) {
              cubit.setLookTarget(
                Offset(
                  ((local.dx / width) - 0.5) * 2.4,
                  ((local.dy / height) - 0.5) * 2.2,
                ),
              );
            }

            return Listener(
              onPointerDown: (event) {
                _pointers.add(event.pointer);
                if (_pointers.length >= 2 && !_twoFingerTriggered) {
                  _twoFingerTriggered = true;
                  HapticFeedback.heavyImpact();
                  cubit.onShake();
                }
              },
              onPointerUp: (event) {
                _pointers.remove(event.pointer);
                if (_pointers.isEmpty) _twoFingerTriggered = false;
              },
              onPointerCancel: (event) {
                _pointers.remove(event.pointer);
                if (_pointers.isEmpty) _twoFingerTriggered = false;
              },
              child: GestureDetector(
                // The face itself paints on a bare CustomPaint, which isn't
                // hit-testable — without this, taps on V2/V3 never land.
                behavior: HitTestBehavior.opaque,
                onTap: cubit.onTap,
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  cubit.cuddle();
                },
                onPanStart: (details) => lookAt(details.localPosition),
                onPanUpdate: (details) => lookAt(details.localPosition),
                onPanEnd: (_) => cubit.setLookTarget(null),
                onPanCancel: () => cubit.setLookTarget(null),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  scale: state.isPressed ? 1.05 : 1.0,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: (isV2 || isV3)
                        ? null
                        : BoxDecoration(
                            color: state.config.isDarkTheme
                                ? Colors.grey[900]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              if (state.isPressed)
                                BoxShadow(
                                  color: state.config.eyeColor.withValues(
                                    alpha: 0.16,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              BoxShadow(
                                color: state.config.isDarkTheme
                                    ? Colors.black.withValues(alpha: 0.5)
                                    : Colors.grey.withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                    child: _buildFaceType(state.config.faceType, state, cubit),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaceType(
    FaceType faceType,
    RobotFaceState state,
    RobotFaceCubit cubit,
  ) {
    switch (faceType) {
      case FaceType.classic:
        return ClassicFace(state: state);
      case FaceType.looi:
        return LooiFace(state: state);
      case FaceType.minimal:
        return MinimalFace(state: state);
      case FaceType.bean:
        return BeanFace(state: state);
      case FaceType.hazeV2:
        return AliveFace(
          state: state,
          voiceLevel: state.isSpeaking || state.mimicStatus != MimicStatus.idle
              ? cubit.voice.level
              : null,
        );
      case FaceType.hazeV3:
        return HazeFace(
          state: state,
          voiceLevel: state.isSpeaking || state.mimicStatus != MimicStatus.idle
              ? cubit.voice.level
              : null,
        );
    }
  }
}
