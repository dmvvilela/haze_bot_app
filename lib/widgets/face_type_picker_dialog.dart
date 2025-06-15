import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../i18n/strings.g.dart';

class FaceTypePickerDialog extends StatelessWidget {
  const FaceTypePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(t.ui.choose_face_type),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FaceType.values.map((faceType) {
              return RadioListTile<FaceType>(
                title: Text(faceType.displayName),
                subtitle: Text(faceType.description),
                value: faceType,
                groupValue: state.config.faceType,
                onChanged: (value) {
                  if (value != null) {
                    context.read<RobotFaceCubit>().updateFaceType(value);
                  }
                },
              );
            }).toList(),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        );
      },
    );
  }
}
