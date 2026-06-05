import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../services/haze_brain.dart';

/// One-time, plain-language consent before Haze downloads its on-device AI
/// model. Nothing is downloaded until the user taps "Download" here — and Haze
/// keeps working with built-in replies if they decline.
class AiConsentDialog extends StatelessWidget {
  final VoidCallback? onResolved;

  const AiConsentDialog({super.key, this.onResolved});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final status = state.brainStatus;
        final busy =
            status == BrainStatus.downloading ||
            status == BrainStatus.preparing;
        final ready = status == BrainStatus.ready;
        final failed = status == BrainStatus.unavailable;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Flexible(child: Text('Give Haze a brain?')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!busy && !ready && !failed) ...[
                const Text(
                  'Haze can run a small AI model right on your phone so it can '
                  'chat and react with real feelings.\n',
                ),
                _bullet(
                  context,
                  Icons.download,
                  'One-time download of about 550 MB — Wi-Fi recommended.',
                ),
                _bullet(
                  context,
                  Icons.wifi_off,
                  'After that it runs fully offline. Nothing you say leaves your phone.',
                ),
                _bullet(
                  context,
                  Icons.toys,
                  'Totally optional — Haze still works without it, using built-in replies.',
                ),
              ],
              if (busy) ...[
                Text(
                  status == BrainStatus.downloading
                      ? "Downloading Haze's brain… ${state.downloadProgress}%"
                      : 'Waking Haze up…',
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value:
                      status == BrainStatus.downloading &&
                          state.downloadProgress > 0
                      ? state.downloadProgress / 100
                      : null,
                ),
              ],
              if (ready)
                const Text('Haze is awake! 🤖 Tap the chat bubble to talk.'),
              if (failed)
                const Text(
                  "Hmm, that didn't work on this device. Haze will use its "
                  'built-in replies for now.',
                ),
            ],
          ),
          actions: _actions(context, busy, ready, failed),
        );
      },
    );
  }

  Widget _bullet(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    bool busy,
    bool ready,
    bool failed,
  ) {
    final cubit = context.read<RobotFaceCubit>();

    if (ready) {
      return [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResolved?.call();
          },
          child: const Text('Done'),
        ),
      ];
    }
    if (failed) {
      return [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResolved?.call();
          },
          child: const Text('Use built-in reply'),
        ),
        ElevatedButton.icon(
          onPressed: () => cubit.grantAiConsent(),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ];
    }
    if (busy) {
      if (onResolved != null) return [];
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continue in background'),
        ),
      ];
    }
    return [
      TextButton(
        onPressed: () async {
          await cubit.declineAiConsent();
          if (!context.mounted) return;
          Navigator.of(context).pop();
          onResolved?.call();
        },
        child: const Text('Not now'),
      ),
      ElevatedButton.icon(
        onPressed: () async {
          await cubit.grantAiConsent();
          if (!context.mounted) return;
          Navigator.of(context).pop();
          onResolved?.call();
        },
        icon: const Icon(Icons.download),
        label: const Text('Download'),
      ),
    ];
  }
}
