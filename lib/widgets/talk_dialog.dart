import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../services/haze_brain.dart';

/// Inline chat composer for talking to Haze without leaving the main face.
class TalkComposer extends StatefulWidget {
  const TalkComposer({super.key});

  @override
  State<TalkComposer> createState() => _TalkComposerState();
}

class _TalkComposerState extends State<TalkComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _inputVisible = true;

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
    setState(() => _inputVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final isPt = state.config.language.toLowerCase().startsWith('pt');
        final unavailable = state.brainStatus == BrainStatus.unavailable;
        final colors = Theme.of(context).colorScheme;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _inputVisible ? null : () => setState(() => _inputVisible = true),
          child: Material(
            elevation: 12,
            color: colors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(isPt ? 'Modo chat' : 'Chat mode', style: Theme.of(context).textTheme.titleSmall)),
                      IconButton(
                        tooltip: isPt ? 'Fechar' : 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: context.read<RobotFaceCubit>().toggleChatComposer,
                      ),
                    ],
                  ),
                  if (unavailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        isPt
                            ? 'O cérebro local não carregou. Usando respostas prontas por enquanto.'
                            : "Haze's local brain could not load. Using built-in replies for now.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (!_inputVisible)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 8, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.isLoadingAI
                                  ? (isPt ? 'Haze está pensando...' : 'Haze is thinking...')
                                  : (isPt ? 'Toque para continuar' : 'Tap to keep talking'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          if (state.isLoadingAI) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                    )
                  else
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      enabled: !state.isLoadingAI,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(context),
                      decoration: InputDecoration(
                        hintText: isPt ? 'Digite uma mensagem para o Haze...' : 'Say something to Haze...',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: state.isLoadingAI
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : IconButton(tooltip: isPt ? 'Enviar' : 'Send', icon: const Icon(Icons.send), onPressed: () => _send(context)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
