import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import 'classic_face.dart';
import 'looi_face.dart';
import 'minimal_face.dart';
import 'bean_face.dart';

class RobotFaceWidget extends StatelessWidget {
  const RobotFaceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<RobotFaceCubit>().onTap(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.identity()..scale(state.isPressed ? 1.05 : 1.0),
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: state.config.isDarkTheme ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  // Subtle glow when pressed (dark mode only)
                  if (state.isPressed && state.config.isDarkTheme)
                    BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                  // Normal shadow for depth
                  BoxShadow(
                    color: state.config.isDarkTheme ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
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
    }
  }
}
