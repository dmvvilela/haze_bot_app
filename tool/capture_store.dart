// Reproducible captures of production widgets, without downloading an AI model.
// flutter test tool/capture_store.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/feelings_game_cubit.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/main.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/theme/haze_theme.dart';
import 'package:haze_bot_app/widgets/feelings_game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture localized store campaign', (tester) async {
    await tester.runAsync(() async {
      final sdk =
          Platform.environment['FLUTTER_ROOT'] ??
          '/Users/danvilela/Code/Misc/flutter';
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              await File(
                '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytes(),
            ),
          ),
        );
      await icons.load();
      for (final family in [
        'Roboto',
        '.AppleSystemUIFont',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
        '.SF UI Text',
        '.SF UI Display',
        '.SF Pro Text',
        '.SF Pro Display',
      ]) {
        final loader = FontLoader(family);
        final path = family == 'Roboto'
            ? '$sdk/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf'
            : '/System/Library/Fonts/SFNS.ttf';
        loader.addFont(
          Future.value(ByteData.sublistView(await File(path).readAsBytes())),
        );
        await loader.load();
      }
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (_) async =>
              const StandardMessageCodec().encodeMessage(<Object?>[null]),
        );
    const captureKey = ValueKey('store-capture');
    Future<void> settle([int frames = 12]) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 80));
      }
    }

    for (final (device, size, ratio, platform) in [
      ('iphone', const Size(440, 956), 3.0, TargetPlatform.iOS),
      ('ipad', const Size(1032, 1376), 2.0, TargetPlatform.iOS),
      ('android', const Size(412, 892), 3.0, TargetPlatform.android),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      tester.view.physicalSize = size * ratio;
      tester.view.devicePixelRatio = ratio;
      for (final (locale, language) in [
        (AppLocale.en, 'en-US'),
        (AppLocale.pt, 'pt-BR'),
      ]) {
        // This file is a development-only flutter_test capture entrypoint.
        // ignore: invalid_use_of_visible_for_testing_member
        SharedPreferences.setMockInitialValues({});
        final robot = RobotFaceCubit();
        robot.sounds.enabled = false;
        robot.mood.setPaused(true);
        await settle(2);
        LocaleSettings.setLocaleSync(locale);
        robot.updateLanguage(language);
        Widget wrap(Widget child) => RepaintBoundary(
          key: captureKey,
          child: TranslationProvider(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: HazeTheme.of(true),
              home: BlocProvider.value(value: robot, child: child),
            ),
          ),
        );
        Future<void> shot(String name) async {
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(captureKey),
          );
          // Custom theme TextStyles without a font use the OS fallback in the
          // app, but the widget-test engine substitutes Ahem square glyphs.
          // Resolve only that missing font here; preserve copy, styles, and
          // production layouts, including explicit icon font families.
          final systemFont = platform == TargetPlatform.iOS
              ? '.AppleSystemUIFont'
              : 'Roboto';
          InlineSpan resolveFont(InlineSpan span, String inherited) {
            if (span is! TextSpan) return span;
            final family = span.style?.fontFamily ?? inherited;
            return TextSpan(
              text: span.text,
              style: (span.style ?? const TextStyle()).copyWith(
                fontFamily: family,
              ),
              children: span.children
                  ?.map((child) => resolveFont(child, family))
                  .toList(),
              locale: span.locale,
              semanticsLabel: span.semanticsLabel,
            );
          }

          void resolveTree(RenderObject node) {
            if (node is RenderParagraph) {
              node.text = resolveFont(node.text, systemFont);
            }
            node.visitChildren(resolveTree);
          }

          resolveTree(boundary);
          await tester.pump();
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: ratio);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'release/marketing/aurea/raw/$language/$device/$name.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await tester.pumpWidget(wrap(const RobotFaceScreen()));
        robot.showExpression(RobotExpression.happy);
        await settle();
        await shot('01_companion');

        await tester.tap(find.text(t.home.lab));
        await settle();
        for (
          var i = 0;
          i < 40 && find.text(t.aurea.play).evaluate().isEmpty;
          i++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }
        await tester.ensureVisible(find.text(t.aurea.play));
        await tester.tap(find.text(t.aurea.play));
        await tester.pump();
        await tester.pump(const Duration(seconds: 6));
        await tester.tap(find.text(t.aurea.pause));
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
        await settle();
        await shot('02_aurea');

        await tester.pumpWidget(const SizedBox());
        final game = FeelingsGameCubit(robot, random: math.Random(7));
        await tester.pumpWidget(
          wrap(
            BlocProvider.value(value: game, child: const FeelingsGameScreen()),
          ),
        );
        await settle();
        await shot('03_play');
        await tester.pumpWidget(const SizedBox());
        await game.close();

        robot.showExpression(RobotExpression.happy);
        await tester.pumpWidget(wrap(const RobotFaceScreen()));
        robot.updateEyeColor(Colors.purple);
        robot.updateMouthColor(Colors.orange);
        robot.toggleTheme();
        await settle();
        await shot('05_yours');

        robot.updateEyeColor(Colors.cyan);
        robot.updateMouthColor(Colors.pink);
        robot.toggleTheme();
        robot.startTimer(25);
        await settle();
        await shot('04_focus');
        robot.stopTimer();
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(robot.close);
      }
    }
    tester.view.reset();
    debugDefaultTargetPlatformOverride = null;
  });
}
