import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haze_bot_app/cubits/feelings_game_cubit.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/widgets/feelings_game_screen.dart';

// Renders the feelings game screen to a golden PNG for design review.
// Regenerate with: flutter test --update-goldens test/feelings_game_golden_test.dart

void main() {
  testWidgets('feelings game screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final robot = RobotFaceCubit();
    addTearDown(robot.close);
    // No audio plugin in tests — keep the player pool from being created.
    robot.sounds.enabled = false;
    // Seeded so the round (and therefore the golden) is deterministic.
    final game = FeelingsGameCubit(robot, random: math.Random(7));
    addTearDown(game.close);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: robot),
            BlocProvider.value(value: game),
          ],
          child: const FeelingsGameScreen(),
        ),
      ),
    );
    // Bounded pumps: the V3 face animates forever, so pumpAndSettle would hang.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 90));
    }

    expect(robot.state.config.expression, game.state.target);
    expect(game.state.options.contains(game.state.target), isTrue);

    await expectLater(
      find.byType(FeelingsGameScreen),
      matchesGoldenFile('goldens/feelings_game.png'),
    );
  });

  testWidgets('game answers advance and score', (tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);

    final robot = RobotFaceCubit();
    addTearDown(robot.close);
    robot.sounds.enabled = false;
    final game = FeelingsGameCubit(robot, random: math.Random(3));
    addTearDown(game.close);

    final firstTarget = game.state.target;
    final wrong = game.state.options.firstWhere((e) => e != firstTarget);

    game.guess(wrong);
    expect(game.state.misses, {wrong});
    expect(game.state.score, 0);

    game.guess(firstTarget);
    expect(game.state.score, 1);
    expect(game.state.celebrating, isTrue);

    // Let the next-round timer fire inside the test scope.
    await tester.pump(const Duration(seconds: 2));
    expect(game.state.round, 2);
    expect(game.state.celebrating, isFalse);
    expect(game.state.target, isNot(firstTarget));
  });
}
