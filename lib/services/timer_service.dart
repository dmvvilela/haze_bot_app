import 'dart:async';

/// Countdown built around a wall-clock deadline rather than counted ticks, so
/// the remaining time stays correct even when the OS pauses timers (app
/// backgrounded, screen locked) and catches up on return.
class TimerService {
  Timer? _ticker;
  DateTime? _endsAt; // non-null while running
  int _remainingSeconds = 0;

  final StreamController<int> _timerController = StreamController<int>.broadcast();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  final StreamController<void> _completeController = StreamController<void>.broadcast();

  Stream<int> get timerStream => _timerController.stream;
  Stream<bool> get statusStream => _statusController.stream;
  Stream<void> get completeStream => _completeController.stream;

  bool get isRunning => _endsAt != null;
  int get remainingSeconds => _remainingSeconds;

  void startTimer(int minutes) {
    _cancelTicker();
    _remainingSeconds = minutes * 60;
    _endsAt = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _statusController.add(true);
    _timerController.add(_remainingSeconds);
    _startTicker();
  }

  void stopTimer() {
    _cancelTicker();
    _endsAt = null;
    _remainingSeconds = 0;
    _statusController.add(false);
    _timerController.add(0);
  }

  void pauseTimer() {
    if (_endsAt == null) return;
    _tick(); // capture the exact remaining time before freezing it
    _cancelTicker();
    _endsAt = null;
    _statusController.add(false);
  }

  void resumeTimer() {
    if (_endsAt != null || _remainingSeconds <= 0) return;
    _endsAt = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _statusController.add(true);
    _startTicker();
  }

  void _startTicker() {
    // Sub-second cadence so the displayed seconds never visibly skip.
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final endsAt = _endsAt;
    if (endsAt == null) return;
    final remainingMs = endsAt.difference(DateTime.now()).inMilliseconds;
    final seconds = remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
    if (seconds != _remainingSeconds) {
      _remainingSeconds = seconds;
      _timerController.add(seconds);
    }
    if (remainingMs <= 0) _complete();
  }

  void _complete() {
    _cancelTicker();
    _endsAt = null;
    _remainingSeconds = 0;
    _statusController.add(false);
    _timerController.add(0);
    _completeController.add(null);
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _cancelTicker();
    _timerController.close();
    _statusController.close();
    _completeController.close();
  }
}
