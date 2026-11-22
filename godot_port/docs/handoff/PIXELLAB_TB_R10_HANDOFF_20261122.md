# Forest Symphony | T-B R10 | Full three-stage Leaf Bat motion production | 2026-11-22

## Corrected owner priority (supersedes R9)
User: 「妳先不用考慮整合進戰鬥系統，專心把怪物都生成好，我們怪物需要的動作很多，整串進化鏈也還沒做完」.
**STOP battle engine, UI, ATB, ACT, BattleScape/Enemy ID mapping work on T-B.** Only creature family shapes, distinct animations, spritesheets, technical native art gallery and art review.

## Real deliverable, not design-only
- TRUE TB02_LEAF_BAT source-locked stage1 96px, stage2 128px, stage3 160px; source SHA readback in R10 manifest. No fantasy replacement of the original three stages.
- The source-authentic stage1 PixelLab Idle 8F and owner-accepted R8 Bite 11F remain byte-exact. Added stage1 Hurt 6F + KO 8F.
- Stage2 distinct 160px canvas: Idle 8F + mouth bite Attack 11F + Hurt 6F + KO 8F.
- Stage3 distinct tall-crown + glowing-chest original species: Idle 8F/192px + revised mouth bite Attack 11F/224px + Hurt 6F/224px + KO 8F/224px.
- **Three stages x four authentic motions = 12 clips, 99 original frame cells**. Total 10 brand-new technically valid clips, 1 historical rejected R10A candidate. 4x/3x sprite-sheets, no source pixel recycling or recolor as animation.
- 12/12 frame geometry, transparency, distinct-frame and no-edge-touch tech QA PASS. Original Godot **4.7.2** isolated native sprite gallery verified 12/12 available motions. Xvfb Mesa llvmpipe OpenGL actual 1280x768 frame-F5 capture pass.
- New motions **ART_REVIEW_PENDING** until owner actually evaluates animation GIFs, not equivalent to human approval. Only previous stage1 R8 Bite has explicit owner acceptance.

## Cost and actual PixelLab generation trace
- 11 real provider jobs x 3 generations = **33.0 generations new**; one rejected stage3 192px Attack incurred 3 generations and is retained. No USD price verified.
- TB02 pre-R10 25.0 generations; **cumulative 58.0 generations**.
- Explicit action-specific 13-joint bat head/jaws/wings/tail source rig; no fake arm/claw attacks; higher stages made from their OWN source PNG and padded 160/192/224 canvases.

| Batch/clip | PixelLab job ID | Sheet | Generations | Technical |
|---|---|---|---:|---|
| batchA/2_idle | `ce69bf83-053e-47f6-b547-214731cf61ed` | BAT_STAGE2_IDLE_8F_160px.png | 3 | PASS |
| batchA/2_attack | `83d1d82a-77a5-47c2-94a4-c6d5d0046b32` | BAT_STAGE2_ATTACK_11F_160px.png | 3 | PASS |
| batchA/3_idle | `efa7031c-a0f6-4930-a48b-b041bcbd0405` | BAT_STAGE3_IDLE_8F_192px.png | 3 | PASS |
| batchA/1_hurt | `a41d54b8-fbb7-4a2d-9498-5fa1f52616a1` | BAT_STAGE1_HURT_6F_128px.png | 3 | PASS |
| batchA/1_ko | `8ab067e4-bd25-458d-9feb-d2cf14d30539` | BAT_STAGE1_KO_8F_128px.png | 3 | PASS |
| batchA/3_attack_r10A_edge_hold | `0740b6df-4589-47ef-b361-826db46a8ce8` | BAT_STAGE3_ATTACK_11F_192px.png | 3 | HOLD |
| batchA/3_attack | `a70147d2-5ef5-49d8-b3d6-53ba533f2fe1` | BAT_STAGE3_ATTACK_11F_224px.png | 3 | PASS |
| batchB/2_hurt | `228ad8ce-d0dd-4021-871e-1c8ffa921cd6` | BAT_STAGE2_HURT_6F_160px.png | 3 | PASS |
| batchB/2_ko | `d26fafad-69d4-4e09-9636-39a927c761a6` | BAT_STAGE2_KO_8F_160px.png | 3 | PASS |
| batchB/3_hurt | `f01d8b21-8fd8-4f74-b3ed-f5b9f1a730d8` | BAT_STAGE3_HURT_6F_224px.png | 3 | PASS |
| batchB/3_ko | `53d6c3fc-eabc-408b-bf2a-f51d4d3eb419` | BAT_STAGE3_KO_8F_224px.png | 3 | PASS |

## Failure Log
**R10-A-F05 CROPPED WING EDGE HOLD**: Stage3 Attack 192px F5 had three colored pixels touching right frame boundary. Preserved first provider PNG at `reports/rejected/BAT_STAGE3_ATTACK_11F_192px.png`. Mechanism = inadequate padded frame despite distinct motion. Rebuilt from exact stage3 source PNG with 32px instead of 16px safety padding, 224px cells. New job `a70147d2-5ef5-49d8-b3d6-53ba533f2fe1` yielded 11/11 frames zero edge contacts. This is a changed canvas method, not a pixel band-aid.
**Other nonblocking caveats**: Stage3 Attack mouth opening is smaller visually than Stage2 at F5; human 45° direction and quality review remain pending. Stage2/3 face/crown/wings are visibly consistent at selected frame, but technical QA alone does not certify animation art.

## Completion boundary and next work macro
- The 3-stage Leaf Bat chain has a reproducible 4-motion baseline. **This is not the full required set**: Guard/Skill/Fly remain missing in each stage (9 clips), plus the first lava-frog family's higher-stage animations are not finished. Do not claim all monsters done.
- **NEXT FIRST**: original lava-frog PMD0002 + PMD0003 own-source Idle and Attack, then Hurt and KO; follow with Guard, Skill, traversal/fly in the same bat family and frog chain. No battle mechanics work.
- Godot gallery is an ART factory witness only, NOT real FS battle integration. No private PNG in public GitHub. No user's PC persistent library; PixelLab executed in Win %%TEMP%% and must be cleaned after Drive readback.
