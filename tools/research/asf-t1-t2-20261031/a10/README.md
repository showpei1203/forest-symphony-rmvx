# A10 — true AI still → deterministic pixel rig → Agent Sprite Forge → Godot (2026-10-31)

**Status: T1/T2 new AI master TECH PASS; deterministic rig-generated sprite actions and ASF 11-clip packaging TECH PASS; real Godot GPU pixel parity 22/22 TECH PASS. Actual image-to-video not tested. Human art Gate G7 NOT PASSED. No SEALED FS asset modified.**

## What changed from R2

R2 extracted already-painted frames from a misleading multi-action AI poster, so it did not verify generation from one standalone character. A10 generated **two genuinely separate single-subject images on solid magenta**:

- **T1 forest scout**, brown-haired green-cloak swordsman, complete original still. Chroma-keyed, alpha binary, compressed at 48×64 and 64×80; rig source master **64×80**, 32-color finish.
- **T2 moss antler**, quadrupedal forest creature with branching antlers and foliage, original still. Chroma-keyed, alpha binary, compressed at 48×48 and 64×64; rig source master **64×64**, 32-color finish.

Both are new independently AI-generated stills, **not from a sheet or infographic**.

### A10-RIG: alternative to video generation

We built a deterministic nearest-neighbor **inverse mesh warp** that moves source pixels according to per-region head/arms/legs/feet displacement fields while keeping the original sprite palette. It does not redraw faces or invent new character pixels, and **does not use an AI image-to-video model**. Treat this as an explicitly named alternate tool route, *not* an ASF video2dsprite success.

| Test case | Actions | Trial RGBA frames | ASF final referenced frames | Canvas / anchor |
|---|---|---:|---:|---|
| T1 Forest Scout | idle/walk/run/attack/hurt/jump | 46 | 45 | 96×112 / (48,104) |
| T2 Moss Antler | idle/walk/attack/hurt/faint | 38 | 37 | 96×96 / (48,88) |
| **Total** | **11** | **84** | **82** | both with 32-color source palettes |

All 84 trial frames are nonempty, use hard alpha and avoid touching the canvas edges after correcting an inverted T1 jump offset and cropped antlers during T2 faint rotation.

## ACTUAL Agent Sprite Forge implementation

On user's separate Windows test folder, source Master transfers were decoded on Windows and pixel RGBA SHA checked against the generating computer. Sources T1 RGB/RGBA pixel sha `acb99751906fed095aeaee96fbe692d38c0841d14f9597b40a3a66f99d994dde` and T2 `4d200d0c02cf5e5fe19f2b0516136fda634133ad691c54e69a9893ef4e5c50ef` matched.

The pinned existing `generate2dsprite/scripts/build_animation_clips.py --strict` was run, **not a custom imitation**.

- Initial strict attempt **FAIL**; no output published. T1 attack had near-identical frames [1,2] and T2 faint had near-identical [6,7].
- Corrective operation removed one redundant playback reference from each clip and **added its ticks to the adjacent hold**. Clip total tick durations remained identical.
- The corrected ASF strict compilation **PASS**, 0 warnings: T1 6 clips/46 stored source frames, T2 5 clips/38 stored source frames.
- The pinned ASF `export_engine.py --target all --sampling nearest` **PASS**: Aseprite JSON, Godot SpriteFrames, Godot Sprite3D, one atlas per character; 45+37 referenced timeline frames.

## Real native Godot proof

Real **Godot 4.7.2**, OpenGL 3.3, **AMD Radeon RX 6700 XT** loaded the two newly exported ASF `.tscn` files and played **all 11 actions** simultaneously in an actual GPU viewport. Saved two native screenshots at different time points. Source-frame-to-screen comparisons:

- **22/22** source RGBA frames (11 actions × 2 timestamps) matched the matching **Godot native GPU RGB crop exactly** after compositing against the actual screen background. Maximum RGB difference = 0.
- An initial 21/22 report was an error in the QA script: after duplicate removal the Godot **playback ordinal** is not the original image file suffix. Corrected to resolve `manifest.clips[action].frames[playback_ordinal]` then `manifest.frames[source_index].file`. Re-test yielded 22/22; no renderer defect.

This demonstrates the **ASF compiler and engine import** preserve original source pixels and frame playability. It does **not** prove the artistically realistic quality of the motions or actual RPG Maker VX import.

## Formal Gate Decision

| Gate | Result |
|---|---|
| G1 independent new AI master subject | **TECH PASS** (2 originals), awaiting user style preference |
| G2 identity preservation through skeletal source pixels | **TECH PASS** for deterministic rig route; no I2V identity gate evaluated |
| G3 newly generated motions from single master | **RIG TOOL TECH PASS**, **I2V model route NOT RUN** |
| G4 transparent 32-color frame + registration + no edge clipping | **TECH PASS** |
| G5 ASF strict and export engine | **TECH PASS** |
| G6 native Godot import, two-time captures, source pixel parity | **TECH PASS**; VX for these cases PENDING |
| G7 motion legibility & final FS visual approval | **FAIL / PENDING**: T1 sword does not make a believable swing; walk/run too subtle; T2 faint is identifiable but rig rotation needs aesthetic review |

### Lessons learned

- A strong original master still does not automatically become great combat animation through pixel warp. **Preserving identity is easier than producing meaningful articulation.**
- Procedural rig is a fast, pixel-identity-locked baseline for idle, small locomotion and death/faint. For authentic arms, sword swing or four-direction motion, we need part-level rigging or **real image-to-video pose synthesis**.
- Potential local image-to-video route: community `eviscerations/comfyui-rinsei` reports Wan 2.2 I2V on the exact RX 6700 XT 12GB, but requires a substantial ROCm/ComfyUI and GGUF model installation. This route is **research only, NOT installed or tested**. Do not silently download huge models or change GPU drivers.
- A separately generated T1 sword-strike image was a **prompt-only independent still** with similar identity, but it was not conditioned on the approved Master and was not included in the rig export. A T2 action image generation attempt returned another misleading infographic, rejected. Neither is proof of single-source generative motion.

## Handoff & storage

Windows private bundle (all ASF compile artifacts, original rig-derived frames, scripts and actual Godot screenshot):

`E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG\A10_WINDOWS_TRUE_MASTER_ASF_GODOT_PRIVATE_20261031.zip`

**635 files / 2,540,580 bytes / ZIP CRC PASS / SHA256 `a7e69706fea3de6f4637200b222009a695478775d98ebbbcef886df822ea7623`.** Private local Windows only. GitHub stores QA/text/scripts, not artwork or game screenshots. The separate chat-provided portable package contains the two new master extracts, all locally generated skeleton motion frames, GIFs and sheets; that is not the same binary as the Windows ASF build.

**Next A11:** improve the per-part rig on actual limb/sword anchors, run art acceptance for T1 sword and four-direction suitability, compare a low-cost I2V implementation before installing a ~10+GB Wan stack. Do not reopen the already-passed frame compiler unless a regression occurs. Keep FS/R17/K4/N5/PMD/LPC SEALED untouched.
