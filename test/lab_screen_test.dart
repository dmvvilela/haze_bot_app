import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/cubits/mix_game_cubit.dart';
import 'package:haze_bot_app/chemistry/chemistry.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/widgets/haze_lab_screen.dart';

void main() {
  for (final locale in [AppLocale.en, AppLocale.pt]) {
    testWidgets('lab reference, change, restore and exit in ${locale.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      LocaleSettings.setLocale(locale);
      final robot = RobotFaceCubit();
      final game = MixGameCubit(robot);

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: robot),
                BlocProvider.value(value: game),
              ],
              child: const HazeLabScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(robot.mood.paused, isTrue);
      expect(find.text(t.lab.references.title), findsOneWidget);
      expect(tester.takeException(), isNull);
      robot.sounds.enabled = false;
      final initial = robot.mood.level(Chemical.dopamine);
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      expect(robot.mood.level(Chemical.dopamine), closeTo(initial + 0.2, 1e-9));
      expect(
        find.textContaining(
          t.lab.references.changed(chemical: t.lab.chemicals.dopamine.name),
        ),
        findsOneWidget,
      );
      await tester.drag(find.byType(ListView), const Offset(0, 220));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(t.lab.references.restore));
      await tester.pump();
      expect(robot.mood.level(Chemical.dopamine), initial);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(t.lab.references.free));
      await tester.pump();
      expect(robot.mood.labControlled, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(robot.mood.paused, isFalse);
      await tester.runAsync(() async {
        await game.close();
        await robot.close();
      });
    });
  }
}
