import 'package:flutter/material.dart';
import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../painters/mouth_painter.dart';

class BeanFace extends StatelessWidget {
  final RobotFaceState state;

  const BeanFace({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Eyes
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildEye(isLeft: true), _buildEye(isLeft: false)]),
        // Mouth
        _buildMouth(),
      ],
    );
  }

  Widget _buildEye({required bool isLeft}) {
    final blinkScale = state.isBlinking ? 0.1 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 45,
      height: 85 * blinkScale, // Tall vertical eyes like beans
      decoration: BoxDecoration(
        color: state.config.eyeColor,
        borderRadius: BorderRadius.circular(22.5), // More oval/bean-like
        boxShadow: [BoxShadow(color: state.config.eyeColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
      ),
      child: blinkScale > 0.5 ? _buildPupil(isLeft: isLeft) : null,
    );
  }

  Widget _buildPupil({required bool isLeft}) {
    double pupilOffsetX = 0;
    double pupilOffsetY = 0;
    double pupilWidth = 20;
    double pupilHeight = 35; // Vertical pupil to match bean shape

    switch (state.config.expression) {
      case RobotExpression.happy:
        pupilWidth = 18;
        pupilHeight = 30;
        pupilOffsetY = -5;
        break;
      case RobotExpression.surprised:
        pupilWidth = 25;
        pupilHeight = 45;
        break;
      case RobotExpression.sleepy:
        pupilWidth = 15;
        pupilHeight = 20;
        pupilOffsetY = 15;
        break;
      case RobotExpression.excited:
        pupilWidth = 22;
        pupilHeight = 40;
        pupilOffsetY = -8;
        break;
      case RobotExpression.confused:
        pupilOffsetX = isLeft ? -5 : 5;
        pupilOffsetY = isLeft ? -3 : 3;
        break;
      case RobotExpression.love:
        pupilWidth = 16;
        pupilHeight = 25;
        break;
      case RobotExpression.angry:
        pupilWidth = 18;
        pupilHeight = 28;
        pupilOffsetY = -10;
        break;
      case RobotExpression.winking:
        if (isLeft) {
          pupilWidth = 0;
          pupilHeight = 0; // Left eye closed for wink
        } else {
          pupilWidth = 25;
          pupilHeight = 45; // Right eye wide open
        }
        break;
    }

    if (pupilWidth == 0 || pupilHeight == 0) return const SizedBox.shrink();

    return Center(
      child: Transform.translate(
        offset: Offset(pupilOffsetX, pupilOffsetY),
        child: Container(
          width: pupilWidth,
          height: pupilHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(pupilWidth / 2), // Oval pupil
          ),
          child: state.config.expression == RobotExpression.love
              ? const Center(child: Icon(Icons.favorite, color: Colors.red, size: 14))
              : Center(
                  child: Container(
                    width: pupilWidth * 0.3,
                    height: pupilHeight * 0.2,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(pupilWidth * 0.15)),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    return Container(
      width: 90,
      height: 45,
      child: CustomPaint(
        painter: MouthPainter(expression: state.config.expression, color: state.config.mouthColor, animationValue: 1.0, isBeanStyle: true),
      ),
    );
  }
}
