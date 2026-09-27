import 'dart:async';

import 'theme/haze_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'cubits/feelings_game_cubit.dart';
import 'cubits/mix_game_cubit.dart';
import 'cubits/robot_face_cubit.dart';
import 'widgets/feelings_game_screen.dart';
import 'widgets/haze_lab_screen.dart';
import 'widgets/aurea_lab_screen.dart';
import 'widgets/robot_face_widget.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/timer_dialog.dart';
import 'widgets/talk_dialog.dart';
import 'widgets/ai_consent_dialog.dart';
import 'widgets/voice_waveform.dart';
import 'services/haze_brain.dart';
import 'services/robot_voice_service.dart';
import 'i18n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load runtime config from .env (HUGGINGFACE_TOKEN, optional HAZE_MODEL_URL).
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found, on-device model may not download: $e');
  }

  // Initialize on-device AI. The (optional) HuggingFace token used for the
  // gated Gemma model download is read from .env.
  await FlutterGemma.initialize(
    huggingFaceToken: dotenv.isInitialized
        ? dotenv.maybeGet('HUGGINGFACE_TOKEN')
        : null,
  );

  LocaleSettings.setLocaleSync(
    AppLocale.en,
  ); // Start with English to match robot config default
  runApp(TranslationProvider(child: const HazeBotApp()));
}

class HazeBotApp extends StatelessWidget {
  const HazeBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: t.app.title,
      theme: HazeTheme.of(false),
      darkTheme: HazeTheme.of(true),
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocale.values.map((locale) => locale.flutterLocale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocProvider(
        create: (context) => RobotFaceCubit()
          ..startBlinking()
          ..startSecretInteractions(),
        child: const RobotFaceScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum _MenuAction { lab, say, colors, theme, settings }

PopupMenuItem<_MenuAction> _menuItem(
  _MenuAction action,
  IconData icon,
  String label,
) {
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class RobotFaceScreen extends StatelessWidget {
  const RobotFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) => Theme(
        data: HazeTheme.of(state.config.isDarkTheme),
        child: Builder(
          builder: (context) {
            final colors = Theme.of(context).colorScheme;
            final cubit = context.read<RobotFaceCubit>();
            final visible = state.showControls;
            return Scaffold(
              appBar: visible
                  ? AppBar(
                      toolbarHeight:
                          76 *
                          (MediaQuery.textScalerOf(context).scale(14) / 14)
                              .clamp(1, 1.5),
                      titleSpacing: 24,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Haze',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.7,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.home.companion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          tooltip: t.home.hide,
                          icon: const Icon(Icons.visibility_off_outlined),
                          onPressed: cubit.toggleControls,
                        ),
                        _toolsMenu(context, state),
                        const SizedBox(width: 12),
                      ],
                    )
                  : null,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final landscape =
                        constraints.maxWidth > 620 &&
                        constraints.maxWidth > constraints.maxHeight * 1.3;
                    final hero = Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: visible ? null : cubit.toggleControls,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  radius: .75,
                                  colors: [
                                    state.config.eyeColor.withValues(
                                      alpha: state.config.isDarkTheme
                                          ? .09
                                          : .06,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Center(child: RobotFaceWidget(framed: false)),
                        if (state.mimicStatus != MimicStatus.idle ||
                            state.isSpeaking)
                          Positioned(
                            top: 12,
                            left: 60,
                            right: 60,
                            child: VoiceWaveform(
                              voice: cubit.voice,
                              color: state.mimicStatus == MimicStatus.listening
                                  ? colors.error
                                  : colors.primary,
                            ),
                          ),
                        if (!visible)
                          Positioned(
                            top: 8,
                            right: 12,
                            child: IconButton(
                              tooltip: t.home.show,
                              icon: Icon(
                                Icons.visibility_outlined,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: .65,
                                ),
                              ),
                              onPressed: cubit.toggleControls,
                            ),
                          ),
                      ],
                    );
                    Widget controls() => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (visible && !state.showChatComposer) ...[
                            Text(
                              _status(state),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              t.home.hint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (state.aiMessage.isNotEmpty)
                            _HazeSpeechBubble(
                              message: state.aiMessage,
                              speaking: state.isSpeaking,
                              accent: colors.primary,
                            ),
                          if (state.timerSeconds > 0 || state.isTimerRunning)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                              ),
                              child: _TimerOverlay(state: state),
                            ),
                          if (visible && state.showChatComposer)
                            const TalkComposer()
                          else if (visible)
                            _homeActions(context, state),
                        ],
                      ),
                    );
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: landscape && visible
                            ? Row(
                                children: [
                                  Expanded(child: hero),
                                  SizedBox(
                                    width: constraints.maxWidth * .42 > 380
                                        ? 380
                                        : constraints.maxWidth * .42,
                                    child: SingleChildScrollView(
                                      child: controls(),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(child: hero),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          constraints.maxHeight *
                                          (state.showChatComposer ? .65 : .55),
                                    ),
                                    child: SingleChildScrollView(
                                      child: controls(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _status(RobotFaceState state) {
    if (state.mimicStatus == MimicStatus.listening) return t.home.listening;
    if (state.mimicStatus == MimicStatus.replaying) return t.home.replaying;
    if (state.isLoadingAI) return t.home.thinking;
    if (state.isSpeaking) return t.home.speaking;
    return t.home.greeting;
  }

  Widget _toolsMenu(BuildContext context, RobotFaceState state) =>
      PopupMenuButton<_MenuAction>(
        tooltip: t.home.more,
        icon: const Icon(Icons.more_vert),
        onSelected: (action) {
          final cubit = context.read<RobotFaceCubit>();
          switch (action) {
            case _MenuAction.lab:
              _showLab(context);
            case _MenuAction.say:
              _withAiConsent(context, cubit.getAIResponse);
            case _MenuAction.colors:
              _showColorPicker(context);
            case _MenuAction.theme:
              cubit.toggleTheme();
            case _MenuAction.settings:
              _showSettings(context);
          }
        },
        itemBuilder: (_) => [
          _menuItem(_MenuAction.say, Icons.smart_toy, t.home.say),
          _menuItem(_MenuAction.lab, Icons.science_outlined, t.lab.title),
          const PopupMenuDivider(),
          _menuItem(_MenuAction.colors, Icons.palette_outlined, t.home.colors),
          _menuItem(
            _MenuAction.theme,
            state.config.isDarkTheme
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            state.config.isDarkTheme ? t.home.light : t.home.dark,
          ),
          _menuItem(
            _MenuAction.settings,
            Icons.settings_outlined,
            t.ui.settings,
          ),
        ],
      );

  Widget _homeActions(BuildContext context, RobotFaceState state) {
    final cubit = context.read<RobotFaceCubit>();
    final colors = Theme.of(context).colorScheme;
    return HazePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HomeAction(
                  icon: Icons.chat_bubble_outline,
                  label: t.home.talk,
                  primary: true,
                  onTap: () =>
                      _withAiConsent(context, cubit.toggleChatComposer),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HomeAction(
                  icon: Icons.emoji_emotions_outlined,
                  label: t.home.play,
                  onTap: () => _showGame(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HomeAction(
                  icon: Icons.auto_awesome_outlined,
                  label: t.home.lab,
                  onTap: () => _showLab(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: cubit.toggleMimic,
                icon: Icon(
                  state.mimicStatus == MimicStatus.listening
                      ? Icons.stop_circle_outlined
                      : Icons.mic_none,
                  color: state.mimicStatus == MimicStatus.listening
                      ? colors.error
                      : null,
                  size: 19,
                ),
                label: Text(
                  state.mimicStatus == MimicStatus.listening
                      ? t.home.stop
                      : t.home.mimic,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showTimer(context),
                icon: const Icon(Icons.timer, size: 19),
                label: Text(t.home.timer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGame(BuildContext context) {
    final cubit = context.read<RobotFaceCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => FeelingsGameCubit(cubit)),
          ],
          child: const FeelingsGameScreen(),
        ),
      ),
    );
  }

  void _showLab(BuildContext context) {
    final cubit = context.read<RobotFaceCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AureaLabScreen(
          faceState: cubit.state,
          onOpenChemistry: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: cubit),
                  BlocProvider(create: (_) => MixGameCubit(cubit)),
                ],
                child: const HazeLabScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const ColorPickerDialog(),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const SettingsDialog(),
      ),
    );
  }

  void _showTimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const TimerDialog(),
      ),
    );
  }

  /// Gate AI features behind one-time consent: the first time the user invokes
  /// the brain we ask before downloading anything. Once they've decided
  /// (granted or declined) we just run the action — declined falls back to
  /// canned replies, so nothing downloads behind their back.
  void _withAiConsent(BuildContext context, VoidCallback action) {
    if (context.read<RobotFaceCubit>().state.aiConsent == AiConsent.unknown) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<RobotFaceCubit>(),
          child: AiConsentDialog(onResolved: action),
        ),
      );
    } else {
      action();
    }
  }
}

/// Haze's latest line, floated under the face. Slides in on a new message and
/// fades out on its own once Haze has finished making its point.
class _HazeSpeechBubble extends StatefulWidget {
  final String message;
  final bool speaking;
  final Color accent;

  const _HazeSpeechBubble({
    required this.message,
    required this.speaking,
    required this.accent,
  });

  @override
  State<_HazeSpeechBubble> createState() => _HazeSpeechBubbleState();
}

class _HazeSpeechBubbleState extends State<_HazeSpeechBubble> {
  Timer? _hideTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _show();
  }

  @override
  void didUpdateWidget(covariant _HazeSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message ||
        (widget.speaking && !oldWidget.speaking)) {
      _show();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _show() {
    setState(() => _visible = true);
    _scheduleHide(const Duration(seconds: 7));
  }

  void _scheduleHide(Duration delay) {
    _hideTimer?.cancel();
    _hideTimer = Timer(delay, () {
      if (!mounted) return;
      if (widget.speaking) {
        // Still talking — check back shortly instead of cutting the line off.
        _scheduleHide(const Duration(seconds: 2));
      } else {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!_visible) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _visible = false),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerOverlay extends StatelessWidget {
  final RobotFaceState state;

  const _TimerOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RobotFaceCubit>();
    final colors = Theme.of(context).colorScheme;
    final paused = !state.isTimerRunning && state.timerSeconds > 0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        elevation: 10,
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.personality == HazePersonality.meditative ||
                        state.personality == HazePersonality.sleepy
                    ? Icons.self_improvement
                    : Icons.timer,
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 74,
                child: Text(
                  _formatTimer(state.timerSeconds),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: paused ? t.home.resume : t.home.pause,
                onPressed: paused ? cubit.resumeTimer : cubit.pauseTimer,
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: t.home.stop,
                onPressed: cubit.stopTimer,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _HomeAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: primary ? colors.primary : colors.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: primary ? colors.onPrimary : colors.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primary ? colors.onPrimary : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
