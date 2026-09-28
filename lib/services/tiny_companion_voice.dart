import 'dart:math' as math;
import 'dart:typed_data';

/// Portable version of the approved Tiny Companion sound sketch.
/// Raises pitch 2.5 semitones without shortening speech, then mixes a quiet
/// synthetic carrier into the speech envelopes. Run outside the UI isolate.
class TinyCompanionVoice {
  static const semitones = 2.5;
  static const syntheticMix = .12;

  static Float64List process(Float64List input, int sampleRate) {
    if (input.isEmpty || sampleRate < 8000) return input;
    final speech = _raisePitch(input, sampleRate);
    final high = math.min(7400.0, sampleRate * .43);
    final highPass = _Biquad.highPass(110, sampleRate);
    final lowPass = _Biquad.lowPass(high, sampleRate);
    for (var i = 0; i < speech.length; i++) {
      speech[i] = lowPass.next(highPass.next(speech[i]));
    }

    final carrier = Float64List(speech.length);
    final noise = Float64List(speech.length);
    var phase = 0.0;
    var random = 20260927;
    const frequency = 235.0;
    final step = frequency / sampleRate;
    for (var i = 0; i < speech.length; i++) {
      // Band-limited sawtooth: a steady, small electronic presence.
      var value = 2 * phase - 1;
      if (phase < step) {
        final t = phase / step;
        value -= 2 * t - t * t - 1;
      } else if (phase > 1 - step) {
        final t = (phase - 1) / step;
        value -= t * t + 2 * t + 1;
      }
      carrier[i] = value;
      phase = (phase + step) % 1;
      random = (1664525 * random + 1013904223) & 0xffffffff;
      noise[i] = random / 2147483648 - 1;
    }

    final synthetic = Float64List(speech.length);
    final attack = math.exp(-1 / (sampleRate * .006));
    final release = math.exp(-1 / (sampleRate * .025));
    for (var band = 0; band < 32; band++) {
      final lower = 110 * math.pow(high / 110, band / 32);
      final upper = 110 * math.pow(high / 110, (band + 1) / 32);
      final center = math.sqrt(lower * upper);
      final q = center / (upper - lower);
      final analysis = _Biquad.bandPass(center, q, sampleRate);
      final toneFilter = _Biquad.bandPass(center, q, sampleRate);
      final noiseFilter = _Biquad.bandPass(center, q, sampleRate);
      final tone = Float64List(speech.length);
      var toneEnergy = 0.0;
      final noiseMix = ((center - 2200) / 4000).clamp(.02, .9);
      for (var i = 0; i < speech.length; i++) {
        tone[i] =
            math.sqrt(1 - noiseMix) * toneFilter.next(carrier[i]) +
            math.sqrt(noiseMix) * noiseFilter.next(noise[i]);
        toneEnergy += tone[i] * tone[i];
      }
      final carrierRms = math.sqrt(toneEnergy / speech.length);
      if (carrierRms < 1e-9) continue;
      var envelope = 0.0;
      for (var i = 0; i < speech.length; i++) {
        final sample = analysis.next(speech[i]);
        final power = sample * sample;
        final smoothing = power > envelope ? attack : release;
        envelope = smoothing * envelope + (1 - smoothing) * power;
        synthetic[i] += math.sqrt(envelope) * tone[i] / carrierRms;
      }
    }

    var dryEnergy = 0.0;
    var wetEnergy = 0.0;
    for (var i = 0; i < speech.length; i++) {
      dryEnergy += speech[i] * speech[i];
      wetEnergy += synthetic[i] * synthetic[i];
    }
    final balance = wetEnergy > 1e-12 ? math.sqrt(dryEnergy / wetEnergy) : 0.0;
    var peak = 0.0;
    final fade = math.min(sampleRate ~/ 100, speech.length ~/ 2);
    for (var i = 0; i < speech.length; i++) {
      speech[i] =
          (1 - syntheticMix) * speech[i] +
          syntheticMix * balance * synthetic[i];
      if (fade > 0) {
        speech[i] *= math.min(1.0, math.min(i, speech.length - 1 - i) / fade);
      }
      peak = math.max(peak, speech[i].abs());
    }
    // Headroom without boosting the noise floor of quiet recordings.
    if (peak > .85) {
      for (var i = 0; i < speech.length; i++) {
        speech[i] *= .85 / peak;
      }
    }
    return speech;
  }

  static Float64List _raisePitch(Float64List input, int sampleRate) {
    final ratio = math.pow(2, semitones / 12);
    final short = Float64List((input.length / ratio).ceil());
    for (var i = 0; i < short.length; i++) {
      final position = i * ratio;
      final left = position.floor();
      final right = math.min(left + 1, input.length - 1);
      short[i] = input[left] + (input[right] - input[left]) * (position - left);
    }
    // Waveform-similarity overlap-add restores the original sentence duration.
    final hop = math.max(16, (sampleRate * .02).round());
    final window = hop * 2;
    final search = (sampleRate * .008).round();
    final output = Float64List(input.length + window);
    final weights = Float64List(output.length);
    final hann = List<double>.generate(
      window,
      (i) => .5 - .5 * math.cos(2 * math.pi * i / window),
    );
    double sample(int index) =>
        index >= 0 && index < short.length ? short[index] : 0;
    for (var destination = 0; destination < input.length; destination += hop) {
      final expected = (destination / ratio).round();
      var chosen = expected;
      if (destination > 0) {
        var best = -double.infinity;
        final start = math.max(0, expected - search);
        final end = math.min(short.length - 1, expected + search);
        double score(int candidate) {
          var dot = 0.0;
          var energy = 1e-12;
          for (var j = 0; j < hop; j += 4) {
            final weight = weights[destination + j];
            final previous = weight > 1e-6
                ? output[destination + j] / weight
                : 0.0;
            final next = sample(candidate + j);
            dot += previous * next;
            energy += next * next;
          }
          return dot / math.sqrt(energy);
        }

        for (var candidate = start; candidate <= end; candidate += 4) {
          final similarity = score(candidate);
          if (similarity > best) {
            best = similarity;
            chosen = candidate;
          }
        }
        final coarse = chosen;
        for (
          var candidate = math.max(start, coarse - 3);
          candidate <= math.min(end, coarse + 3);
          candidate++
        ) {
          final similarity = score(candidate);
          if (similarity > best) {
            best = similarity;
            chosen = candidate;
          }
        }
      }
      for (var j = 0; j < window; j++) {
        output[destination + j] += sample(chosen + j) * hann[j];
        weights[destination + j] += hann[j];
      }
    }
    return Float64List.fromList(
      List<double>.generate(
        input.length,
        (i) => weights[i] > 1e-6 ? output[i] / weights[i] : 0,
      ),
    );
  }
}

class _Biquad {
  final double b0, b1, b2, a1, a2;
  double z1 = 0, z2 = 0;
  _Biquad(this.b0, this.b1, this.b2, this.a1, this.a2);

  factory _Biquad.bandPass(double frequency, double q, int rate) {
    final w = 2 * math.pi * frequency / rate;
    final alpha = math.sin(w) / (2 * q);
    final a0 = 1 + alpha;
    return _Biquad(
      alpha / a0,
      0,
      -alpha / a0,
      -2 * math.cos(w) / a0,
      (1 - alpha) / a0,
    );
  }

  factory _Biquad.lowPass(double frequency, int rate) =>
      _Biquad.cut(frequency, rate, false);
  factory _Biquad.highPass(double frequency, int rate) =>
      _Biquad.cut(frequency, rate, true);
  factory _Biquad.cut(double frequency, int rate, bool high) {
    final w = 2 * math.pi * frequency / rate;
    final c = math.cos(w);
    final alpha = math.sin(w) / math.sqrt(2);
    final a0 = 1 + alpha;
    final sign = high ? 1 : -1;
    final b0 = (1 + sign * c) / 2;
    return _Biquad(
      b0 / a0,
      -sign * 2 * b0 / a0,
      b0 / a0,
      -2 * c / a0,
      (1 - alpha) / a0,
    );
  }

  double next(double input) {
    final output = b0 * input + z1;
    z1 = b1 * input - a1 * output + z2;
    z2 = b2 * input - a2 * output;
    return output;
  }
}
