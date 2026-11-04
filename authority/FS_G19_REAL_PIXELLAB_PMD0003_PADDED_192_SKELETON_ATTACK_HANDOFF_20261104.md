# FS G19 / REAL PixelLab PMD0003 Skeleton V3 padded Close Attack — 2026-11-04

**Status: Real provider TECH PASS; improved Close Attack candidate, human ART PENDING; PMD/XML and VX native integration NOT TESTED.**

## Why G19 was necessary
- In G16, the original PMD0003 concept sprite already occupied x10..125 inside a 128×128 canvas. A strong southeast-oriented head/forelimb lunge had insufficient space and the rendered hit looked like an idle arm-lift.
- **G19 uses no regeneration of the starting sprite**. It copied the same G15 128×128 cleaned source pixels (33 isolated alpha flecks already removed) into a transparent **192×192** canvas at offset x+22/y+26. The source alpha bounding box therefore became (32,43,147,145), leaving 45px of right margin for an actual lunge without destroying source pixel details.
- The same proven 18-joint quadruped rig is remapped with x'=(128x+22)/192 and y'=(128y+26)/192. It uses explicit pose targets for _1 wind-up (crouch), _2 right/down forepaw and head/shoulders thrust, _3 follow-through. Direction: **south-east 45°**; view: low top-down; template: bear. No ImageGen attack frames.

## Real provider evidence
- PixelLab endpoint: `POST /v2/animate-with-skeleton-v3`.
- HTTP 200, Job ID: `66750210-3b60-46a1-8e21-99620c373a43`, provider status completed; 3 actual 192×192 transparent PNG frames returned.
- Direct provider usage: **2 generations**, single POST; no duplicate charge/retry.
- F1 bbox (30,47,142,148), one alpha-connected component with 7950 pixels, alpha centroid (84.564,99.472).
- F2 bbox (22,41,164,150), one alpha-connected component with 9223 pixels, alpha centroid (97.041,95.330).
- F3 bbox (27,44,155,151), one alpha-connected component with 8813 pixels, alpha centroid (92.051,98.562).
- **F2 body-pixel centroid moved 12.477px toward screen-right relative to F1**; visually the hind limbs also stretch and the chest/near forepaw lunge. This is concrete improvement over the G16 almost stationary paw motion. No edge clipping and no detached alpha islands.
- Do not confuse technical metrics with human art acceptance: the exact impact gesture and transition continuity still need human inspection.

## Actual delivered artifacts
- [Drive G19 project folder](https://drive.google.com/drive/folders/1O6jNn3iWpJGPWD55suAYUMFW8vGYoTNA)
- [G19 complete original source+poses+PNG+GIF+code+SHA ZIP](https://drive.google.com/file/d/1Ts_hAtUTxL-QPgMnYCLXA2N98PvHQLcC/view)
- [G19 original three-frame PixelLab provider QA](https://drive.google.com/file/d/18JYbxqKDPVpQl332MTjZT5jXFgM1N1ZW/view)
- [G19 real output 3-key animation GIF](https://drive.google.com/file/d/1zJtaFN1pHNS-V017fFN1f6HW_hdHBPGq/view)
- [G16 vs G19 actual PNG comparison](https://drive.google.com/file/d/1RTBFu7hlymHUVkjQ12c4SIqghsWHMzHl/view)
- [G19 detailed Handoff Markdown](https://drive.google.com/file/d/1E9TTlQgIpAjvdmvWCR0H4FH5EA_3PFHw/view)
- ZIP `FS_G19_PMD0003_REAL_PIXELLAB_PADDED_192_CLOSE_ATTACK_20261104.zip`, size 235241 bytes, 16 entries, CRC PASS, SHA256 `539e8ee072e3477e5e18cdd9b7e073404c5fe73574d1d2e7b7ac5cf9d79ca46c`.

## Engineering blockers and next
- G19 **192×192 sprite frames are not original PMD native atlas cells**. Never replace `AnimData.xml`, Offsets, Shadow, G11/G12 graphics, nor approved PMD0001/0002 without a proper native schema and actual VX/Godot gameplay QA.
- G18's earlier 384×512 3×4 candidate sheet still includes the deliberately failed G16 attack and remains immutable history. Only after user visual approval should G19 replace G16 in a newly versioned integrated test sheet, and 192→target size conversion should be demonstrated by nearest-neighbor style verification and motion testing.
- Preserve A68 humanoid project PAUSED. No further paid PixelLab calls unless a specific defect is tested or a new action needs to be rendered.
