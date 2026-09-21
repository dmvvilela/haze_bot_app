import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/widgets/aurea_lab_screen.dart';

void main() {
  for (final locale in [AppLocale.en, AppLocale.pt]) {
    testWidgets(
      'Aurea replay, comparison, explanation and reset in ${locale.name}',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        LocaleSettings.setLocale(locale);
        rootBundle.evict('assets/aurea/prototype.json');
        await tester.pumpWidget(
          TranslationProvider(child: MaterialApp(home: const AureaLabScreen())),
        );
        for (
          var attempt = 0;
          attempt < 30 && find.text(t.aurea.play).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () async => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump();
        }
        expect(
          find.text(t.aurea.play),
          findsOneWidget,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((w) => w.data)
              .join(' | '),
        );
        final play = find.text(t.aurea.play);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
        await tester.pump();
        await tester.tap(play);
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        expect(find.text(t.aurea.pause), findsOneWidget);
        await tester.tap(find.text(t.aurea.pause));
        await tester.pump();
        expect(find.text(t.aurea.resume), findsOneWidget);
        await tester.tap(find.text(t.aurea.resume));
        await tester.pump();
        await tester.pump(const Duration(seconds: 10));
        expect(find.text(t.aurea.replay), findsOneWidget);
        final original = tester
            .widget<Text>(find.byKey(const ValueKey('aurea-dialogue')))
            .data;
        final alternatives = find.byType(OutlinedButton);
        await Scrollable.ensureVisible(
          tester.element(alternatives.last),
          alignment: 1,
        );
        await tester.pump();
        await tester.tap(alternatives.last);
        await tester.pump();
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('aurea-dialogue')))
              .data,
          isNot(original),
        );
        await Scrollable.ensureVisible(
          tester.element(find.text(t.aurea.practiced)),
          alignment: 1,
        );
        await tester.pump();
        await tester.tap(find.text(t.aurea.practiced));
        await tester.pump();
        await Scrollable.ensureVisible(
          tester.element(find.text(t.aurea.why)),
          alignment: 1,
        );
        await tester.pump();
        await tester.tap(find.text(t.aurea.why));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text(t.aurea.incomplete), findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 1600));
        await tester.pump();
        await tester.tap(
          find.text(locale == AppLocale.en ? 'Courage' : 'Coragem'),
        );
        await tester.pump();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(t.aurea.reset));
        await tester.pump();
        expect(find.text(t.aurea.ready), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  for (final (size, scale) in [
    (const Size(320, 568), 1.0),
    (const Size(844, 390), 1.0),
    (const Size(390, 844), 2.0),
  ]) {
    testWidgets('Aurea readable at $size and text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      LocaleSettings.setLocale(AppLocale.pt);
      rootBundle.evict('assets/aurea/prototype.json');
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const AureaLabScreen(),
          ),
        ),
      );
      for (
        var i = 0;
        i < 30 && find.text(t.aurea.subtitle).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () async => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
      }
      expect(find.text(t.aurea.subtitle), findsOneWidget);
      for (
        var i = 0;
        i < 5 && find.text(t.aurea.play).evaluate().isEmpty;
        i++
      ) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pump();
      }
      expect(find.text(t.aurea.play), findsOneWidget);
      tester.widget<Slider>(find.byType(Slider)).onChanged!(1);
      await tester.pump();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
