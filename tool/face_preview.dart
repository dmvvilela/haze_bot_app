// Development-only preview of the production face; no AI download or mic access.
// flutter run -d web-server -t tool/face_preview.dart --web-port 8743
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/services/robot_voice_service.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const FacePreview(),
  ),
);

class FacePreview extends StatefulWidget {
  const FacePreview({super.key});
  @override
  State<FacePreview> createState() => _FacePreviewState();
}

class _FacePreviewState extends State<FacePreview> {
  final _level = ValueNotifier(0.0);
  Timer? _timer;
  double _time = 0;
  String _activity = 'Rest';
  String _mood = 'Warm';
  bool _reduced = false;
  bool _pause = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      _time += .03;
      final inPhrase = _time % 3 < 2.1;
      _level.value = _activity == 'Speak' && inPhrase && !_pause
          ? .15 + .7 * math.pow(math.sin(_time * 9), 2)
          : 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final affect = switch (_mood) {
      'Concerned' => const AureaExpression(
        sorrow: .8,
        warmth: .15,
        openness: .4,
      ),
      'Curious' => const AureaExpression(
        surprise: .7,
        openness: .9,
        activation: .6,
      ),
      _ => const AureaExpression(warmth: .9, openness: .5, activation: .4),
    };
    return Scaffold(
      backgroundColor: const Color(0xFF080C12),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Haze · Expression studio',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Production face · simulated speech levels · no audio',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                Expanded(
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(disableAnimations: _reduced),
                    child: HazeFace(
                      framed: false,
                      voiceLevel: _level,
                      affect: affect,
                      state: RobotFaceState(
                        isSpeaking: _activity == 'Speak',
                        isLoadingAI: _activity == 'Think',
                        mimicStatus: _activity == 'Listen'
                            ? MimicStatus.listening
                            : MimicStatus.idle,
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in ['Warm', 'Concerned', 'Curious'])
                      ChoiceChip(
                        label: Text(value),
                        selected: _mood == value,
                        onSelected: (_) => setState(() => _mood = value),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in ['Rest', 'Listen', 'Think', 'Speak'])
                      ChoiceChip(
                        label: Text(value),
                        selected: _activity == value,
                        onSelected: (_) => setState(() {
                          _activity = value;
                          _time = 0;
                          _level.value = 0;
                        }),
                      ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _pause = !_pause),
                      child: Text(
                        _pause ? 'Resume speech levels' : 'Hold silence',
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _reduced = !_reduced),
                      child: Text(
                        _reduced ? 'Reduce motion: on' : 'Reduce motion: off',
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Try Speak → Hold silence, then Listen → Think → Speak → Rest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
