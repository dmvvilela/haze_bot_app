# Aurea conversation

The optional on-device language model now interprets a situation as bounded
observations (loss, threat, connection, benefit, uncertainty, agency, novelty).
It cannot set chemical doses or a face preset. AureaCompanion translates those
observations into the bundled lab catalog's ingredients, compound bottlenecks,
and continuous expression mappings. A second model pass receives that computed
state and writes the reply; voice cadence also follows the continuous state.

The numerical interpretation is authored Haze design, not a biological model or
an additional research claim. The current catalog covers compassion, courage,
and gratitude; this is an extensible first integration, not universal understanding.

State carries across messages in the current session and decays over minutes.
It is not a persistent conversation history. Explicit game/touch expressions and
the original controlled chemistry lab retain their own rendering behavior.

Without AI consent, the model never downloads. A limited English/Portuguese cue
matcher and contextual replies use the same state engine. Unknown messages get
a neutral invitation to continue. Malformed model output falls back locally.

The current Haze renderer is the only face. Legacy faceType JSON keys are ignored
on load; colors, language, voice, and the other settings are preserved.

Validation: haze_brain_test, aurea_conversation_test, face_migration_test,
widget_test, home_layout_test, and the lab and face regression tests.
Actual on-device model output quality/latency still needs a physical-device run.

Code generation uses the upgraded Freezed and Slang toolchain. Run
`dart run build_runner build` to regenerate both models and translations.
`build.yaml` is the shared Slang configuration, with synchronous locale loading.
