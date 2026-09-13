# Repository instructions

## Preserve useful project knowledge

- During every task, notice durable facts that would help future work in this repository, such as architecture decisions, non-obvious conventions, reliable commands, environment constraints, recurring pitfalls, and their verified solutions.
- Add such facts to this `AGENTS.md` automatically as soon as they are confirmed; do not wait for the user to ask.
- Keep additions concise, factual, and specific to this repository. Update or replace stale guidance instead of accumulating contradictory notes.
- Do not record secrets, credentials, personal data, transient debugging output, guesses, or information that is already obvious from the source tree.

## Store agent information

- Keep `AGENTS.md` at the repository root.
- Store all other agent instructions, working notes, plans, handoff records, progress files, and similar agent-specific information under the repository-root `.agents/` directory.
- Do not create agent-instruction or agent-state files elsewhere in the repository. If such a file already exists outside `.agents/`, move it into `.agents/` and update all references to it.
- This location rule does not apply to ordinary project documentation or user-facing artifacts that are part of the requested deliverable.

## Project identity and materials

- The project is named `gd_quarth` and is developed with Godot Engine. Treat `project.godot`, Godot scenes/resources, and GDScript as the authoritative project structure, and use Godot-compatible workflows and conventions.
- The game is a modern puzzle-shooter based on Konami's *Quarth*. Preserve shape- and position-based play that does not require color identification, while increasing meaningful decisions and reducing repetitive input after a solution is already understood.
- The initial gameplay specification is `資料/仕様/gd_quarthゲーム仕様.md`. Its current baseline uses rotatable 1–4 cell polyomino shots, three-piece NEXT plus one HOLD slot, rigid first-contact locking, outline-completed rectangle clearing, and short quota-based waves that reset the board.
- Store project-specific specifications, design references, research notes, and development/support tools under the repository-root `資料/` directory.
- Organize specifications and reference material under `資料/仕様/`, and repository-specific helper tools and scripts under `資料/ツール/`. Create these subdirectories when content of that type is first added.
- Keep runtime game source and assets in the Godot project rather than `資料/`; the `資料/` directory is for supporting material and tooling, not shipped game content.
- The Godot project root is `gd_quarth/gd-quarth/`; repository-level specifications remain under `資料/`.
- The current implementation baseline is documented in `資料/仕様/Godot実装設計.md`. Keep deterministic board rules under `src/model/`, rendering/input nodes under `src/objects/`, and use `Main.gd` only for high-level composition and scene flow.
- Godot is available at `/Applications/Godot_mono.app/Contents/MacOS/Godot`; use `--log-file /tmp/<name>.log` for sandboxed headless runs because the default `user://logs` location is not writable.
- When adding or relocating specifications or tools, update every reference and command that points to them.

## Keep work resumable

- Maintain `.agents/PROGRESS.md` throughout every task so work can resume after the current session or context is lost.
- At the beginning of a task, read `.agents/PROGRESS.md` before making changes. Reconcile it with the current working tree and update it if the recorded state is stale.
- Save progress after each meaningful milestone and before any potentially disruptive, long-running, or context-heavy operation. Do not defer all progress recording until the end.
- Record the current objective, completed work, remaining steps, important decisions and assumptions, files changed, and verification results. Include exact commands when they are needed to resume or verify the work.
- Keep `.agents/PROGRESS.md` concise and current. Remove obsolete steps, clearly distinguish verified facts from open questions, and never store secrets or credentials.
- When a task is fully complete, mark it complete and leave a short final state and verification summary. Future tasks may replace completed task details rather than growing the file without bound.

## Prefer the best current design

- This project is under active development and does not require backward compatibility unless the user explicitly says otherwise for a specific task.
- Prefer breaking changes when they produce a cleaner, simpler, safer, or more coherent design. Do not preserve legacy APIs, compatibility shims, deprecated paths, or obsolete structures merely to avoid updating callers.
- Implement the best complete design you can justify, not the smallest patch. Update every affected caller, test, scene, resource, configuration file, document, and tool so the repository consistently reflects the new design.
- Remove superseded implementations and stale compatibility code once all uses have migrated. Do not leave parallel old and new approaches without a concrete need.
- Comments and documentation must describe only the current behavior and rationale that remains relevant. Remove change-history comments such as "previously," "now," "temporary migration," or notes explaining what an old implementation did; version control is the change history.
- After the functional implementation and verification are complete, always perform a dedicated final refactoring phase. Re-read the full diff and affected code, simplify structure and naming, remove duplication and dead code, align related APIs, update comments, and rerun relevant verification before declaring the task complete.
