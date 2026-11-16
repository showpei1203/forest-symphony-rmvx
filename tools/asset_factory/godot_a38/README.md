# FS A38 Godot-first Actor01 RUN / IDLE pilot

**Isolated test project.** Open `project.godot` in Godot 4.7.2. Godot 64px frames, no VX three-frame restriction. Two sprites on an RPG battle preview: unchanged A35 RUN on the left, PixelLab A38 IDLE on the right.

**Controls:** 1 = IDLE R1 raw (5 true source poses / 8 phases); 2 = IDLE calm selected (3 true source poses / 8 display slots); 3 = IDLE R2 raw (5 poses / 8 phases); 4 = RUN original 8 fps; 5 = RUN tuned 10 fps; Space = pause; +/- = speed.

Model source: PixelLab Interpolate V3. Both R1 and R2 independently generated actual PNG/GIF from accepted first and last images; they did **not** produce 8 unique original frames. Breathing exhale reuses a reverse sequence, which is appropriate for a symmetric breath cycle and is explicitly recorded. R1 G1/G2 and R2 G1/G2/G3 had exaggerated hands, feet or head movement; all profiles **ART HOLD**. Calm is a lossless selection of R1 G0/G3/G4 and **does not** count as new provider-generated art.

Motion controller: `scenes/actor01.tscn` using `FSBattleActorAnimator`. Supports `run` and `idle` only; attack/cast/hurt/death reject unsupported. Profile JSON allows future animations with arbitrary frame counts, textures and durations. Formal FS migrated BATTLE integration is not claimed.

QA: `qa/qa_animation_runtime.gd` must be executed with real Godot OpenGL compatibility renderer to test animation event sequence, state/profile switches and GPU snapshot. `qa/qa_idle_gpu_capture.gd` records each of the eight displayed frames on the GPU for comparative visual review.

**Source integrity:** A35 RUN 256x128 remains byte-for-byte unchanged (SHA256 ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b). Original PixelLab R1/R2 GIFs and sheets are kept separately on private Google Drive. No editing of FS original E: project or GitHub main.
