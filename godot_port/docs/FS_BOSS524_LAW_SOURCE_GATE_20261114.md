# FS Godot P1 | Boss 524 Law cycle source gate (2026-11-14)

## Evidence actually read
Repository: `showpei1203/forest-symphony-rmvx`, branch `feature/fs-godot-phase1`.
Source: `exported_scripts/401__id72365482__SetupRuntime_09｜Boss_Runtime___AI_Provider_v1.4.1.rb`, lines 415–443.

- Alive Boss 524: add State150 only if none of 150/151/152 are present.
- At HP <= 35%: remove 150,151 and 140..143; add 152 unless present.
- Else at HP <= 70%: remove 150; add 151 unless present.
- When 151 is active, and the boss responds to both `albert_ant_law_states` and `albert_ant_initialize_law_cycle`, iterate returned law-state IDs. Call initializer only if none is active.
- This source does not remove 152 after healing, nor establish a mutually exclusive finite state machine.
- The source does not define the initializer or its timing/damage semantics; **do not synthesize Law140 as a substitute**.

## Next mandatory source audit
1. Locate all ordered RGSS2 definitions and aliases of `albert_ant_law_states` and `albert_ant_initialize_law_cycle`, plus relevant add/remove State hooks; report file, section index, line number, and effective method receiver.
2. Determine last effective override at runtime (including conditional installs), and capture original VX post-boot witness after `FS_DB_AUTOSET.apply_all`.
3. Record State140–143/150–152 post-boot definitions and effect/turn behavior in private Drive, not public GitHub.
4. Add deterministic Godot tests for initialization once, cycling, 70/35% exact boundaries, healing and sticky 152, missing source/State fail-closed, and interaction with #404 global Field.
5. Only then connect Law effects to `FSBattle` action settlement and unblock protected gameplay paths.

## Current QA classification
The previous 33 native Godot headless tests are source-shaped synthetic coverage, **not** original FS runtime parity. #404 Field weather is already implemented for its proven subset; do not regress or re-implement it. State77 shield and State128/129 are still effect-pending. Phase1 seal remains NO.

## Safety
Do not modify the user's E: source project, main, or develop. No private RVData, PNG, audio, or post-boot full database in public repository. This document records a source-audit gate, not completed combat functionality.
