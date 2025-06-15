import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/robot_face_cubit.dart';
import 'models/robot_config.dart';
import 'widgets/robot_face_widget.dart';

void main() {
  runApp(const HazeBotApp());
}

class HazeBotApp extends StatelessWidget {
  const HazeBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HazeBot Face',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: BlocProvider(create: (context) => RobotFaceCubit()..startBlinking(), child: const RobotFaceScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RobotFaceScreen extends StatelessWidget {
  const RobotFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.white),
            onPressed: () => _showColorPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.face, color: Colors.white),
            onPressed: () => _showFaceTypePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: const Center(child: RobotFaceWidget()),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: const Text('Choose Colors'),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Eye Color'),
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
                  const Text('Mouth Color'),
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
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }

  void _showFaceTypePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: const Text('Choose Face Type'),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
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
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: const Text('Settings'),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Speech Enabled'),
                    subtitle: const Text('Robot will speak when expressions change'),
                    value: state.config.speechEnabled,
                    onChanged: (_) => context.read<RobotFaceCubit>().toggleSpeech(),
                  ),
                  if (state.config.speechEnabled) ...[
                    const SizedBox(height: 16),
                    Text('Speech Rate: ${state.config.speechRate.toStringAsFixed(1)}'),
                    Slider(
                      value: state.config.speechRate,
                      min: 0.1,
                      max: 2.0,
                      divisions: 19,
                      onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechRate(value),
                    ),
                    const SizedBox(height: 8),
                    Text('Speech Pitch: ${state.config.speechPitch.toStringAsFixed(1)}'),
                    Slider(
                      value: state.config.speechPitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechPitch(value),
                    ),
                  ],
                ],
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }
}
