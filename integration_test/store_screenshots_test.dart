import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haze_bot_app/cubits/feelings_game_cubit.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/main.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/widgets/feelings_game_screen.dart';

/// Captures App Store screenshots on a real simulator at native resolution.
/// Run per device class:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/store_screenshots_test.dart \
///     -d <SIMULATOR_UDID> --dart-define=SHOT_DEVICE=iphone69
const _device = String.fromEnvironment('SHOT_DEVICE', defaultValue: 'iphone69');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final cubit = RobotFaceCubit();
    addTearDown(cubit.close);
    cubit.sounds.enabled = false;

    Widget mainScreen() => TranslationProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocProvider.value(value: cubit, child: const RobotFaceScreen()),
      ),
    );

    // The face animates forever, so settle with bounded pumps.
    Future<void> settle([int frames = 12]) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 80));
      }
    }

    Future<void> shot(String locale, String name) async {
      await tester.pump(const Duration(milliseconds: 50));
      await binding.takeScreenshot(
        'release/screenshots/ios/$locale/$_device/$name',
      );
    }

    for (final (locale, appLocale, language) in [
      ('en-US', AppLocale.en, 'en-US'),
      ('pt-BR', AppLocale.pt, 'pt-BR'),
    ]) {
      LocaleSettings.setLocale(appLocale);
      cubit.updateLanguage(language);

      // 1) Hero: happy face, ambient mode (controls hidden).
      await tester.pumpWidget(mainScreen());
      if (cubit.state.showControls) cubit.toggleControls();
      cubit.showExpression(RobotExpression.happy);
      await settle(16);
      await shot(locale, '01_hero_happy');

      // 2) Sad, mid-teardrop.
      cubit.showExpression(RobotExpression.sad);
      await settle(14);
      await shot(locale, '02_sad_tear');

      // 3) Heart eyes.
      cubit.showExpression(RobotExpression.love);
      await settle(12);
      await shot(locale, '03_love');

      // 4) Excited with sparkles.
      cubit.showExpression(RobotExpression.excited);
      await settle(11);
      await shot(locale, '04_excited');

      // 5) The feelings game.
      final game = FeelingsGameCubit(cubit, random: math.Random(7));
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: cubit),
                BlocProvider.value(value: game),
              ],
              child: const FeelingsGameScreen(),
            ),
          ),
        ),
      );
      await settle(14);
      await shot(locale, '05_feelings_game');
      await game.close();

      // Restore controls for the next locale pass.
      await tester.pumpWidget(mainScreen());
      if (!cubit.state.showControls) cubit.toggleControls();
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
}
