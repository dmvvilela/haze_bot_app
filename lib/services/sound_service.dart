import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haze's chirps. Synthesized WAVs in assets/sounds/ — regenerate with
/// `python3 tool/generate_sounds.py`. See assets/sounds/README.md for the
/// catalog and guidelines on when to use each.
enum HazeSound {
  poke,
  correct,
  wrong,
  win,
  hello,
  sing,
  laugh,
  curious,
  sad,
  sleep,
  chime,
  startup,
  proud,
}

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
  bool _unavailable = false;

  Future<void> play(HazeSound sound) async {
    if (!enabled || _unavailable) return;
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
      // A MissingPluginException means the native side isn't registered
      // (fresh plugin without a full rebuild): go quiet instead of retrying.
      if (e is MissingPluginException) _unavailable = true;
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
