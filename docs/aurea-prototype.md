# Aurea in Haze Lab

Open **Haze Lab** from the home menu. It now opens the Aurea experiment;
**Original chemistry lab** at the bottom still opens the existing lab.

Three scenes explore compassion, courage and gratitude. Play, pause or scrub
Notice → Make sense of it → Choose a response. At a fixed timeline position,
change the interpretation or imagined prior experience to compare responses.
The explanation panel shows the ingredients used at that exact moment.

## Source and authored behavior

`assets/aurea/prototype.json` bundles the three ingredient lists from Aurea's
`src/data/compounds.json`. The source URL, snapshot date and SHA-256 of that
source file are recorded in the bundle. English and Portuguese scenario copy
are included. This is a reviewed snapshot, not a live website subscription.

The ingredient lists are Aurea's definitions. Numeric levels, timing, event
interpretations, practice scaling, the bottleneck rule, dialogue and expression
mappings are experimental choices made for Haze. They are not empirical
neurochemistry or validation of Aurea's claims. No chemical concentrations are
inferred from the user.

`AureaSimulation.sample` is a pure function of scenario, progress,
interpretation and practice. The event's initial signals stay constant across
interpretations. Appraisals develop next; values contribute to the action.
A compound's strength is the minimum of its necessary ingredients, so extra
joy cannot compensate for an absent appraisal. Practice strengthens enacted
values; it does not erase fear or sadness. First-time responses remain possible.

`AureaExpression` provides continuous warmth, sorrow, tension, openness,
activation, steadiness, approach and surprise. `HazeFace` translates these to
geometry and motion without checking compound names. Missing channels default
to zero. Existing emotion-based rendering remains the fallback outside Aurea.
The captions are authored scene dialogue, not generated conversation or speech.

## Boundaries

The imagined history selector is a counterfactual for this experiment. It does
not claim that Haze learned from replaying a scripted event. This screen never
writes companion mood, personality or conversation memory. Everything runs
offline, without an AI model download. Persistent learning and free-form event
interpretation are future work.

Adding a compound that uses existing ingredients/channels means adding its
source definition and a scenario to the bundle. New primitives require a
reviewed mapping and behavior checks; a source formula alone does not specify
a simulation. Keep approved source changes separate from authored dynamics.

## Validation and development

- `flutter test --no-pub test/aurea_model_test.dart test/aurea_screen_test.dart`
- `flutter run -t test_driver/preview.dart -d <simulator>` enables the Flutter
  test driver while launching the normal app. Production uses `lib/main.dart`.
- Existing chemistry/lab tests cover the retained experiment.
