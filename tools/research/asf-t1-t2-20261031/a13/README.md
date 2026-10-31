# Forest Symphony / ASF A13: wrist-bound sword, source-pixel quadruped paws, animation keyposes

**2026-10-31. STATUS: A13-R3 ASF/Godot TECH PASS, human visual G7 NOT PASS, complete I2V NOT RUN.** This is a private-art, isolated test branch; no SEALED FS/R17/Tankentai/LPC/PMD files were changed.

## Goal

Make GPT-generated character/monster **single Master** useful for games: master → proper key poses → spritesheets via ASF → actual game-engine playback → **human art approval**. Never confuse format transport/pixel parity with believable movement.

## What was materially changed since A11/A12

T1 forest scout source is exactly the original A10 64×80 PNG (SHA256 `43cf8d9b9562c8de63cccf224774c2e3f318b1f4ed4046151fd52cd001e84f72`). Eight attack poses now carry explicitly named semantic states, variable ticks and `shoulder/elbow/wrist` coordinates. A new, procedurally drawn short sword has its grip rigidly parented to the wrist (reported numerical grip offset **0 px**). T1 body uses original source art. Crucial caveat: **the original painted hip scabbard and a stylized wrist/sword overlap remain visibly unconvincing**, so this is not human G7 PASS and the source pixels are not all from the single Master (additional procedural blade).

T2 moss antler source is exactly the original A10 64×64 PNG (SHA256 `74230347769421cface62e97ddaa146cc657177a5fa9c539f3961f50ce6c31bc`). Eight semantic attack phases now define four foot contact flags and individual foot world-space coordinates, with continuous stance-foot drift checked as **0** in the numeric contact table. No antlers were cut off.

**Negative iterations preserved:**
1. R1 generated legs as simple quadrilaterals. They were blocky wooden posts, **VISUAL FAIL**.
2. R2 used *real source-pixel patches* from the master instead of synthetic blocky legs. This substantially improved style coherence, but the positions of planted feet still drifted across frames, **CONTACT-TABLE FAIL**.
3. R3 uses the same original-pixel leg components and fixed world-contact positions for contiguous stance phases. **Coordinate verification PASS; art remains human pending** due to visible seams, lack of true torso/leg articulation, and limited animal weight transfer.
4. T1 independently articulated hand and sword beats are more readable than whole-body swing, but visual alignment of grip and hand and proper empty-scabbard state still insufficient.

All keyposes were programmatically created from the original Master with Pillow and author-controlled limb geometry/part masks. **No image-to-video model was used**, no new photoreal or independently regenerated facial details substituted.

## Real ASF compiler and native Godot run

The two isolated candidates were rebuilt with real ASF `build_animation_clips.py --strict` and `export_engine.py --target all` on the authorized Windows PC.

| | T1 | T2 |
|---|---:|---:|
| Action clips | 6 | 5 |
| Source frames | 46 | 38 |
| Replacement attack frames | 8 | 8 |
| Distinct attack frames | 8 | 7 (deliberate same rest pose at beginning/end) |
| ASF strict warnings | 0 | 0 |
| Export | Aseprite JSON, Godot SpriteFrames, Godot Sprite3D | Same |
| All nine pre-existing **non-attack** actions | Source SHA identical | Source SHA identical |

Godot 4.7.2 Stable, AMD RX6700XT, OpenGL3.3 loaded the ASF-exported scenes, played 11 clips, captured two native GPU screenshots, and performed **22/22 source RGBA frame-to-Godot-render exact RGB comparisons**, zero errors. The comparison is merely proof of a correctly compiled/rendered animation, **not** that the fighting/motion looks good.

Fail-closed negative test: removed T2 `attack_04.png` from a disposable copy, invoked ASF strict mode → **exit 1** with **no published output directory**. PASS.

Official FS K4/N5 source script SHA unchanged and checked:
`K4=5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`
`N5=3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`.

## Required next learning step (A14)

A12 resources (PixelOver bone tutorial; JatCool AI Sprite Animation per-pixel segmentation; foot-lock constraints and silhouette quality; quadruped biomechanics) must now be converted into true **part-identity masks**: hands, two forearm segments, sword guard and grip, near/far legs, masked/occluded underlying torso. Source-pixel parts need hidden-area backfill, not just transformations.

T1: redraw only the hand-on-hilt contact, add sheathed/drawn state with an *empty* waist scabbard, emphasize winding-up, strike/contact and recovery and a coherent end-of-motion hold.

T2: use hoof attachment/ground track observations from **rendered sprites** in addition to the semantic foot target table, cover disconnection seams and convey actual rear-limb push and front-limb brake. Contact chart alone cannot guarantee visually planted feet.

Proceed to full FS/Godot/VX integration **only after human Gate F art approval**. Previous A09 weapon runtime tests belong after this visual gate, not before.

## Reproducibility and authority

- Private root: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\A13_KEYPOSE_RIG`. All 8+8 original sprite PNG candidates and A/B actual GPU screenshots are kept *private on Windows*, not committed to this public GitHub repository.
- Complete local archive: `A13_KEYPOSE_R3_FULL_PRIVATE_20261031.zip`, **1,091 files / 4,838,637 bytes, CRC PASS**, SHA256 `ffddcf79663563c76468d0f391d0abb6795fb564db605565ea5c38a8c7ec2024`, **NOT uploaded to GitHub/Google Drive**.
- Public reproducible scripts and numeric QA: `scripts/create_a13_keyposes.py`, `scripts/refine_t2_source_pixels.py`, `scripts/correct_t2_foot_contacts.py`, `scripts/build_a13_inputs.py`, `scripts/verify_a13_r3_gpu.py`, `scripts/package_a13.py`, `data/A13_R3_FORMAL_QA.json`, `data/A13_R3_GODOT_PIXEL_PARITY.json`, and two versioned manifests.
- **Final A13 decision:** G1 prior source identity PASS; G3 procedural rig candidate; G4 PASS; G5 ASF strict PASS; G6 Godot real GPU PASS; **G7 art FAIL/PENDING**; native VX for new candidates NOT RUN; model I2V NOT RUN. No formal seal.
