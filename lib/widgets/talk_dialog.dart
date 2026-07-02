import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../services/haze_brain.dart';
import 'ai_consent_dialog.dart';

/// Lets the user actually talk to Haze. The reply is spoken (if speech is on),
/// drives Haze's face, and is also shown here as a little chat bubble.
class TalkDialog extends StatefulWidget {
  const TalkDialog({super.key});

  @override
  State<TalkDialog> createState() => _TalkDialogState();
}

class _TalkDialogState extends State<TalkDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<RobotFaceCubit>().talkToHaze(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final downloading = state.brainStatus == BrainStatus.downloading;
        final unavailable = state.brainStatus == BrainStatus.unavailable;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.smart_toy, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Talk to Haze'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Not opted in yet: offer to enable the on-device brain. Until
              // then Haze answers with its built-in canned lines.
              if (state.aiConsent != AiConsent.granted) ...[
                FilledButton.tonalIcon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<RobotFaceCubit>(),
                      child: const AiConsentDialog(),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Enable Haze's AI brain"),
                ),
                const SizedBox(height: 12),
              ],

              // Haze's latest line (or a hint while the brain wakes up).
              if (state.aiMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(state.aiMessage),
                ),

              if (downloading) ...[
                const SizedBox(height: 12),
                Text('Waking Haze up… ${state.downloadProgress}%'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: state.downloadProgress > 0
                      ? state.downloadProgress / 100
                      : null,
                ),
              ],

              if (unavailable) ...[
                const SizedBox(height: 12),
                const Text(
                  "Haze's brain couldn't load on this device — using built-in "
                  'replies for now.',
                  style: TextStyle(fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(context),
                decoration: InputDecoration(
                  hintText: 'Say something to Haze…',
                  border: const OutlineInputBorder(),
                  suffixIcon: state.isLoadingAI
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _send(context),
                        ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
