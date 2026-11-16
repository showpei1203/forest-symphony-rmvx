# Forest Symphony | A52 Actual PixelLab Lower-Body Animation Engineering Handoff | 2026-11-16

## User request and actual construction
User explicitly required real construction, no further written plans. A50 R4 and A51 had good upper animation but nearly motionless legs. This time the game actor was ACTUALLY regenerated using PixelLab Animate with Skeleton V3 and tested on a live Godot 4.7.2 runtime.

PixelLab paid provider job ID: 094a45f9-c279-4c06-94e4-a1708a13daac. One intentional 10-frame submission, 3.0 generation units, persistent Job Lock before POST; never auto-resubmit. All 10 real provider original 64x64 PNGs, SHA manifest, full response, original request without token, source A62 image and 18-joint coordinates live in owner-private Drive. F0 and F11 are exactly approved original Actor01 A62.

### Biomechanics
Reused all twelve R4 upper-body/facial skeleton points identically. Authored SIX lower body joints (left/right hip, knee and boot), with crouch during F2-F5, forward left boot +2.1px and back right boot -1.5px with heel lift at F7; pushing off in F6, landing in F7-F8, resetting in F9-F10. Model generated all pixels, NO cutting/stitching or limb redraw by Pillow.
Rendered fullbody can change some upper pixels despite identical upper skeleton: 10-frame difference to R4 head ROI=75 pixels, upper torso ROI=567 pixels. Do not falsely claim upper RGBA exact. Leg/hip ROI=536 changed pixels and boot ROI=176; F7 boots 43 changed pixels. All 12 body frames single 8-connected silhouette and 11 unique poses, no unrequested model sword.

### Actual Godot engineering
Separate isolated full Godot project godot_a52_lower_body_lunge, cloned from the frozen A51 R4 stable FX project. New A52 genuine 12-frame Body PNG, independent exact original PixelLab true model sword and A51 existing FX. The sword needed zero per-frame shift to remain 8-connected to the full character, so no weapon or Body patch required. Attack frame keytimes unchanged: 0.000,0.100,0.190,0.275,0.350,0.455,0.560,0.620,0.735,0.830,0.910,0.980. F7 contact t=0.63sec at local (29,7); 70ms Hitstop.

Actual Windows Godot 4.7.2 AMD RX6700XT: fresh native import EXIT0; 12 real GPU PNG frames exactly match composite source atlases (zero pixel mismatch), no edge crop and 11 distinct poses; real target HP100 -> 75 -> 50, no hit before old 0.55s, no damage out-of-range, cancel before/during, duplicate serial guard and 2x speed PASS. A52 native frame changes vs R4 (lower stance ROI) F6=88 F7=101 F8=97 pixels. Reproducing these is different from assuming PixelLab API success means valid animation.

Video evidence: native_comparisons/A52_R4_VS_REAL_LOWERBODY_NATIVE_GODOT_5X.gif, native_comparisons/A52_REAL_FULL_BODY_WEIGHT_TRANSFER_ATTACK_5X.gif, native_comparisons/A52_R4_VS_LOWERBODY_TRUE_GODOT_12FRAMES_3X.png. Original model body is immutable sha256 a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f.

## Failure log
1. Initial integration script attempted to json.dumps a Path object instead of the manifest dictionary; fixed and regenerated isolated A52 project, baseline preserved.
2. Source GDScript QA emits PASS dynamically; initial text assert incorrectly expected a static literal A52_QA_RESULT PASS in source, failed. Fixed source validation, then native GPU/contact real tests PASS.
3. Skeleton upper points retained, model upper actual pixels still vary; check visual ART rather than claiming frozen upper appearance. User requested lower stance movement and it is visibly present in native rendered sprites.
4. No auto retry or secret API token stored in files. All official source owner-private Drive, only public-safe tech docs on GitHub feature branch. No changes to old A50/A51, GitHub main, maps, E: RPG Maker VX original data.

## Status and continuation
ENGINE PASS, genuine PixelLab true source PASS, visible leg motion PASS in model and native Godot, ART HOLD pending user's actual 1x motion approval. Full formal FS Godot combat ATB/skills/enemy damage still NOT RUN, this is an isolated target demo. Compare A52 with prior A51 R4 at actual gameplay scale. Future work must not go back to pixel-slicing actor into disconnected limbs. Only add more PixelLab expense when justified by concrete visual failure.


## 正式私人雲端交付與冷啟動實測（同日確認）
完整私有工程 ZIP：https://drive.google.com/file/d/1DW4sZWzZrSVaAhuhgcHRAWYB1I9l0nw8/view
原生 R4 vs A52 同步 GIF：https://drive.google.com/file/d/1XP0kuAwNb2-DTPa9ozu687BZ7egA5yt9/view
原生 A52 攻擊 GIF：https://drive.google.com/file/d/13Q_vxRBwHIWqgYQU_OPe4kwVTcrMmUOq/view
原生 12 幀 3x 比較：https://drive.google.com/file/d/1N7MeNgUiNmUJakEmLXWpp7VgEUvI0l6J/view
Google Drive 私人來源目錄：https://drive.google.com/drive/folders/1rnDh-L-LiCUPTxVUTRUFf43SKHqif440
完整 ZIP 共387 entries，386個檔案 SHA256 一致、CRC PASS，1,927,251 bytes，SHA256 a7ee69534b99a44cfdcfd12591b5b48d2ade6b91f2e5a8e3f8d47c5a807d7c07；Drive 已讀回僅 owner 權限。
**真實自 ZIP 獨立解壓 R4->A52 專案後**，Godot 4.7.2 本地 Import、12 幀 GPU、F7 contact 三組再次全部 EXIT0，C:\\Users\\Public 暫存均清理。詳細紀錄：A52_ZIP_COLD_GODOT_QA_RESULT.json（私人 Drive）。
