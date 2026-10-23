# Forest Symphony B0/N5 Map Runtime Checkpoint (2026-10-24)

**Status: N5_B0_RUNTIME_ADAPTER_ISOLATED_SMOKE_PASS_VISUAL_GATE_F_PENDING**.

Canonical handoff and detailed next gates: https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit

- K4 baseline original 3,860 files matched original content SHA-256/size/CRC32 3,860/3,860; externally repackaged ZIP SHA may differ.
- K4 core Scripts SHA: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`.
- N5 SEALED Scripts SHA: `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`. Original 505 scripts intact. **No change to sealed FS**.
- Separate `Map900` adapter candidate adds exactly one script (index 482, total 506) and isolated test-map source sprites. Native N5 Game.exe B0 6/6 regression PASS: both-height stairs, cliff/water blocks, three interaction proximity tests and screenshot background pixel parity outside actor and N5 native UI; 220 native frames.
- Root-cause of first failure: FS runtime ISS ParaPassa overwrites `Game_Player#move_passable?`, so overriding only `Game_Character#passable?` cannot enable stairs. Adapter v2 overrides player edge passability strictly on Map900, preserving all other maps.
- Local results: `E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\logs\N5_B0_FINAL_REGRESSION.json`.
- B0 earlier 13/13 source compiler and 10/10 isolated VX/Godot smoke continue to hold. `SCENE04` reference-quality visual fidelity, complex bridge over/under height-state, legal licensed replacement Source Kit and **human Gate F** pending. Do **not** claim FORMAL PASS.
- Asset path anti-rediscovery index: https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit

**Next focus switch:** Pause map work; re-test/extend other already-installed OSS tools (Sprite Fusion Sprite Normals, Laigter, Pixelorama, LibreSprite, Godot lighting) and expand evidence beyond prior ToolValidation V2. Do not re-run earlier PASS merely to claim new progress. Record per-tool objectives, negative tests, inputs, hash, outputs and handoff to Drive/Linear. Never commit restricted source art, full sealed binary, licensed proprietary assets or fonts to GitHub.
