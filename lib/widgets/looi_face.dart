import 'package:flutter/material.dart';
import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../painters/mouth_painter.dart';

class LooiFace extends StatelessWidget {
  final RobotFaceState state;

  const LooiFace({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Eyes with eyebrows
        Column(
          children: [
            // Eyebrows
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildEyebrow(isLeft: true), _buildEyebrow(isLeft: false)]),
            const SizedBox(height: 10),
            // Eyes
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildEye(isLeft: true), _buildEye(isLeft: false)]),
          ],
        ),
        // Mouth
        _buildMouth(),
      ],
    );
  }

  Widget _buildEyebrow({required bool isLeft}) {
    double eyebrowAngle = 0;
    double eyebrowThickness = 4;

    switch (state.config.expression) {
      case RobotExpression.angry:
        eyebrowAngle = isLeft ? -0.3 : 0.3;
        eyebrowThickness = 6;
        break;
      case RobotExpression.confused:
        eyebrowAngle = isLeft ? 0.2 : -0.2;
        break;
      case RobotExpression.surprised:
        eyebrowAngle = isLeft ? 0.4 : -0.4;
        break;
      case RobotExpression.sleepy:
        eyebrowAngle = isLeft ? 0.1 : -0.1;
        eyebrowThickness = 3;
        break;
      default:
        eyebrowAngle = 0;
        break;
    }

    return Transform.rotate(
      angle: eyebrowAngle,
      child: Container(
        width: 50,
        height: eyebrowThickness,
        decoration: BoxDecoration(color: state.config.eyeColor.withOpacity(0.8), borderRadius: BorderRadius.circular(eyebrowThickness / 2)),
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    final blinkScale = state.isBlinking ? 0.1 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 70,
      height: 50 * blinkScale,
      decoration: BoxDecoration(
        color: state.config.eyeColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: state.config.eyeColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)],
      ),
      child: blinkScale > 0.5 ? _buildPupil(isLeft: isLeft) : null,
    );
  }

  Widget _buildPupil({required bool isLeft}) {
    double pupilOffsetX = 0;
    double pupilOffsetY = 0;
    double pupilSize = 25;

    switch (state.config.expression) {
      case RobotExpression.happy:
        pupilSize = 20;
        pupilOffsetY = -2;
        break;
      case RobotExpression.surprised:
        pupilSize = 30;
        break;
      case RobotExpression.sleepy:
        pupilSize = 15;
        pupilOffsetY = 8;
        break;
      case RobotExpression.excited:
        pupilSize = 25;
        pupilOffsetY = -3;
        break;
      case RobotExpression.confused:
        pupilOffsetX = isLeft ? -5 : 5;
        break;
      case RobotExpression.love:
        pupilSize = 18;
        break;
      case RobotExpression.angry:
        pupilSize = 22;
        pupilOffsetY = -5;
        break;
      case RobotExpression.winking:
        if (isLeft) {
          pupilSize = 0; // Left eye closed for wink
        } else {
          pupilSize = 30; // Right eye wide open
        }
        break;
    }

    if (pupilSize == 0) return const SizedBox.shrink();

    return Center(
      child: Transform.translate(
        offset: Offset(pupilOffsetX, pupilOffsetY),
        child: Container(
          width: pupilSize,
          height: pupilSize,
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: state.config.expression == RobotExpression.love
              ? const Center(child: Icon(Icons.favorite, color: Colors.red, size: 12))
              : Center(
                  child: Container(
                    width: pupilSize * 0.25,
                    height: pupilSize * 0.25,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    return Container(
      width: 100,
      height: 50,
      child: CustomPaint(
        painter: MouthPainter(expression: state.config.expression, color: state.config.mouthColor, animationValue: 1.0, isLooiStyle: true),
      ),
    );
  }
}
