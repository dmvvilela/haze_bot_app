import 'package:flutter/material.dart';
import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../painters/mouth_painter.dart';

class ClassicFace extends StatelessWidget {
  final RobotFaceState state;

  const ClassicFace({super.key, required this.state});

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
      width: 80,
      height: 80 * blinkScale,
      decoration: BoxDecoration(
        color: state.config.eyeColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: state.config.eyeColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
      ),
      child: blinkScale > 0.5 ? _buildPupil(isLeft: isLeft) : null,
    );
  }

  Widget _buildPupil({required bool isLeft}) {
    double pupilOffset = 0;
    double pupilSize = 30;

    switch (state.config.expression) {
      case RobotExpression.happy:
        pupilSize = 25;
        break;
      case RobotExpression.surprised:
        pupilSize = 35;
        break;
      case RobotExpression.sleepy:
        pupilSize = 20;
        pupilOffset = 5;
        break;
      case RobotExpression.excited:
        pupilSize = 30;
        break;
      case RobotExpression.confused:
        pupilOffset = isLeft ? -8 : 8;
        break;
      case RobotExpression.love:
        pupilSize = 20;
        break;
      case RobotExpression.angry:
        pupilSize = 25;
        pupilOffset = isLeft ? 3 : -3;
        break;
      case RobotExpression.winking:
        if (isLeft) {
          pupilSize = 0; // Left eye closed for wink
        } else {
          pupilSize = 35; // Right eye wide open
        }
        break;
    }

    if (pupilSize == 0) return const SizedBox.shrink();

    return Center(
      child: Transform.translate(
        offset: Offset(pupilOffset, pupilOffset),
        child: Container(
          width: pupilSize,
          height: pupilSize,
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: state.config.expression == RobotExpression.love
              ? const Center(child: Icon(Icons.favorite, color: Colors.red, size: 15))
              : Center(
                  child: Container(
                    width: pupilSize * 0.3,
                    height: pupilSize * 0.3,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    return Container(
      width: 120,
      height: 60,
      child: CustomPaint(
        painter: MouthPainter(expression: state.config.expression, color: state.config.mouthColor, animationValue: 1.0),
      ),
    );
  }
}
