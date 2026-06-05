import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/main.dart';
import 'package:haze_bot_app/services/haze_brain.dart';
import 'package:haze_bot_app/widgets/ai_consent_dialog.dart';

void main() {
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
