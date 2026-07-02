import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import 'alive_face.dart';
import 'classic_face.dart';
import 'haze_face.dart';
import 'looi_face.dart';
import 'minimal_face.dart';
import 'bean_face.dart';

class RobotFaceWidget extends StatelessWidget {
  const RobotFaceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final isV2 = state.config.faceType == FaceType.hazeV2;
        final isV3 = state.config.faceType == FaceType.hazeV3;
        // V3 is a full "screen face" — let it take most of the display, the
        // way mall companion robots do.
        final media = MediaQuery.sizeOf(context);
        final width = isV3
            ? math.min(media.width * 0.94, 540.0)
            : (isV2 ? 360.0 : 300.0);
        final height = isV3
            ? math.min(media.height * 0.68, 640.0)
            : (isV2 ? 440.0 : 400.0);
        final cubit = context.read<RobotFaceCubit>();

        // Convert a touch position into a normalized look direction so the
        // eyes can track the user's finger.
        void lookAt(Offset local) {
          cubit.setLookTarget(
            Offset(
              ((local.dx / width) - 0.5) * 2.4,
              ((local.dy / height) - 0.5) * 2.2,
            ),
          );
        }

        return GestureDetector(
          // The face itself paints on a bare CustomPaint, which isn't
          // hit-testable — without this, taps on V2/V3 never land.
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            cubit.onTap();
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
              child: _buildFaceType(state.config.faceType, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceType(FaceType faceType, RobotFaceState state) {
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
        return AliveFace(state: state);
      case FaceType.hazeV3:
        return HazeFace(state: state);
    }
  }
}
