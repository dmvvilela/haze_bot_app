import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Haze's chirps. Synthesized WAVs in assets/sounds/ — regenerate with
/// `python3 tool/generate_sounds.py`.
enum HazeSound { poke, correct, wrong, win, hello }

extension on HazeSound {
  String get asset => 'sounds/$name.wav';
}

/// Plays short UI chirps. A small pool of players so quick sounds (poke,
/// game answers) can overlap instead of cutting each other off.
class SoundService {
  static const _poolSize = 3;

  final List<AudioPlayer> _players = [];
  int _next = 0;
  bool enabled = true;

  Future<void> play(HazeSound sound) async {
    if (!enabled) return;
    try {
      if (_players.isEmpty) {
        for (var i = 0; i < _poolSize; i++) {
          final player = AudioPlayer();
          await player.setPlayerMode(PlayerMode.lowLatency);
          _players.add(player);
        }
      }
      final player = _players[_next];
      _next = (_next + 1) % _players.length;
      await player.stop();
      await player.play(AssetSource(sound.asset));
    } catch (e) {
      // Sounds are decoration — never let a missing codec/asset break the app.
      debugPrint('SoundService: failed to play ${sound.name}: $e');
    }
  }

  Future<void> dispose() async {
    for (final player in _players) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}
