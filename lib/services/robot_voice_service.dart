import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:record/record.dart';

import 'tiny_companion_voice.dart';

/// Where Haze's ears/voice are in the mimic flow.
enum MimicStatus { idle, listening, replaying }

/// How a clip is flavored before it leaves the speaker.
enum VoicePreset { natural, robot, chipmunk, deep }

/// One pipe for everything Haze says out loud: TTS clips and mimicked
/// recordings both play through SoLoud so they can share the same funny-voice
/// filters, and so the real amplitude can drive the mouth and waveform.
///
/// [level] ticks 0..1 while audio is being captured or played; [levelHistory]
/// keeps a short rolling window of it for the waveform widget.
class RobotVoiceService {
  static const _audioTools = MethodChannel('haze_bot_app/audio_tools');
  static const _sampleRate = 22050;
  static const _envelopeWindowMs = 30;
  static const _silenceStopAfter = Duration(milliseconds: 1100);
  static const _maxRecording = Duration(seconds: 12);
  static const historyLength = 48;

  final ValueNotifier<double> level = ValueNotifier(0);
  final List<double> levelHistory = List.filled(
    historyLength,
    0,
    growable: true,
  );

  // Lazy: AudioRecorder() fires a platform `create` call from its
  // constructor, so building it eagerly would hit the (absent) plugin in
  // widget tests — and ask the OS for a recorder nobody may ever use.
  AudioRecorder? _recorder;
  bool _engineReady = false;
  bool _engineUnavailable = false;
  int _clipCounter = 0;

  StreamSubscription<Uint8List>? _micSubscription;
  BytesBuilder? _micBytes;
  Completer<Uint8List?>? _capture;
  Timer? _recordingCap;
  DateTime? _lastLoudAt;
  bool _heardSpeech = false;

  Timer? _playbackTicker;
  SoundHandle? _playingHandle;
  AudioSource? _playingSource;
  Completer<void>? _playbackDone;
  int _playbackRequest = 0;
  bool _disposed = false;

  /// TTS-through-SoLoud needs `synthesizeToFile`. Android writes PCM WAV.
  /// iOS can write float WAV, so we normalize it before handing it to SoLoud.
  bool get isTtsCaptureSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<bool> _ensureEngine() async {
    if (_engineReady) return true;
    if (_engineUnavailable) return false;
    try {
      await SoLoud.instance.init();
      _engineReady = true;
      return true;
    } catch (e) {
      _engineUnavailable = true;
      debugPrint('RobotVoice: SoLoud unavailable, using platform audio: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------- capture

  /// Starts listening on the mic. Returns false when permission is denied.
  /// The recording ends on its own after ~1s of silence (or [stopListening]),
  /// and [onCaptured] completes with WAV bytes ready to replay.
  Future<bool> startListening() async {
    if (_micSubscription != null) return true;
    try {
      final recorder = _recorder ??= AudioRecorder();
      if (!await recorder.hasPermission()) return false;
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      _micBytes = BytesBuilder(copy: false);
      _capture = Completer<Uint8List?>();
      _heardSpeech = false;
      _lastLoudAt = null;
      _recordingCap = Timer(_maxRecording, () => stopListening());
      _micSubscription = stream.listen(
        _onMicChunk,
        onError: (Object e) {
          debugPrint('RobotVoice: mic stream error: $e');
          stopListening(cancel: true);
        },
        onDone: () {
          // Recorder ended on its own (route change etc.) — deliver whatever
          // audio we already collected instead of hanging the capture future.
          if (_micSubscription != null) stopListening();
        },
      );
      return true;
    } catch (e) {
      debugPrint('RobotVoice: failed to start listening: $e');
      await stopListening(cancel: true);
      return false;
    }
  }

  /// Completes with the finished recording, or null when it was cancelled or
  /// nothing loud enough was heard.
  Future<Uint8List?> get onCaptured => _capture?.future ?? Future.value(null);

  Future<void> stopListening({bool cancel = false}) async {
    final subscription = _micSubscription;
    if (subscription == null) return;
    _micSubscription = null;
    _recordingCap?.cancel();
    _recordingCap = null;
    await subscription.cancel();
    try {
      await _recorder?.stop();
    } catch (e) {
      debugPrint('RobotVoice: recorder stop failed: $e');
    }
    level.value = 0;
    final pcm = _micBytes?.takeBytes();
    _micBytes = null;
    final capture = _capture;
    _capture = null;
    if (capture == null || capture.isCompleted) return;
    // A recording that never rose above the noise floor is a misfire (pocket
    // tap, room hum) — treat it like a cancel so Haze doesn't parrot silence.
    if (cancel || pcm == null || pcm.isEmpty || !_heardSpeech) {
      capture.complete(null);
    } else {
      capture.complete(_pcm16ToWav(pcm, _sampleRate));
    }
  }

  void _onMicChunk(Uint8List chunk) {
    _micBytes?.add(chunk);
    final rms = _rmsOfPcm16(chunk);
    _pushLevel((rms * 14).clamp(0.0, 1.0));
    const speechFloor = 0.012;
    final now = DateTime.now();
    if (rms > speechFloor) {
      _heardSpeech = true;
      _lastLoudAt = now;
    } else if (_heardSpeech &&
        _lastLoudAt != null &&
        now.difference(_lastLoudAt!) > _silenceStopAfter) {
      stopListening();
    }
  }

  // --------------------------------------------------------------- playback

  /// Plays WAV bytes through the funny-voice pipe. Resolves when the clip
  /// finishes (or is stopped). Returns false when the engine refused the clip.
  Future<bool> playWavBytes(Uint8List wav, {required VoicePreset preset}) =>
      _play(
        loadPath: null,
        wavBytes: wav,
        preset: preset,
        request: ++_playbackRequest,
      );

  /// Same pipe, for clips flutter_tts already wrote to disk.
  Future<bool> playWavFile(String path, {required VoicePreset preset}) async {
    final request = ++_playbackRequest;
    String? convertedPath;
    var loadName = path;
    try {
      final bytes = await File(path).readAsBytes();
      var wav = _wavForSoLoud(bytes);
      if (wav == null && !kIsWeb && Platform.isIOS) {
        convertedPath = '$path.pcm.wav';
        final result = await _audioTools.invokeMethod<int>('convertToPcmWav', {
          'inputPath': path,
          'outputPath': convertedPath,
        });
        if (result == 1) {
          wav = _wavForSoLoud(await File(convertedPath).readAsBytes());
          loadName = convertedPath;
        }
      }
      if (wav == null) {
        debugPrint(
          'RobotVoice: synthesized audio is not a supported WAV; falling back',
        );
        return false;
      }
      if (_disposed || request != _playbackRequest) return true;
      return await _play(
        loadPath: loadName,
        wavBytes: wav,
        preset: preset,
        request: request,
      );
    } catch (e) {
      debugPrint('RobotVoice: failed to read $path: $e');
      return false;
    } finally {
      if (convertedPath != null) File(convertedPath).delete().ignore();
    }
  }

  Future<bool> _play({
    required String? loadPath,
    required Uint8List wavBytes,
    required VoicePreset preset,
    required int request,
  }) async {
    bool current() => !_disposed && request == _playbackRequest;
    try {
      await _stopPlayback();
      if (!current()) return true;
      if (!await _ensureEngine()) return false;
      if (!current()) return true;

      final playbackBytes = preset == VoicePreset.robot
          ? await compute(renderCompanionWav, wavBytes)
          : wavBytes;
      if (!current()) return true;
      final envelope = _envelopeFromWav(playbackBytes);
      final source = await SoLoud.instance.loadMem(
        loadPath ?? 'haze_clip_${_clipCounter++}.wav',
        playbackBytes,
      );
      if (!current()) {
        await SoLoud.instance.disposeSource(source);
        return true;
      }
      _playingSource = source;

      final handle = SoLoud.instance.play(source);
      _playingHandle = handle;
      switch (preset) {
        case VoicePreset.robot:
          debugPrint('RobotVoice: playing with Tiny Companion voice');
          break;
        case VoicePreset.chipmunk:
          SoLoud.instance.setRelativePlaySpeed(handle, 1.45);
          break;
        case VoicePreset.deep:
          SoLoud.instance.setRelativePlaySpeed(handle, 0.72);
          break;
        case VoicePreset.natural:
          break;
      }

      final done = Completer<void>();
      _playbackDone = done;
      _playbackTicker = Timer.periodic(
        const Duration(milliseconds: _envelopeWindowMs),
        (_) {
          if (!current() || !SoLoud.instance.getIsValidVoiceHandle(handle)) {
            if (!done.isCompleted) done.complete();
            return;
          }
          final position = SoLoud.instance.getPosition(handle);
          final index = position.inMilliseconds ~/ _envelopeWindowMs;
          _pushLevel(index < envelope.length ? envelope[index] : 0);
        },
      );
      await done.future;
      if (current()) await _stopPlayback();
      return true;
    } catch (e) {
      debugPrint('RobotVoice: playback failed: $e');
      if (!current()) return true;
      await _stopPlayback();
      return false;
    }
  }

  Future<void> stopPlayback() async {
    _playbackRequest++;
    await _stopPlayback();
  }

  Future<void> _stopPlayback() async {
    _playbackTicker?.cancel();
    _playbackTicker = null;
    final done = _playbackDone;
    _playbackDone = null;
    if (done != null && !done.isCompleted) done.complete();
    final handle = _playingHandle;
    _playingHandle = null;
    final source = _playingSource;
    _playingSource = null;
    level.value = 0;
    if (!_engineReady) return;
    try {
      if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
        await SoLoud.instance.stop(handle);
      }
      if (source != null) {
        await SoLoud.instance.disposeSource(source);
      }
    } catch (e) {
      debugPrint('RobotVoice: stopPlayback failed: $e');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stopListening(cancel: true);
    await stopPlayback();
    try {
      await _recorder?.dispose();
    } catch (e) {
      debugPrint('RobotVoice: recorder dispose failed: $e');
    }
    level.dispose();
  }

  // ------------------------------------------------------------------ audio

  void _pushLevel(double value) {
    // Fast attack, gentle release: the mouth snaps open on a syllable but
    // eases shut, which reads far more natural than raw 30ms RMS steps.
    final smoothed = value > level.value
        ? value
        : level.value * 0.55 + value * 0.45;
    level.value = smoothed;
    levelHistory.add(smoothed);
    if (levelHistory.length > historyLength) levelHistory.removeAt(0);
  }

  static double _rmsOfPcm16(Uint8List bytes) {
    final samples = bytes.buffer.asByteData(bytes.offsetInBytes, bytes.length);
    final count = bytes.length ~/ 2;
    if (count == 0) return 0;
    var sum = 0.0;
    for (var i = 0; i < count; i++) {
      final s = samples.getInt16(i * 2, Endian.little) / 32768.0;
      sum += s * s;
    }
    return math.sqrt(sum / count);
  }

  static Uint8List? _wavForSoLoud(Uint8List bytes) {
    final info = _wavInfo(bytes);
    if (info == null) return null;
    if (info.audioFormat == 1 &&
        (info.bitsPerSample == 8 || info.bitsPerSample == 16)) {
      return bytes;
    }
    if (info.isFloat && info.bitsPerSample == 32) {
      return _floatWavToPcm16Wav(bytes, info);
    }
    return null;
  }

  static Uint8List _pcm16ToWav(
    Uint8List pcm,
    int sampleRate, {
    int channels = 1,
  }) {
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final header = ByteData(44);
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    ascii(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);
    final wav = Uint8List(44 + pcm.length);
    wav.setAll(0, header.buffer.asUint8List());
    wav.setAll(44, pcm);
    return wav;
  }

  static Uint8List? _floatWavToPcm16Wav(Uint8List wav, _WavInfo info) {
    final data = ByteData.sublistView(wav);
    final bytesPerSample = info.bitsPerSample ~/ 8;
    final frameBytes = bytesPerSample * info.channels;
    if (frameBytes == 0) return null;
    final totalFrames = info.dataLength ~/ frameBytes;
    final pcm = Uint8List(totalFrames * info.channels * 2);
    final pcmData = ByteData.sublistView(pcm);
    for (var frame = 0; frame < totalFrames; frame++) {
      for (var channel = 0; channel < info.channels; channel++) {
        final inputOffset =
            info.dataStart + frame * frameBytes + channel * bytesPerSample;
        final sample = data.getFloat32(inputOffset, Endian.little);
        final clamped = sample.clamp(-1.0, 1.0);
        final int16 = clamped < 0 ? clamped * 32768 : clamped * 32767;
        pcmData.setInt16(
          (frame * info.channels + channel) * 2,
          int16.round(),
          Endian.little,
        );
      }
    }
    return _pcm16ToWav(pcm, info.sampleRate, channels: info.channels);
  }

  /// Renders a PCM WAV with the companion treatment, including WAV decoding.
  /// Exposed for offline auditions and verification of the actual audio path.
  static Uint8List renderCompanionWav(Uint8List wav) {
    final info = _wavInfo(wav);
    if (info == null ||
        info.audioFormat != 1 ||
        (info.bitsPerSample != 8 && info.bitsPerSample != 16) ||
        info.channels < 1 ||
        info.sampleRate < 8000) {
      return wav;
    }
    final clock = Stopwatch()..start();
    final data = ByteData.sublistView(wav);
    final bytesPerSample = info.bitsPerSample ~/ 8;
    final frameBytes = bytesPerSample * info.channels;
    final count = info.dataLength ~/ frameBytes;
    final mono = Float64List(count);
    for (var frame = 0; frame < count; frame++) {
      for (var channel = 0; channel < info.channels; channel++) {
        final offset =
            info.dataStart + frame * frameBytes + channel * bytesPerSample;
        mono[frame] += info.bitsPerSample == 16
            ? data.getInt16(offset, Endian.little) / 32768
            : (data.getUint8(offset) - 128) / 128;
      }
      mono[frame] /= info.channels;
    }
    final processed = TinyCompanionVoice.process(mono, info.sampleRate);
    final pcm = Uint8List(processed.length * 2);
    final encoded = ByteData.sublistView(pcm);
    for (var i = 0; i < processed.length; i++) {
      encoded.setInt16(
        i * 2,
        (processed[i] * 32767).round().clamp(-32768, 32767),
        Endian.little,
      );
    }
    debugPrint(
      'Tiny Companion: processed ${count / info.sampleRate}s in ${clock.elapsedMilliseconds}ms',
    );
    return _pcm16ToWav(pcm, info.sampleRate);
  }

  static _WavInfo? _wavInfo(Uint8List wav) {
    if (wav.length < 44) return null;
    final data = ByteData.sublistView(wav);
    if (data.getUint32(0, Endian.big) != 0x52494646 || // RIFF
        data.getUint32(8, Endian.big) != 0x57415645) {
      // WAVE
      return null;
    }

    var offset = 12;
    int? audioFormat;
    var channels = 1;
    var sampleRate = _sampleRate;
    var bitsPerSample = 16;
    var isExtensibleFloat = false;
    int? dataStart;
    int? dataLength;

    while (offset + 8 <= wav.length) {
      final chunkId = data.getUint32(offset, Endian.big);
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final chunkStart = offset + 8;
      if (chunkStart + chunkSize > wav.length) return null;

      if (chunkId == 0x666d7420 && chunkSize >= 16) {
        // fmt
        audioFormat = data.getUint16(chunkStart, Endian.little);
        channels = data.getUint16(chunkStart + 2, Endian.little);
        sampleRate = data.getUint32(chunkStart + 4, Endian.little);
        bitsPerSample = data.getUint16(chunkStart + 14, Endian.little);
        if (audioFormat == 0xfffe && chunkSize >= 40) {
          // WAVE_FORMAT_EXTENSIBLE stores the real format in the subformat GUID.
          isExtensibleFloat =
              data.getUint32(chunkStart + 24, Endian.little) == 3;
        }
      } else if (chunkId == 0x64617461) {
        // data
        dataStart = chunkStart;
        dataLength = chunkSize;
      }

      offset += 8 + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (audioFormat == null || dataStart == null || dataLength == null) {
      return null;
    }
    return _WavInfo(
      audioFormat: audioFormat,
      channels: channels,
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      dataStart: dataStart,
      dataLength: math.min(dataLength, wav.length - dataStart),
      isFloat: audioFormat == 3 || isExtensibleFloat,
    );
  }

  /// RMS loudness per [_envelopeWindowMs] window, peak-normalized so quiet
  /// recordings still open the mouth. Handles the two WAV flavors we meet:
  /// PCM16 (Android TTS, our mic) and float32 (iOS AVAudioFile).
  static List<double> _envelopeFromWav(Uint8List wav) {
    try {
      final data = ByteData.sublistView(wav);
      var offset = 12; // past RIFF....WAVE
      int? audioFormat;
      int channels = 1;
      int sampleRate = _sampleRate;
      int bitsPerSample = 16;
      int? dataStart;
      int? dataLength;
      while (offset + 8 <= wav.length) {
        final id = String.fromCharCodes(wav.sublist(offset, offset + 4));
        final size = data.getUint32(offset + 4, Endian.little);
        if (id == 'fmt ') {
          audioFormat = data.getUint16(offset + 8, Endian.little);
          channels = data.getUint16(offset + 10, Endian.little);
          sampleRate = data.getUint32(offset + 12, Endian.little);
          bitsPerSample = data.getUint16(offset + 22, Endian.little);
        } else if (id == 'data') {
          dataStart = offset + 8;
          dataLength = math.min(size, wav.length - dataStart);
          break;
        }
        offset += 8 + size + (size.isOdd ? 1 : 0);
      }
      if (dataStart == null || dataLength == null || audioFormat == null) {
        return const [];
      }
      final bytesPerSample = bitsPerSample ~/ 8;
      final frameBytes = bytesPerSample * channels;
      final totalFrames = dataLength ~/ frameBytes;
      final framesPerWindow = math.max(
        1,
        sampleRate * _envelopeWindowMs ~/ 1000,
      );
      final isFloat = audioFormat == 3;

      final envelope = <double>[];
      var peak = 0.0;
      for (var start = 0; start < totalFrames; start += framesPerWindow) {
        final end = math.min(start + framesPerWindow, totalFrames);
        var sum = 0.0;
        for (var frame = start; frame < end; frame++) {
          final byteOffset = dataStart + frame * frameBytes;
          final double sample;
          if (isFloat && bitsPerSample == 32) {
            sample = data.getFloat32(byteOffset, Endian.little);
          } else if (bitsPerSample == 16) {
            sample = data.getInt16(byteOffset, Endian.little) / 32768.0;
          } else {
            return const [];
          }
          sum += sample * sample;
        }
        final rms = math.sqrt(sum / (end - start));
        peak = math.max(peak, rms);
        envelope.add(rms);
      }
      if (peak > 0) {
        for (var i = 0; i < envelope.length; i++) {
          envelope[i] = (envelope[i] / peak).clamp(0.0, 1.0);
        }
      }
      return envelope;
    } catch (e) {
      debugPrint('RobotVoice: envelope parse failed: $e');
      return const [];
    }
  }
}

class _WavInfo {
  final int audioFormat;
  final int channels;
  final int sampleRate;
  final int bitsPerSample;
  final int dataStart;
  final int dataLength;
  final bool isFloat;

  const _WavInfo({
    required this.audioFormat,
    required this.channels,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.dataStart,
    required this.dataLength,
    required this.isFloat,
  });
}
