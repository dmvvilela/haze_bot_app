import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/models/haze_look.dart';
import 'package:haze_bot_app/services/haze_plus_controller.dart';
import 'package:haze_bot_app/theme/haze_theme.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';
import 'package:haze_bot_app/widgets/haze_plus_screen.dart';
import 'support/fake_plus_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (locale, size, scale) in [
    (AppLocale.en, const Size(390, 844), 1.0),
    (AppLocale.pt, const Size(320, 568), 1.0),
    (AppLocale.pt, const Size(390, 844), 2.0),
    (AppLocale.en, const Size(844, 390), 1.0),
  ]) {
    testWidgets(
      'Plus previews, localized price and free exit at $locale $size $scale',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        LocaleSettings.setLocaleSync(locale);
        final store = FakePlusStore();
        final plus = HazePlusController(store: store);
        await plus.initialize();
        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              theme: HazeTheme.of(true),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: HazePlusScreen(
                controller: plus,
                faceState: const RobotFaceState(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        expect(find.text(t.plus.buy(price: 'R\$ 19,90')), findsOneWidget);
        await tester.ensureVisible(
          find.text(t.plus.styles[HazeFaceStyle.aurora.index]),
        );
        await tester.tap(find.text(t.plus.styles[HazeFaceStyle.aurora.index]));
        await tester.pump();
        expect(
          tester.widgetList<HazeFace>(find.byType(HazeFace)).first.look.style,
          HazeFaceStyle.aurora,
        );
        expect(plus.look, const HazeLook()); // Preview is never an apply.
        expect(store.purchases, 0);
        await tester.ensureVisible(find.text(t.plus.keep_classic));
        await tester.tap(find.text(t.plus.keep_classic));
        await tester.pump();
        expect(plus.ownsPlus, isFalse);
        expect(plus.look, const HazeLook());
        expect(store.purchases, 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        plus.dispose();
      },
    );
  }

  testWidgets(
    'all new face and accessory combinations stay in the shared rig',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1250);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const key = Key('cosmetics');
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: HazeTheme.ink,
              child: Column(
                children: [
                  for (final accessory in HazeAccessory.values)
                    Expanded(
                      child: Row(
                        children: [
                          for (final style in HazeFaceStyle.values)
                            Expanded(
                              child: HazeFace(
                                state: const RobotFaceState(
                                  lookTarget: Offset.zero,
                                ),
                                look: HazeLook(
                                  style: style,
                                  accessory: accessory,
                                ),
                                framed: false,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/haze_plus_cosmetics.png'),
      );
    },
  );
}
