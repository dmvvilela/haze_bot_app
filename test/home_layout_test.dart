import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/main.dart';
import 'package:haze_bot_app/theme/haze_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (_) async =>
              const StandardMessageCodec().encodeMessage(<Object?>[null]),
        );
  });
  for (final (size, scale, locale) in [
    (const Size(390, 844), 1.0, AppLocale.en),
    (const Size(320, 568), 1.0, AppLocale.pt),
    (const Size(844, 390), 1.0, AppLocale.en),
    (const Size(390, 844), 2.0, AppLocale.pt),
  ]) {
    testWidgets(
      'Home navigation and quiet mode at $size, $scale, ${locale.name}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        LocaleSettings.setLocaleSync(locale);
        final robot = RobotFaceCubit();
        robot.sounds.enabled = false;
        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: BlocProvider.value(
                value: robot,
                child: const RobotFaceScreen(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text(t.home.talk), findsOneWidget);
        expect(find.text(t.home.lab), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(t.home.hide));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(t.home.talk), findsNothing);
        expect(find.bySemanticsLabel('Haze face'), findsOneWidget);
        await tester.tap(find.byTooltip(t.home.show));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(t.home.talk), findsOneWidget);
        await tester.tap(find.byTooltip(t.home.more));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text(t.home.colors));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final palette = find.byType(AlertDialog);
        expect(
          Theme.of(tester.element(palette)).scaffoldBackgroundColor,
          HazeTheme.ink,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(t.home.done));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        robot.toggleTheme();
        await tester.pump();
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          isNull,
        );
        expect(
          Theme.of(
            tester.element(find.byType(Scaffold)),
          ).scaffoldBackgroundColor,
          HazeTheme.paper,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(robot.close);
      },
    );
  }

  testWidgets('Chat and active timer stay separate above the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocaleSync(AppLocale.en);
    final robot = RobotFaceCubit();
    robot.sounds.enabled = false;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: BlocProvider.value(
            value: robot,
            child: const RobotFaceScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    if (robot.state.config.speechEnabled) robot.toggleSpeech();
    robot.startTimer(5);
    robot.toggleChatComposer();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump(const Duration(milliseconds: 300));
    final input = find.byType(TextField);
    await tester.ensureVisible(input);
    await tester.pump();
    expect(tester.getRect(input).bottom, lessThanOrEqualTo(544));
    expect(
      tester.getRect(input).overlaps(tester.getRect(find.text('05:00'))),
      isFalse,
    );
    expect(tester.takeException(), isNull);
    robot.stopTimer();
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(robot.close);
  });
}
