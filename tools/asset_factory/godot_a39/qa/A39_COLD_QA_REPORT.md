# A39 independent cold-extract verification — 2026-11-14

Tested the owner-only ZIP as an independent project, not the active Godot editor cache. Extracted into a new temporary **G: Google Drive** folder `FS_A39_COLD_QA_TEMP_20261114`. Using the authorized user's desktop Godot 4.7.2 and AMD RX 6700 XT OpenGL 3.3, performed:

1. `--headless --path <cold> --editor --import --quit`: **exit 0**, all resources and scripts imported.
2. `--path <cold> --script res://qa/a39_rig_gpu_qa.gd --rendering-method gl_compatibility`: **exit 0**, 8 actual framebuffer captures, diffs `[0,14,45,37,37,45,14,0]`; changed pixels outside the chest/shoulder mask `[0,0,0,0,0,0,0,0]`; alpha changes `[0,0,0,0,0,0,0,0]`; `A39_GPU_LOCAL_BREATH_PASS`.
3. `--path <cold> --script res://qa/a39_integrated_runtime_qa.gd --rendering-method gl_compatibility`: **exit 0**; real `AnimationPlayer` moved from 0 to ~0.479 in 720ms; `RUN → IDLE AI → IDLE RIG → RUN` transitions and unsupported ATTACK rejection passed; `A39_GODOT_INTEGRATED_RUNTIME_PASS`.
4. Deleted the temporary cold-extract project in G: when both tests finished. No FS source files on E: were changed.

Scope: engine/tooling PASS, pixel identity/outside-mask PASS. Artistic naturalness and integration into the *main* FS migrated Godot battle-state project remain separate gates, currently **ART HOLD** / **NOT_RUN**. The test does not claim exported Android or official RMVX deployment.
