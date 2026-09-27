import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../cubits/robot_face_cubit.dart';
import '../services/robot_voice_service.dart';
import 'haze_face.dart';

class RobotFaceWidget extends StatefulWidget {
  /// Optional interaction overrides for screens where touching Haze has a
  /// more specific meaning (for example, a controlled experiment in Lab).
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool framed;

  const RobotFaceWidget({
    super.key,
    this.onTap,
    this.onLongPress,
    this.framed = true,
  });

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
          if (magnitude > 20 &&
              mounted &&
              !context.read<RobotFaceCubit>().mood.labControlled) {
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
            final width = math.min(maxW * .94, 540.0);
            final height = math.min(maxH * (widget.framed ? .8 : .94), 640.0);
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
                onTap: widget.onTap ?? cubit.onTap,
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  (widget.onLongPress ?? cubit.cuddle).call();
                },
                onPanStart: (details) => lookAt(details.localPosition),
                onPanUpdate: (details) => lookAt(details.localPosition),
                onPanEnd: (_) => cubit.setLookTarget(null),
                onPanCancel: () => cubit.setLookTarget(null),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  scale: state.isPressed ? 1.05 : 1.0,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: HazeFace(
                      state: state,
                      mood: cubit.mood,
                      companion: cubit.companion,
                      framed: widget.framed,
                      voiceLevel:
                          state.isSpeaking ||
                              state.mimicStatus != MimicStatus.idle
                          ? cubit.voice.level
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
