# Progress

## Current task

- Status: Complete
- Objective: Fix the runtime typed-array assignment error in the aiming ghost update.

## Completed

- Reconciled the specification, implementation design, current scene, utilities, and clean working tree.
- Fixed the implementation assumption at a 10×20 logical board, danger line `y = 18`, with the launcher outside the board.
- Implemented deterministic board, rigid projectile prediction, rectangle matching/union clears, all nine polyominoes, rotations, the seeded 7-piece size bag, NEXT 3, and orientation-preserving HOLD.
- Implemented a playable primitive-rendered scene with aiming ghost, wall kicks, repeated movement, projectile flight, pause, target descent, danger-line game over, score/quota HUD, and restart.
- Added six fixed waves, 70% target quotas, board resets between waves, over-clear score, stage clear, and increasing descent speed.
- Replaced the obsolete empty `Player.tscn`, documented controls and execution, and completed a full diff/refactoring pass.
- Replaced direct assignments to typed BoardView cell arrays with type-preserving `assign()` calls; the empty ghost case now uses `clear()`.

## Remaining

- Procedural solvable-wave generation, authored art/audio, tutorials, settings/rebinding UI, telemetry, and detailed target-shape score multipliers remain later production work.

## Important decisions and assumptions

- Runtime rules follow `資料/仕様/gd_quarthゲーム仕様.md` and structure follows `資料/仕様/Godot実装設計.md`.
- The first playable version uses fixed, verified wave layouts; procedural solvable-wave generation remains a later milestone per the design.
- Runtime visuals are drawn with Godot primitives so the prototype does not depend on missing art or audio assets.
- Target descent can occur during flight; the remaining projectile path is recalculated from its current logical anchor.

## Files changed

- `.agents/PROGRESS.md`
- `AGENTS.md`
- `README.md`
- `gd_quarth/gd-quarth/project.godot`
- `gd_quarth/gd-quarth/src/model/*.gd`
- `gd_quarth/gd-quarth/src/objects/BoardView.gd`
- `gd_quarth/gd-quarth/src/scenes/Game.gd`
- `gd_quarth/gd-quarth/src/scenes/Game.tscn`
- `gd_quarth/gd-quarth/src/scenes/Main.gd`
- `gd_quarth/gd-quarth/src/ui/PiecePreview.gd`
- `gd_quarth/gd-quarth/src/utils/Array2D.gd`
- `gd_quarth/gd-quarth/tests/model_test.gd`
- Removed `gd_quarth/gd-quarth/src/Player.tscn`.

## Verification

- Model suite passes: `/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --log-file /tmp/gd_quarth-tests.log --path gd_quarth/gd-quarth --script res://tests/model_test.gd`.
- Main scene runs for 180 frames headlessly without script/runtime errors using `--quit-after 180`.
- A dedicated runtime test advances through the intro into `AIMING`, calls the ghost update, and passes without typed-array assignment errors.
- `git diff --check` passes.
- Godot prints a sandbox-related macOS certificate lookup warning in headless mode; it does not affect parsing, tests, or runtime exit status.
