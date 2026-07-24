import 'chemicals.dart';

/// Cross-chemical couplings, run after decay each sub-step.
///
/// Every term is gated on a chemical's *excess above its own baseline*, so
/// the all-baseline resting state is a true fixed point: at rest nothing
/// drifts. (Constant pushes toward 0 or 1 would overwhelm the slow decays
/// and pin chemicals at their extremes — see kindalive's history note.)

// Interaction coefficients (per second, before the seed's interactionScale).
const double kCortisolSerotonin = 0.03; // excess cortisol erodes serotonin
const double kGabaAdrenaline = 0.15; // GABA damps adrenaline's excess
const double kTestosteroneAdrenaline = 0.015; // drive fuels arousal
const double kAdrenalineGaba = 0.30; // arousal inhibits GABA toward a floor
const double kOxytocinCortisol = 0.30; // bonding eases stress

/// Adrenaline may only chew GABA down to this fraction of its baseline; the
/// remainder keeps damping adrenaline, so arousal can never fully strip its
/// own brake and run away.
const double gabaInhibitionFloorFrac = 0.5;

/// Baseline-drift thresholds. Drift-down sits below the resting cortisol
/// baseline so it only fires during genuinely sustained low-stress recovery.
const double cortisolDriftUpThreshold = 0.7;
const double cortisolDriftDownThreshold = 0.15;

void applyInteractions(ChemicalState state, double dt, {double scale = 1.0}) {
  // Snapshot before mutating so the rules are order-independent.
  final cortisol = state.get(Chemical.cortisol);
  final serotonin = state.get(Chemical.serotonin);
  final gaba = state.get(Chemical.gaba);
  final adrenaline = state.get(Chemical.adrenaline);
  final testosterone = state.get(Chemical.testosterone);
  final oxytocin = state.get(Chemical.oxytocin);

  double excess(double level, Chemical chem) =>
      (level - state.baseline(chem)).clamp(0.0, 1.0);

  final cortisolExcess = excess(cortisol, Chemical.cortisol);
  final adrenalineExcess = excess(adrenaline, Chemical.adrenaline);
  final testosteroneExcess = excess(testosterone, Chemical.testosterone);
  final gabaFloor = gabaInhibitionFloorFrac * state.baseline(Chemical.gaba);

  final dSerotonin = -cortisolExcess * kCortisolSerotonin * scale * dt;
  final dAdrenaline = -gaba * kGabaAdrenaline * adrenalineExcess * scale * dt +
      testosteroneExcess * kTestosteroneAdrenaline * scale * dt;
  final dGaba = -adrenalineExcess *
      kAdrenalineGaba *
      (gaba - gabaFloor).clamp(0.0, 1.0) *
      scale *
      dt;
  final dCortisol = -oxytocin * kOxytocinCortisol * cortisolExcess * scale * dt;

  state.set(Chemical.serotonin, serotonin + dSerotonin);
  state.set(Chemical.adrenaline, adrenaline + dAdrenaline);
  state.set(Chemical.gaba, gaba + dGaba);
  state.set(Chemical.cortisol, cortisol + dCortisol);

  // Chronic stress slowly raises the cortisol baseline; sustained calm
  // lowers it again. Both auto-clamped to the drift band.
  if (cortisol > cortisolDriftUpThreshold) {
    state.setBaseline(
      Chemical.cortisol,
      state.baseline(Chemical.cortisol) + 0.001 * dt,
    );
  }
  if (cortisol < cortisolDriftDownThreshold) {
    state.setBaseline(
      Chemical.cortisol,
      state.baseline(Chemical.cortisol) - 0.0005 * dt,
    );
  }
}
