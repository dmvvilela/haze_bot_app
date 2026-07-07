import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'cubits/feelings_game_cubit.dart';
import 'cubits/robot_face_cubit.dart';
import 'widgets/feelings_game_screen.dart';
import 'widgets/robot_face_widget.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/face_type_picker_dialog.dart';
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

  LocaleSettings.setLocale(
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocale.values.map((locale) => locale.flutterLocale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocProvider(
        create: (context) => RobotFaceCubit()..startBlinking(),
        child: const RobotFaceScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum _MenuAction { colors, faceStyle, theme, settings }

PopupMenuItem<_MenuAction> _menuItem(
  _MenuAction action,
  IconData icon,
  String label,
) {
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
    ),
  );
}

class RobotFaceScreen extends StatelessWidget {
  const RobotFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return Theme(
          data: state.config.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            backgroundColor: state.config.isDarkTheme
                ? Colors.black
                : Colors.grey[100],
            appBar: AppBar(
              backgroundColor: state.config.isDarkTheme
                  ? Colors.black
                  : Colors.grey[100],
              elevation: 0,
              toolbarHeight: kToolbarHeight,
              actions: [
                AnimatedOpacity(
                  opacity: state.showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !state.showControls,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mimic — Haze listens, then repeats it in a silly voice
                        IconButton(
                          icon: Icon(switch (state.mimicStatus) {
                            MimicStatus.idle => Icons.mic_none,
                            MimicStatus.listening => Icons.mic,
                            MimicStatus.replaying => Icons.graphic_eq,
                          }),
                          color: state.mimicStatus == MimicStatus.listening
                              ? Colors.redAccent
                              : null,
                          tooltip: 'Mimic',
                          onPressed: () =>
                              context.read<RobotFaceCubit>().toggleMimic(),
                        ),
                        // Feelings game — Haze acts, the player names the emotion
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined),
                          tooltip: t.game.play,
                          onPressed: () => _showGame(context),
                        ),
                        // Timer button with indicator
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.timer),
                              onPressed: () => _showTimer(context),
                            ),
                            if (state.isTimerRunning)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // "Say something" button — Haze reacts to its current face
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.smart_toy),
                              onPressed: () => _withAiConsent(
                                context,
                                () => context
                                    .read<RobotFaceCubit>()
                                    .getAIResponse(),
                              ),
                            ),
                            if (state.isLoadingAI)
                              Positioned.fill(
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Talk-to-Haze button — type a message, Haze replies + emotes
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline),
                          onPressed: () => _withAiConsent(
                            context,
                            () => context
                                .read<RobotFaceCubit>()
                                .toggleChatComposer(),
                          ),
                        ),
                        // Everything else lives in the overflow menu — nine
                        // inline actions overflowed the app bar on phones.
                        PopupMenuButton<_MenuAction>(
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'More',
                          onSelected: (action) {
                            final cubit = context.read<RobotFaceCubit>();
                            switch (action) {
                              case _MenuAction.colors:
                                _showColorPicker(context);
                              case _MenuAction.faceStyle:
                                _showFaceTypePicker(context);
                              case _MenuAction.theme:
                                cubit.toggleTheme();
                              case _MenuAction.settings:
                                _showSettings(context);
                            }
                          },
                          itemBuilder: (_) => [
                            _menuItem(
                              _MenuAction.colors,
                              Icons.palette,
                              'Colors',
                            ),
                            _menuItem(
                              _MenuAction.faceStyle,
                              Icons.face,
                              'Face style',
                            ),
                            _menuItem(
                              _MenuAction.theme,
                              state.config.isDarkTheme
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              state.config.isDarkTheme
                                  ? 'Light theme'
                                  : 'Dark theme',
                            ),
                            _menuItem(
                              _MenuAction.settings,
                              Icons.settings,
                              'Settings',
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.visibility_off),
                          onPressed: () =>
                              context.read<RobotFaceCubit>().toggleControls(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                // With controls hidden, tapping the empty screen brings them
                // back. This sits UNDER the face so the face stays touchable
                // (poke to emote, drag so the eyes follow) in ambient mode.
                if (!state.showControls)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        context.read<RobotFaceCubit>().toggleControls();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                // Robot face always centered
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppBar().preferredSize.height,
                  ),
                  child: Center(child: const RobotFaceWidget()),
                ),
                if (state.showChatComposer)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: (state.timerSeconds > 0 || state.isTimerRunning)
                        ? 92
                        : 20,
                    child: const TalkComposer(),
                  ),
                // Whatever Haze last said, as a fading speech bubble — so its
                // lines are readable even with the voice turned off.
                if (state.aiMessage.isNotEmpty)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: state.showChatComposer
                        ? 160
                        : (state.timerSeconds > 0 || state.isTimerRunning)
                        ? 104
                        : 36,
                    child: _HazeSpeechBubble(
                      message: state.aiMessage,
                      speaking: state.isSpeaking,
                      accent: state.config.eyeColor,
                    ),
                  ),
                if (state.timerSeconds > 0 || state.isTimerRunning)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 28,
                    child: _TimerOverlay(state: state),
                  ),
                // Live waveform of Haze's ears (listening) or voice (talking).
                if (state.mimicStatus != MimicStatus.idle ||
                    (state.isSpeaking && state.config.robotVoiceEnabled))
                  Positioned(
                    left: 60,
                    right: 60,
                    top: 12,
                    child: VoiceWaveform(
                      voice: context.read<RobotFaceCubit>().voice,
                      color: state.mimicStatus == MimicStatus.listening
                          ? Colors.redAccent
                          : state.config.eyeColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const ColorPickerDialog(),
      ),
    );
  }

  void _showFaceTypePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const FaceTypePickerDialog(),
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
                tooltip: paused ? 'Resume' : 'Pause',
                onPressed: paused ? cubit.resumeTimer : cubit.pauseTimer,
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Stop',
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
