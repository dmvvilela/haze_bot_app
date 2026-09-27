import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../services/haze_brain.dart';
import '../theme/haze_theme.dart';
import '../i18n/strings.g.dart';

/// Inline chat composer for talking to Haze without leaving the main face.
class TalkComposer extends StatefulWidget {
  const TalkComposer({super.key});

  @override
  State<TalkComposer> createState() => _TalkComposerState();
}

class _TalkComposerState extends State<TalkComposer> {
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
        final unavailable = state.brainStatus == BrainStatus.unavailable;
        final colors = Theme.of(context).colorScheme;

        return HazePanel(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.home.chat,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: t.home.close,
                      icon: const Icon(Icons.close),
                      onPressed: context
                          .read<RobotFaceCubit>()
                          .toggleChatComposer,
                    ),
                  ],
                ),
                if (unavailable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      t.home.fallback,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !state.isLoadingAI,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(context),
                  decoration: InputDecoration(
                    hintText: t.home.chatHint,
                    isDense: true,
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
                            tooltip: t.home.send,
                            icon: const Icon(Icons.send),
                            onPressed: () => _send(context),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
