import 'package:flutter/foundation.dart';
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
        final showVoicePicker =
            !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.iOS &&
            state.ttsVoiceOptions.length > 1;
        return AlertDialog(
          title: Text(t.ui.settings),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(
                    icon: Icons.auto_awesome,
                    title: 'AI Brain',
                    subtitle: _brainStatusText(state),
                  ),
                  if (state.brainStatus == BrainStatus.downloading) ...[
                    const SizedBox(height: 10),
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
                  const Divider(height: 32),
                  _SectionHeader(
                    icon: Icons.tune,
                    title: 'Voice and language',
                    subtitle: 'Local voice, mood, and speech settings.',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HazePersonality>(
                    initialValue: state.personality,
                    decoration: const InputDecoration(
                      labelText: 'Haze mood',
                      border: OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: state.config.language,
                    decoration: InputDecoration(
                      labelText: t.ui.language,
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en-US', child: Text('English')),
                      DropdownMenuItem(
                        value: 'pt-BR',
                        child: Text('Português'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<RobotFaceCubit>().updateLanguage(value);
                        if (value == 'pt-BR') {
                          LocaleSettings.setLocale(AppLocale.pt);
                        } else {
                          LocaleSettings.setLocale(AppLocale.en);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sound effects'),
                    subtitle: const Text(
                      'Chirps when you poke or play with Haze',
                    ),
                    value: state.config.soundEnabled,
                    onChanged: (_) =>
                        context.read<RobotFaceCubit>().toggleSound(),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.ui.speech_enabled),
                    subtitle: Text(t.ui.speech_description),
                    value: state.config.speechEnabled,
                    onChanged: (_) =>
                        context.read<RobotFaceCubit>().toggleSpeech(),
                  ),
                  if (state.config.speechEnabled) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Robot voice'),
                      subtitle: const Text('Adds the local robot texture'),
                      value: state.config.robotVoiceEnabled,
                      onChanged: (_) =>
                          context.read<RobotFaceCubit>().toggleRobotVoice(),
                    ),
                    if (showVoicePicker) ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          state.selectedTtsVoiceId ??
                              RobotFaceCubit.automaticVoiceId,
                        ),
                        initialValue:
                            state.selectedTtsVoiceId ??
                            RobotFaceCubit.automaticVoiceId,
                        decoration: const InputDecoration(
                          labelText: 'Voice',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: RobotFaceCubit.automaticVoiceId,
                            child: Text('Automatic'),
                          ),
                          ...state.ttsVoiceOptions.map(
                            (voice) => DropdownMenuItem(
                              value: voice.id,
                              child: Text(
                                voice.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (voiceId) =>
                            context.read<RobotFaceCubit>().setTtsVoice(voiceId),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: context.read<RobotFaceCubit>().previewVoice,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Test voice'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SliderField(
                      label: t.ui.speech_rate,
                      value: state.config.speechRate,
                      min: 0.1,
                      max: 2.0,
                      divisions: 19,
                      onChanged: (value) => context
                          .read<RobotFaceCubit>()
                          .updateSpeechRate(value),
                    ),
                    const SizedBox(height: 12),
                    _SliderField(
                      label: t.ui.speech_pitch,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
