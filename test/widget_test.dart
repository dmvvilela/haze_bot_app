import 'package:flutter/material.dart';
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
  });

  test('Voice style support is opt-in by device capability', () {
    const state = RobotFaceState();

    expect(state.supportsGenderedVoiceChoice, isFalse);
    expect(state.ttsVoicePreference, TtsVoicePreference.automatic);
    expect(
      state
          .copyWith(supportsGenderedVoiceChoice: true)
          .supportsGenderedVoiceChoice,
      isTrue,
    );
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
    expect(find.text('V1'), findsOneWidget);
    expect(find.text('V2'), findsOneWidget);

    await tester.tap(find.text('V2'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(cubit.state.config.faceType, FaceType.hazeV2);
    expect(find.bySemanticsLabel('Haze V2 face'), findsOneWidget);

    await tester.tap(find.text('V1'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(cubit.state.config.faceType, FaceType.classic);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('AI Brain'), findsOneWidget);
    expect(find.text('Haze mood'), findsOneWidget);
    expect(find.text('Playful'), findsWidgets);
    expect(find.text('Voice style'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    cubit.startTimer(1);
    await tester.pump();
    await tester.pump();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    cubit.stopTimer();
  });

  testWidgets('declining AI consent still resolves pending action', (
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
    expect(cubit.state.aiConsent.name, 'declined');
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
