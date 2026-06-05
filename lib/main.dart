import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'cubits/robot_face_cubit.dart';
import 'widgets/robot_face_widget.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/face_type_picker_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/timer_dialog.dart';
import 'widgets/talk_dialog.dart';
import 'widgets/ai_consent_dialog.dart';
import 'services/haze_brain.dart';
import 'models/robot_config.dart';
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
                          onPressed: () =>
                              _withAiConsent(context, () => _showTalk(context)),
                        ),
                        // Personality picker — swaps Haze's voice
                        PopupMenuButton<HazePersonality>(
                          icon: Icon(Icons.theater_comedy),
                          tooltip: "Haze's mood",
                          initialValue: state.personality,
                          onSelected: (p) =>
                              context.read<RobotFaceCubit>().setPersonality(p),
                          itemBuilder: (_) => HazePersonality.values
                              .map(
                                (p) => PopupMenuItem(
                                  value: p,
                                  child: Text(p.displayName),
                                ),
                              )
                              .toList(),
                        ),
                        IconButton(
                          icon: Icon(Icons.palette),
                          onPressed: () => _showColorPicker(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.face),
                          onPressed: () => _showFaceTypePicker(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () => _showSettings(context),
                        ),
                        IconButton(
                          icon: Icon(
                            state.config.isDarkTheme
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: () =>
                              context.read<RobotFaceCubit>().toggleTheme(),
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
                // Robot face always centered
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppBar().preferredSize.height,
                  ),
                  child: Center(child: const RobotFaceWidget()),
                ),
                // Full screen gesture detector only when controls are hidden
                if (!state.showControls)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        context.read<RobotFaceCubit>().toggleControls();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                if (state.showControls)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: (state.timerSeconds > 0 || state.isTimerRunning)
                        ? 96
                        : 28,
                    child: _BotVersionSwitch(state: state),
                  ),
                if (state.timerSeconds > 0 || state.isTimerRunning)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 28,
                    child: _TimerOverlay(state: state),
                  ),
              ],
            ),
          ),
        );
      },
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

  void _showTalk(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: const TalkDialog(),
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

class _BotVersionSwitch extends StatelessWidget {
  final RobotFaceState state;

  const _BotVersionSwitch({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = state.config.faceType == FaceType.hazeV2
        ? FaceType.hazeV2
        : FaceType.classic;

    return Center(
      child: Material(
        elevation: 8,
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SegmentedButton<FaceType>(
            showSelectedIcon: false,
            selected: {selected},
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            segments: const [
              ButtonSegment<FaceType>(
                value: FaceType.classic,
                icon: Icon(Icons.smart_toy_outlined, size: 18),
                label: Text('V1'),
              ),
              ButtonSegment<FaceType>(
                value: FaceType.hazeV2,
                icon: Icon(Icons.auto_awesome, size: 18),
                label: Text('V2'),
              ),
            ],
            onSelectionChanged: (selection) {
              final next = selection.first;
              context.read<RobotFaceCubit>().updateFaceType(next);
            },
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
