import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(t.ui.choose_colors),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.ui.eye_color),
              Wrap(
                children: [Colors.cyan, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.red, Colors.yellow, Colors.pink]
                    .map(
                      (color) => GestureDetector(
                        onTap: () => context.read<RobotFaceCubit>().updateEyeColor(color),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: state.config.eyeColor == color ? Border.all(color: Colors.white, width: 3) : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Text(t.ui.mouth_color),
              Wrap(
                children: [Colors.pink, Colors.red, Colors.orange, Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.cyan]
                    .map(
                      (color) => GestureDetector(
                        onTap: () => context.read<RobotFaceCubit>().updateMouthColor(color),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: state.config.mouthColor == color ? Border.all(color: Colors.white, width: 3) : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        );
      },
    );
  }
}
