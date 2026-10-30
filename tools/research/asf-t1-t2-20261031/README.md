# FS / Agent Sprite Forge: T1/T2 Master-to-Spritesheet Test (2026-10-31)

## Purpose and mandatory pipeline correction

Main goal is **one generated character/monster master → AI image-to-video actions from that same master → frame extraction, alignment, transparency and sprite sheets → game import**. Old A09 weapon/Godot/VX parity experiments are archived and moved **behind** the new pipeline's art/motion gates.

Formal spec and current test handoff (Google Drive 07_Tools):
https://docs.google.com/document/d/1KnY72roQtVyzFtbpVbf6Bs423f855ziEZE61b2WDaGc/edit

## Case specification

| Case | Master | Actions | Registered frame | Sheet |
|---|---|---|---|---|
| T1 Forest Scout | One full-body Q-style human master | idle/walk/attack/hurt, plus run/jump extension | 48×64 RGBA, anchor (24,61), 4 frames/action | 192×384, 6 rows |
| T2 Sproutling | One original plant creature master | idle/walk/attack/hurt, plus faint extension | 48×48 RGBA, anchor (24,45), 4 frames/action | 192×240, 5 rows |

G1 single source master, G2 same identity, G3 *real* motion from the same master, G4 true alpha/registration, G5 ASF clip and sheet roundtrip, G6 engine runtime screenshot, G7 human visual approval of official FS art direction. **Formal PASS only when G1-G7 all pass.**

## Actual execution and quantitative outputs

- Called the host image-generation tool twice. Both attempts produced a **composite report/infographic**, not a single clean character master. This is **G1 RAW INPUT FAIL**, not a successful single-master render. Do not trust any checkmarks or fabricated statuses painted into the AI image itself.
- For a deliberately labeled partial recovery test, used the second AI output's **already drawn** pose rows as artwork. A local Pillow/SciPy script isolated connected sprite components, removed the *painted checkerboard* background to actual RGBA binary alpha, normalized feet/size, assembled sheets and GIFs.
- T1 physical artifacts: **24 unique** 48×64 transparent PNG frames, 192×384 sheet, **6** four-frame GIF previews, candidate master RGBA.
- T2 physical artifacts: **20 unique** 48×48 transparent PNG frames, 192×240 sheet, **5** four-frame GIF previews, candidate master RGBA.
- Tested all **44** resulting frames for nonempty binary alpha and safe margins; all sheet cells roundtrip byte-identically against the standalone frame images; GIFs report 4 frames. Thus local **deterministic post-processing G4/G5-LOCAL TECH PASS**. This is **NOT** ASF CLI PASS on these new files, and certainly not master-to-motion generation PASS.
- Visual defects: T1 attack does not clearly display a weapon strike, and T1 jump does not have a convincing airborne phase. G7 cannot pass. T2 attack/faint are more legible but require human review.
- Offline preview-only Godot project files prepared, **not executed in a native runtime**, so G6 = NOT TESTED.
- Connected Windows PC ASF `forge_doctor.py`, pinned tool revision `5324342fdfab`: image route `host_image` ready; ffmpeg present; **video route NONE** (no configured xAI/ARK/fal keys and no Grok/Codex CLI). Therefore genuine **single-master → video motions G3 NOT TESTED** and blocked by missing motion route. No paid calls or secrets requested.

## Files and evidence

Current chat downloadable private ZIP: `T1_T2_ACTUAL_TEST_CANDIDATE_20261031.zip`, **83 files**, **3,566,406 bytes**, ZIP CRC PASS; SHA256 `5128faeeea3da6d4785270a6e818a9589a4b776049e07ad267cc4bad53118cfd`. Contents include the exact AI composite used as a source, two Python reproduction scripts, T1/T2 frames, sheets, GIFs, candidate masters, manifests, QA JSON, small unexecuted Godot previews and formal Markdown spec/report.

**Cloud binary limitation:** This ZIP was created in the ChatGPT conversation sandbox, not uploaded as a binary to Google Drive/GitHub. This GitHub branch contains the textual specification/handoff only.

## Next ordered task

1. Obtain one proper **standalone** AI master of each asset, not a poster.
2. Configure/verify an available **actual video generation** route and create **one** T1 idle video from its sole approved master. Do not substitute code-drawn animation or an already multi-frame poster as proof of G3.
3. On real video, execute ASF `video2dsprite` key/matte, register, retime, finish, `build_animation_clips.py`, `export_engine.py`, logging every CLI exit code and numerical QC warning; inspect 1× sheet.
4. Only then do T1 walk/attack/hurt and T2 idle/walk/attack/hurt, verify G1-G7 and import into isolated Godot/VX for actual runtime evidence.
5. Fail-closed. Do not edit any SEALED FS/R17/PMD/LPC/CG assets. Continue handoff with each run.

**Status: partial physical candidate generated. Core automated master-to-action pipeline NOT PASSED.**
