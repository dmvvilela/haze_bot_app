import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/main.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/services/haze_brain.dart';
import 'package:haze_bot_app/widgets/ai_consent_dialog.dart';

void main() {
  test('Robot voice defaults are calm', () {
    const config = RobotConfig();

    expect(config.speechRate, 0.55);
    expect(config.speechPitch, 0.95);
    expect(config.robotVoiceEnabled, isTrue);
  });

  test('Robot interaction defaults are idle', () {
    const state = RobotFaceState();

    expect(state.isSpeaking, isFalse);
    expect(state.isLoadingAI, isFalse);
    expect(state.ttsVoiceOptions, isEmpty);
    expect(state.selectedTtsVoiceId, isNull);
  });

  testWidgets('Every Haze character voice ships a complete reaction pack', (
    WidgetTester tester,
  ) async {
    const clips = [
      'hello',
      'happy',
      'annoyed',
      'sleepy',
      'confused',
      'love',
      'sad',
      'scared',
    ];
    for (final voice in HazeVoice.values) {
      for (final localePath in ['', '/pt']) {
        for (final clip in clips) {
          final data = await rootBundle.load(
            'assets/voices/haze/${voice.assetId}$localePath/$clip.wav',
          );
          expect(data.lengthInBytes, greaterThan(1000));
        }
      }
    }
  });

  testWidgets('Haze app renders main controls', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);

    final cubit = RobotFaceCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const RobotFaceScreen(),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);

    // Haze V3 is the default face.
    expect(cubit.state.config.faceType, FaceType.hazeV3);
    expect(find.bySemanticsLabel('Haze face'), findsOneWidget);

    // Other faces stay reachable through the face-type picker's cubit path.
    cubit.updateFaceType(FaceType.hazeV2);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.bySemanticsLabel('Haze V2 face'), findsOneWidget);

    // Switch to the static classic face so pumpAndSettle below can settle
    // (V2/V3 animate forever).
    cubit.updateFaceType(FaceType.classic);
    await tester.pump(const Duration(milliseconds: 200));
    expect(cubit.state.config.faceType, FaceType.classic);

    // Settings now lives in the overflow menu.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('AI Brain'), findsOneWidget);
    expect(find.text('Haze mood'), findsOneWidget);
    expect(find.text('Voice and language'), findsOneWidget);
    expect(find.text('Playful'), findsWidgets);
    expect(find.text('Voice style'), findsNothing);
    expect(find.text('Voice'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    cubit.startTimer(1);
    await tester.pump();
    await tester.pump();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    cubit.stopTimer();
  });

  testWidgets('skipping AI consent still resolves and can ask later', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final cubit = RobotFaceCubit();
    addTearDown(cubit.close);
    var resolved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: AiConsentDialog(onResolved: () => resolved = true),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(resolved, isTrue);
    expect(cubit.state.aiConsent, AiConsent.unknown);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('haze_ai_consent'), isNull);
  });

  testWidgets('old declined consent does not block future brain prompts', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'haze_ai_consent': 'declined'});

    final cubit = RobotFaceCubit();
    addTearDown(cubit.close);
    await tester.pump();

    expect(cubit.state.aiConsent, AiConsent.unknown);
  });

  testWidgets('personality selection is persisted and restored', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final firstCubit = RobotFaceCubit();
    addTearDown(firstCubit.close);
    await firstCubit.setPersonality(HazePersonality.zen);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('haze_personality'), 'zen');

    final secondCubit = RobotFaceCubit();
    addTearDown(secondCubit.close);
    await tester.pump();

    expect(secondCubit.state.personality, HazePersonality.zen);
  });
}
