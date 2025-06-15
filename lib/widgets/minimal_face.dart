import 'package:flutter/material.dart';
import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../painters/mouth_painter.dart';

class MinimalFace extends StatelessWidget {
  final RobotFaceState state;

  const MinimalFace({super.key, required this.state});

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
      width: 60,
      height: 60 * blinkScale,
      decoration: BoxDecoration(
        color: state.config.eyeColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: state.config.eyeColor.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)],
      ),
      child: blinkScale > 0.5 ? _buildPupil(isLeft: isLeft) : null,
    );
  }

  Widget _buildPupil({required bool isLeft}) {
    double pupilOffsetX = 0;
    double pupilOffsetY = 0;
    double pupilSize = 20;

    switch (state.config.expression) {
      case RobotExpression.happy:
        pupilSize = 18;
        break;
      case RobotExpression.surprised:
        pupilSize = 25;
        break;
      case RobotExpression.sleepy:
        pupilSize = 15;
        pupilOffsetY = 5;
        break;
      case RobotExpression.excited:
        pupilSize = 22;
        break;
      case RobotExpression.confused:
        pupilOffsetX = isLeft ? -3 : 3;
        break;
      case RobotExpression.love:
        pupilSize = 16;
        break;
      case RobotExpression.angry:
        pupilSize = 18;
        pupilOffsetY = -3;
        break;
      case RobotExpression.winking:
        if (isLeft) {
          pupilSize = 0; // Left eye closed for wink
        } else {
          pupilSize = 25; // Right eye wide open
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
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
          child: state.config.expression == RobotExpression.love
              ? const Center(child: Icon(Icons.favorite, color: Colors.red, size: 10))
              : Center(
                  child: Container(
                    width: pupilSize * 0.2,
                    height: pupilSize * 0.2,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    return Container(
      width: 80,
      height: 40,
      child: CustomPaint(
        painter: MouthPainter(
          expression: state.config.expression,
          color: state.config.mouthColor,
          animationValue: 1.0,
          isMinimalStyle: true,
        ),
      ),
    );
  }
}
