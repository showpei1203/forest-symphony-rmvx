# Forest Symphony | T-B R12 monster art factory | 2026-11-22

## User mandate / strict scope
User explicitly said to **stop integrating monster art into the combat system**, to complete missing evolution-chain forms and the **many monster animations**. R12 is 100% **art generation, sprite atlas QA, standalone Godot 4.7.2 ART gallery**. No BattleScape, ATB, HUD, Enemy IDs, damage, character animation, T-A/T-C or main branch touched.

## Completed real artifacts
- Source-authentic families: **TB02 Leaf Bat** (3 original stage PNGs, 3 stages) and **PMD Lava Frog** (3 original stage PNGs, 3 stages).
- Previous R10/R11 owner-approved artwork retained **unchanged**: Leaf Bat Stage1 R8 mouth bite 11F, Lava Frog Stage1 V6 mouth bite 11F; previous other 4-action atlases retained byte-for-byte.
- R12 adds 18 **distinct real PixelLab Skeleton v3** monster-specific animations:
  - Leaf Bat Stages1/2/3: **Guard 7F + Skill 8F + Fly 8F** each. Stage1 128px tiles, Stage2 160px, Stage3 224px.
  - Lava Frog Stages1/2/3: **Guard 7F + Skill 9F + Hop 10F** each, 128px tiles.
- Previous 24 clips / 193 frames + new 18 clips / 147 frames = **42 real sprite clips / 340 distinct frame slots**, **6 total forms**, **7 actions/form**. No Stage1 sprites merely resized and relabeled as Stage2 or Stage3 actions.
- **18 real successful provider jobs** x **3 generations** = **54.0 PixelLab generations** for R12, provider-reported. USD cost not reported. One extra BAT Stage3 Fly request initially rejected with HTTP 429 concurrency limit (not counted as successful/charged), successfully resubmitted and all 8 frames received.
- R12 standalone Godot gallery at `godot/tb12_gallery.tscn`: displays all six creatures, seven actions (`1` Idle; `2` Attack; `3` Hurt; `4` KO; `5` Guard; `6` Skill; `7` movement Fly/Hop; Space to replay). No battle engine dependencies.

## Genuine QA and proof
- Real provider job metadata in `reports/R12_PROVIDER_JOB_LEDGER.json` includes source SHA256, padded input SHA, original PixelLab job/generation ID, exact seed, prompt, 3.0 generation usage, image output SHA, borders, all frame identity count.
- All 18 new atlases: **frame-count exact, every frame non-empty, no non-transparent pixel touching atlas cell borders, >=3 unique raw pixel frames, output SHA matches provider report**, verified independently in `reports/R12_ALL_42_CLIP_FRAME_QA.json`; all 42 current stage/action clips PASS.
- **Godot 4.7.2.stable.official.ed1daf0bf** `FS_TB_R12_GODOT472_NATIVE_ART_ONLY_PASS clips=42 frames=340 stages=6 actions=7` from `reports/R12_GODOT_NATIVE_QA.log`.
- **Real non-headless** Godot Mesa llvmpipe OpenGL/Xvfb native F3 screenshot capture for Guard, Skill and Fly/Hop, each `FS_TB_R12_GODOT472_NATIVE_CAPTURE_PASS`, 1280x900; images stored under `godot/out/`.
- Two full seven-action 3-stage contact sheets under `reports/`. 18 actual-frame GIF previews under `reports/new_action_gifs/`. GIFs are **display previews only**; original RGBA PNG atlases are the canonical gameplay art assets.
- PRIVATE ZIP contains exact source stage PNGs + 42 authentic atlas PNGs + Godot demo + QA/provenance/manifest + GIF reviews. CRC check and SHA256 recorded in final release summary; all proprietary art stays private in user Drive. Public GitHub receives scripts, tests, manifests, handoff/Failure Log **not** copyrighted/private raster PNGs.

## Approval gates and honest limits
- **TECHNICAL_QA_PASS is NOT USER_ART_ACCEPTED.** All 18 new actions marked `OWNER_ART_REVIEW_PENDING`. Stage1 original R8 Bite and V6 attack remain approved only as previously established.
- Bat Fly motion may be visually subtle relative to its normal hover; reviewer should inspect loop for actual wing animation and visible forward travel. No fabricated detached arms, no projectile effects in Skill. Skill means **charging/casting pose**, external magic effects are a separate art unit.
- This completes seven **baseline** actions per form, not every possible game animation, every direction, or every future monster species. Additional movement directions, alternate physical attacks, attack anticipation, skill special effects, status animations, and evolution transformation remain future art-only production work.
- Prior combat/R9 work is historical and must not be revived under this mandate.

## Next full unit, not a detour
Continue **monster animation breadth** with creature-specific `Charge`, `Cast Release`, `Stun`, `Wake/Revive`, `Evolve/Transform` and direction/facing variants as appropriate, using stage-locked original sprites; verify artistically before mass scale-out. Then a third species full 3-stage 7-action family. Keep same art-only QA and private Drive / GitHub T-B branch discipline.
