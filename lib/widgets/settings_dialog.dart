import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(t.ui.settings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(t.ui.language),
                subtitle: Text(state.config.language == 'en-US' ? 'English' : 'Português'),
                trailing: DropdownButton<String>(
                  value: state.config.language,
                  items: const [
                    DropdownMenuItem(value: 'en-US', child: Text('English')),
                    DropdownMenuItem(value: 'pt-BR', child: Text('Português')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<RobotFaceCubit>().updateLanguage(value);
                      // Update app locale
                      if (value == 'pt-BR') {
                        LocaleSettings.setLocale(AppLocale.pt);
                      } else {
                        LocaleSettings.setLocale(AppLocale.en);
                      }
                    }
                  },
                ),
              ),
              SwitchListTile(
                title: Text(t.ui.speech_enabled),
                subtitle: Text(t.ui.speech_description),
                value: state.config.speechEnabled,
                onChanged: (_) => context.read<RobotFaceCubit>().toggleSpeech(),
              ),
              if (state.config.speechEnabled) ...[
                const SizedBox(height: 16),
                Text('${t.ui.speech_rate}: ${state.config.speechRate.toStringAsFixed(1)}'),
                Slider(
                  value: state.config.speechRate,
                  min: 0.1,
                  max: 2.0,
                  divisions: 19,
                  onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechRate(value),
                ),
                const SizedBox(height: 8),
                Text('${t.ui.speech_pitch}: ${state.config.speechPitch.toStringAsFixed(1)}'),
                Slider(
                  value: state.config.speechPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechPitch(value),
                ),
              ],
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        );
      },
    );
  }
}
