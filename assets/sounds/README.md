# Haze's sound library

Every sound is **synthesized** by `tool/generate_sounds.py` — sine chirps with
pitch glides, vibrato, and soft envelopes (the R2D2 / Cozmo school of robot
voice). No licensed assets, no attribution needed. To change a sound, edit its
recipe in the script and re-run:

```bash
python3 tool/generate_sounds.py
```

Played through `SoundService` (`lib/services/sound_service.dart`) via the
`HazeSound` enum. Respects the "Sound effects" toggle in Settings.

## Catalog

| Sound | Feels like | Use it for | Currently wired to |
|---|---|---|---|
| `poke` | quick happy blip | acknowledging a touch | tapping the face |
| `correct` | "ding-ding!" | success, right answer | feelings game correct pick |
| `wrong` | soft double-boop | gentle "not quite" (never harsh) | feelings game wrong pick |
| `win` | rising arpeggio | milestones, celebrations | game streak of 5 |
| `hello` | R2D2 warble | greetings, session start | opening the feelings game |
| `sing` | little melody 🎵 | pure charm, easter eggs | long-pressing the face |
| `laugh` | staccato giggle | jokes, funny moments | *(free)* |
| `curious` | rising "hmm?" | discovering something new | *(free)* |
| `sad` | falling whimper | sad moments, goodbyes | *(free)* |
| `sleep` | descending purr | entering sleep mode, goodnight | *(free)* |
| `chime` | soft two-tone bell | timers, notifications | timer completion |
| `startup` | power-on sweep | app launch, waking up | *(free)* |

## Guidelines

- **Sounds confirm, they don't announce.** Play them in response to something
  the user (or a timer) did — never on a loop or on passive state changes,
  or the robot becomes a noisy toy.
- **Failure sounds must be softer than success sounds.** `wrong` is quiet and
  round on purpose — kids play the feelings game.
- **One sound per event.** If speech (TTS) will say something, a chirp right
  before it is fine; two chirps back-to-back is mush.
- **Keep new sounds under ~1.5s** (only `sing` gets to be long — it's a
  performance, not feedback).
- **Adding one:** add a recipe to `tool/generate_sounds.py`, re-run it, add
  the name to the `HazeSound` enum. The asset name must match the enum name.
