# Forest Symphony｜Style-first 17×13 New Ground Native VX V1｜2026-10-24

**CURRENT STATUS: ISOLATED VX REAL NEW SOURCE GROUND/PAR PASS; formal Forest Symphony runtime NOT TESTED; human Gate F NOT RUN; complete ground3-quality Elf Village NOT PASS.**

## Previous reporting error, corrected
The earlier VX screenshots were from the old B1 v8 bridge/treehouse regression, **not** the newly AI-generated Ground/PAR. The user's objection was correct. The newly generated 544×416 ground and source cutouts had at that point only passed static compilation, not VX engine import. The work below directly repairs that gap.

## New source assets actually imported to Windows RPG Maker VX Game.exe
- Generated painterly meadow/dirt-road Ground 544×416, SHA256 `8e7f7072d6304289100f9c07d686bacde30d51b8f005e13ea4204edfdcb7201b`, opaque across the entire canvas.
- Six new style-matched PAR source sprites (three trees, two rocks, one wooden sign), each SHA-validated against the single Scene Manifest. No old v8 tree sprites or v8 Ground are used.
- New Scene object placement derives x/y and foot-Z and a ground-collision bitmap. 13 sampled VX blocking tiles; the other legal movement positions remain accessible.
- A test-only RGSS2 adapter is inserted into an **isolated** Project1 duplicate from the prior proven Windows VX engine template. Official sealed FS scripts remain unchanged.

## Native engine evidence (not a synthetic preview)
- The manual Game.exe boots, supports arrow-key walking and actual blocked movement, and has no auto-teleport flag.
- A separate auto-probe Game.exe captured five real 544×416 Windows frames: behind/front of a western tree, behind/front of an eastern tree, and spawn.
- Strict native PNG vs source-composited Master: **0 background mismatches outside the actor** and **0 invalid foreground-owner occlusion pixels** in all five frames.
- Both behind-tree frames show the actor fully hidden (0 visible actor-change pixels). Three front/spawn frames show the actor (627 changed pixels each).
- Source transfer package SHA, each object SHA, and Game.exe image import all checked.
- Full private ZIP was extracted into a *new Windows directory*: 165 ZIP item SHA256 checks, Python native-source rebuild, then a second real VX five-image / movement-collision test all PASS.

## Deliverables (private sources and engine)
- [Complete playable Windows VX ZIP](https://drive.google.com/file/d/1LKjsqjxgiUl5VZWWTH7aUVQCDDLC8NsO/view): `FS_STYLE_FIRST_VX_NATIVE_V1_20261024_PRIVATE_PLAYABLE.zip`, **22,803,385 bytes**, 167 entries, SHA256 `39bdd725140298d20e78248943f230e67ec68fe63c0f2ccbce4e77aaca5d6ac4`.
- [Private original-source ZIP](https://drive.google.com/file/d/1SnlXP6PFCxzlgklphn66uQqAnyWhf3YH/view): includes original generated sheets/concept, crop manifests, semantic masks, source compiler, checks and logs.
- [Google Docs current handoff](https://docs.google.com/document/d/1B--jOuUYWqmIH6zy9e0WRC07HAC8DkhDpBPFbjLKmhY/edit).
- [Style-first workflow Authority v4](https://docs.google.com/document/d/1Hfs7v5tctPVrMDLB_a_0o-85_ou_jLKKx3sdtk0v5I4/edit).

Windows ZIP root: `START_STYLE_FIRST_VX.cmd` launches real Game.exe; `RUN_NATIVE_QA.cmd` reruns source rebuild and screenshot pixel tests (Python/Pillow/rubymarshal required for developer QA, not for manual play). Logs: `logs/STYLE_NATIVE_VX_VALIDATION.json`, `logs/STYLE_RELEASE_EXTRACTED_AUDIT.json`, and 5 native screenshots.

## Remaining gates
This does **not** mean the newly generated art has already been integrated with old v8's treehouse Level1 or bridge Level0/2; those 25 actions belong to the separate v8 baseline. Full elf village rich-style visual Gate, production sealed FS integration, Godot re-import, and user human Gate F remain pending. Source rights stay PRIVATE_TEST_CANDIDATE; do not upload licensed images to public GitHub or commercially redistribute them.

**Next step:** continue the user-specified order (reference style → new Ground → modular Ground parts → matching PAR parts → semantic masks → single Manifest compile → VX screenshot and collision tests), then scale toward the high-richness ground3 village while progressively re-verifying the v8 level-aware engine adapters.

## User visual feedback accepted as art-direction benchmark (2026-10-24)
After directly inspecting the new style-first Ground and PAR in an actual native VX game, the user stated **「效果很棒」** (looks excellent). Record `STYLE_FIRST_V1_USER_VISUAL_POSITIVE_FEEDBACK`. Reuse this style family for newly generated grass/dirt/paths, Ground modular patches, trees, village props, landmark/treehouse, and richer Elf Village stages. Preserve the original generated source files and Scene Manifest, and re-test source-layer native VX each release. **Do not conflate favorable visual feedback on the pilot with formal Human Gate F or full village benchmark acceptance.** The user's next instruction is to record/upload the decision and continue active development.
