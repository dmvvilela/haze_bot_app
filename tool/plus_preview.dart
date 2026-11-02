// Developer-only preview. No real checkout, SDK key, or purchase entitlement.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';
import 'package:haze_bot_app/services/haze_plus_controller.dart';
import 'package:haze_bot_app/services/haze_plus_store.dart';
import 'package:haze_bot_app/theme/haze_theme.dart';
import 'package:haze_bot_app/widgets/haze_plus_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = _PreviewStore();
  final controller = HazePlusController(store: store);
  await controller.initialize();
  runApp(
    TranslationProvider(
      child: _Preview(controller: controller, store: store),
    ),
  );
}

class _PreviewStore implements HazePlusStore {
  final _changes = StreamController<bool>.broadcast();
  bool owned = false;
  @override
  Stream<bool> get ownershipChanges => _changes.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> ownsPlus({bool refresh = false}) async => owned;
  @override
  Future<PlusOffer?> loadOffer() async => null;
  @override
  Future<bool> purchase() async => throw PlusStoreError.unavailable;
  @override
  Future<bool> restore() async => owned;
  void toggle() {
    owned = !owned;
    _changes.add(owned);
  }

  @override
  void dispose() => _changes.close();
}

class _Preview extends StatefulWidget {
  final HazePlusController controller;
  final _PreviewStore store;
  const _Preview({required this.controller, required this.store});
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  int _revision = 0;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: HazeTheme.of(true),
    builder: (context, child) => Column(
      children: [
        Material(
          color: const Color(0xFF342948),
          child: SafeArea(
            bottom: false,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Developer preview · no checkout',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    widget.store.toggle();
                    _revision++;
                  }),
                  child: Text(
                    widget.store.owned ? 'Preview locked' : 'Preview unlocked',
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    LocaleSettings.setLocaleSync(
                      LocaleSettings.currentLocale == AppLocale.en
                          ? AppLocale.pt
                          : AppLocale.en,
                    );
                  }),
                  child: const Text('EN / PT'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child!),
      ],
    ),
    home: HazePlusScreen(
      key: ValueKey(_revision),
      controller: widget.controller,
      faceState: const RobotFaceState(),
    ),
  );
}
