import 'chemicals.dart';

/// A discrete change to one chemical — the only way the world reaches the
/// engine. Instant when [durationSeconds] is 0, otherwise dripped in evenly
/// over that many seconds (a slow-burn feeling instead of a spike).
class ChemicalImpulse {
  final Chemical chemical;

  /// Signed magnitude; sensible events stay within about ±0.5.
  final double delta;
  final double durationSeconds;

  /// Same-source impulses inside a 5-minute window are dampened, so mashing
  /// one button can't ratchet a chemical to the ceiling.
  final String sourceId;

  const ChemicalImpulse(
    this.chemical,
    this.delta, {
    this.durationSeconds = 0,
    this.sourceId = '',
  });
}

/// Bookkeeping for a sustained impulse that is still dripping.
class ActiveSustainedImpulse {
  final ChemicalImpulse impulse;
  double remainingSeconds;
  final double ratePerSecond;

  ActiveSustainedImpulse(this.impulse)
      : remainingSeconds = impulse.durationSeconds,
        ratePerSecond = impulse.delta / impulse.durationSeconds;
}
