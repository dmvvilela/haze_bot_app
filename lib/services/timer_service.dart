import 'dart:async';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  final StreamController<int> _timerController = StreamController<int>.broadcast();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  final StreamController<void> _completeController = StreamController<void>.broadcast();

  Stream<int> get timerStream => _timerController.stream;
  Stream<bool> get statusStream => _statusController.stream;
  Stream<void> get completeStream => _completeController.stream;

  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;

  void startTimer(int minutes) {
    if (_isRunning) {
      stopTimer();
    }

    _remainingSeconds = minutes * 60;
    _isRunning = true;
    _statusController.add(true);
    _timerController.add(_remainingSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _timerController.add(_remainingSeconds);

      if (_remainingSeconds <= 0) {
        _completeTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = 0;
    _statusController.add(false);
    _timerController.add(0);
  }

  void pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      _statusController.add(false);
    }
  }

  void resumeTimer() {
    if (!_isRunning && _remainingSeconds > 0) {
      _isRunning = true;
      _statusController.add(true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingSeconds--;
        _timerController.add(_remainingSeconds);

        if (_remainingSeconds <= 0) {
          _completeTimer();
        }
      });
    }
  }

  void _completeTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
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
    _timer?.cancel();
    _timerController.close();
    _statusController.close();
    _completeController.close();
  }
}
