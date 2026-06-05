import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import '../services/haze_brain.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(t.ui.settings),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: const Text('AI Brain'),
                    subtitle: Text(_brainStatusText(state)),
                  ),
                  if (state.brainStatus == BrainStatus.downloading) ...[
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: state.downloadProgress > 0
                          ? state.downloadProgress / 100
                          : null,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _brainActions(context, state),
                    ),
                  ),
                  const Divider(height: 28),
                  ListTile(
                    leading: const Icon(Icons.theater_comedy),
                    title: const Text('Haze mood'),
                    subtitle: Text(state.personality.displayName),
                    trailing: DropdownButton<HazePersonality>(
                      value: state.personality,
                      items: HazePersonality.values
                          .map(
                            (personality) => DropdownMenuItem(
                              value: personality,
                              child: Text(personality.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (personality) {
                        if (personality != null) {
                          context.read<RobotFaceCubit>().setPersonality(
                            personality,
                          );
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(t.ui.language),
                    subtitle: Text(
                      state.config.language == 'en-US'
                          ? 'English'
                          : 'Português',
                    ),
                    trailing: DropdownButton<String>(
                      value: state.config.language,
                      items: const [
                        DropdownMenuItem(
                          value: 'en-US',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'pt-BR',
                          child: Text('Português'),
                        ),
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
                    onChanged: (_) =>
                        context.read<RobotFaceCubit>().toggleSpeech(),
                  ),
                  if (state.config.speechEnabled) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: context.read<RobotFaceCubit>().previewVoice,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Test voice'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${t.ui.speech_rate}: ${state.config.speechRate.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: state.config.speechRate,
                      min: 0.1,
                      max: 2.0,
                      divisions: 19,
                      onChanged: (value) => context
                          .read<RobotFaceCubit>()
                          .updateSpeechRate(value),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t.ui.speech_pitch}: ${state.config.speechPitch.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: state.config.speechPitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (value) => context
                          .read<RobotFaceCubit>()
                          .updateSpeechPitch(value),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  String _brainStatusText(RobotFaceState state) {
    if (state.aiConsent == AiConsent.declined) {
      return 'Using built-in replies. Nothing downloads.';
    }
    if (state.aiConsent == AiConsent.unknown) {
      return 'Optional. Enable it to chat locally on this phone.';
    }
    return switch (state.brainStatus) {
      BrainStatus.idle => 'Enabled. Haze will wake it on first use.',
      BrainStatus.downloading =>
        "Downloading Haze's brain... ${state.downloadProgress}%",
      BrainStatus.preparing => 'Waking Haze up...',
      BrainStatus.ready => 'Ready. Replies run fully offline.',
      BrainStatus.unavailable =>
        "Couldn't load. Haze is using built-in replies for now.",
    };
  }

  List<Widget> _brainActions(BuildContext context, RobotFaceState state) {
    final cubit = context.read<RobotFaceCubit>();
    final busy =
        state.brainStatus == BrainStatus.downloading ||
        state.brainStatus == BrainStatus.preparing;

    if (busy) return const [];

    final actions = <Widget>[];
    if (state.aiConsent != AiConsent.granted ||
        state.brainStatus == BrainStatus.unavailable) {
      actions.add(
        FilledButton.tonalIcon(
          onPressed: cubit.grantAiConsent,
          icon: Icon(
            state.brainStatus == BrainStatus.unavailable
                ? Icons.refresh
                : Icons.download,
          ),
          label: Text(
            state.brainStatus == BrainStatus.unavailable ? 'Retry' : 'Enable',
          ),
        ),
      );
    }
    if (state.aiConsent == AiConsent.granted) {
      actions.add(
        TextButton.icon(
          onPressed: cubit.declineAiConsent,
          icon: const Icon(Icons.wifi_off),
          label: const Text('Use built-in replies'),
        ),
      );
    }
    return actions;
  }
}
