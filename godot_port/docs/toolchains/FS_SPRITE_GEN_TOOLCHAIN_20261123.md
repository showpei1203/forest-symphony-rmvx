# Forest Symphony | sprite-gen Toolchain | 2026-11-23

## Authority and boundaries
- Godot **4.7.2** is the engine. PixelLab/Orca remain identity-locked art generators. This integration adds **deterministic/offline sprite postprocessing and format interchange**, not an art-approval algorithm.
- Upstream: [aldegad/sprite-gen](https://github.com/aldegad/sprite-gen) **4.3.0**, pinned commit bb3be7b127d46de237e0b4e03f026be4fd207da6. Read upstream SKILL.md, docs/run-contract.md, docs/atlas-workflow.md and docs/engine-export.md. These skills are NOT auto-imported into Orca, Cherry Studio or every ChatGPT conversation.
- Windows owner PC: C:\Users\User\PCBridgeWorkspace\tools\sprite-gen-4.3.0-bb3be7b, isolated venv .venv-fs. Windows executable inside .venv-fs\Scripts\sprite-gen.exe.
- GitHub PC Bridge private Issue task: JSON with EXACTLY two fields, schema=1 and task=fs_sprite_gen_install.
- **No Codex, no unauthorized provider/API generation, no private image files in public FS repository.** PixelLab remains separately controlled by reviewed paid task gates. The upstream default gen command can select Codex, therefore it is **DISABLED for this FS integration**.
- Original game data E:\遊戲專案開發 and T-A/T-B/T-C work branches remain untouched. Private sprites and QA media belong in the owner's private Drive. T-C Ground-first, PAR-everything-else remains unchanged.

## Supported routes
| Lane | Use | Blocking review |
|---|---|---|
| T-A ACTOR01 | Approved paper-doll layers and 64×64 source, inspect/curation/atlas. Use an approved source for each Body/Weapon/FX layer; do NOT hallucinate missing underpaint from flattened masks | Proportions, belly/coat geometry, true poseable layers, 12F run/attack, 45-degree view, foot anchoring and human ART gate |
| T-B monsters | Approved three-stage sprites, 64/96/128/160/192 cells, atlas/sidecar, preview/recolor as optional derivatives | Family identity, distinct key poses and action semantics, expected frames, one-shot vs loop, Godot native and human ART gate |
| T-C maps | Optional independent prop cleanup; does NOT replace complete Ground then all-non-Ground PAR | Whole-scene composition and Ground/PAR contract |

## Runtime contract and technical QA
1. sprite-gen compose-atlas exports sprite-sheet-alpha.png, manifest.json containing frame_layout.rows.STATE[i] rectangles x/y/w/h and animation.rows.STATE metadata including FPS/loop/duration.
2. Use the project read-only Python adapter. Example with PRIVATE run files (never commit them into GitHub):

    python godot_port/tools/sprite_gen_fs/validate_atlas.py --manifest PRIVATE_RUN/manifest.json --atlas PRIVATE_RUN/sprite-sheet-alpha.png --output PRIVATE_OUTPUT/fs_animation_manifest.json --profile actor64 --expect RUN=12 --expect ATTACK=12

   For T-B variable cells, use --profile monster_variable and current correct expected motion counts. Output refuses to overwrite existing files.
3. QA checks: dimensions, cell size, region bounds, alpha (reject blank), durations, frame counts, FPS/loop, repeated-image warning and SHA256. Technical success ALWAYS outputs art_gate=HOLD, not ART_PASS.
4. Godot GDScript at godot_port/tools/sprite_gen_fs/FSSpriteGenAtlas.gd: read_sidecar(path), then build_sprite_frames(atlas_texture, sidecar). It creates SpriteFrames and AtlasTexture regions with accurate timing, without modifying source images.
5. Synthetic Python tests test_validate_atlas.py and Godot native smoke script test_importer.gd validate the interchange. They do not certify any private art or full FSBattle/ATB/ACT.

## Operational gates
- Technical tests first; preserve original PixelLab/source PNG byte identity. Keep source, curated, derived and QA files separate with SHA256.
- Do not stretch flattened head, arm, belly, coat or monster limbs to hide broken poses or visual mistakes.
- Only human visual review can promote identity, viewing angle, anatomy, motion and aesthetic quality.
- Native import PASS != visual ART PASS != full game integration PASS.
- T-A R23 current: real 7-visible-layer technical native 12/12 but underpaint/true paper-doll poseability missing; ART HOLD.
- T-B R19 current: actual 3-stage PixelLab SKILL and official Godot image import/native art-only pass; owner visual ART HOLD and no full FSBattle/ATB/ACT.
- Upgrades require a newly approved SHA, checked dependencies, new scoped Bridge installation and native/QA verification. Do NOT silently follow upstream moving main.

## QA / Handoff
- [PC Bridge negative Issue #107](https://github.com/showpei1203/chatgpt-pc-bridge/issues/107): extra command payload was rejected, intended FAIL.
- [PC Bridge positive Issue #108](https://github.com/showpei1203/chatgpt-pc-bridge/issues/108): Windows Python 3.11.0; Pillow 13.0.0; NumPy 2.4.6; sprite-gen 4.3.0 installed, basic CLI help smoke PASS, original E: games untouched.
- FS branch feat/fs-sprite-gen-toolchain-20261123 is isolated from main/T-A/T-B/T-C. No private raster is stored here.
