# FS A41/A42 正式骨架動作產線增修規則（2026-11-01）

## 完全不可變的輸出
- 人形戰鬥動作 Sprite Sheet ALWAYS 3 frames, 40×40 each currently, 120×40 transparent one row. Never reintroduce A35 research 18/28 frames into actual output.
- The exact original FS actor01_1/_2/_3 45° battle view is the art authority. PixelLab V3 direction south-east, camera low top-down. Check **each** output frame F0, F1, F2, especially face planes/head/shoulders/hips/legs. One wrong orientation = Camera FAIL.
- One Q-character 1:1 head-body proportion, white-haired teal armor, unarmed at all times. Tankentai SBS overlays weapons independent of sprite sheets. Do not bake weapon/blur/particle/armor hologram inside.
- PixelLab actual provider raw frames always remain unchanged. Any selected sheet with the original A34 native F0 or F2 must say explicitly "source-anchored assembly" and cannot be represented as the provider's raw output.
- Each paid job writes Submission Lock before POST, stores original SHA/pose JSON SHA/job ID/usage, polls the exact accepted job, never uncertain retries. One provider skeleton3 frames currently cost 2 generations. Reuse real previously estimated 18-joint source rather than pay repeated /estimate-skeleton.

## 18-joint pose constraints and classification
- A40 real /estimate-skeleton returned 18 named joints NOSE, L/R EYE, L/R EAR, NECK, L/R SHOULDER, L/R ELBOW, L/R ARM, L/R HIP, L/R KNEE, L/R LEG; preserve skeleton labels and native-depth ordering. For proper camera use source actor battle view. Human-only rig; nonhuman PMD monsters must NOT reuse humanoid joints.
- Ordinary Damage: short flinch body and guard, knees/hips slight compression; hands and elbows stay near chest. **R1 FAIL:** wrist/forearms spread to the sides giving an attack/cast silhouette even when prompt says hit recoil; do not accept per-pixel output as physically meaningful merely because bones were changed. R2 wrists constrained to torso, F2 exact original guard. All three frames still subject to full art gate.
- Critic Damaged: stronger body mass transfer, shoulders/head lean, hip sinks, knees separate, final pose stays collapsed, unlike ordinary Damage which returns to guard in F2. A40 severe and A41 normal should never be interchangeable or just facial emotion changes.
- Moving to Close Attack: sprite art only models in-place approach/body step, not travel across map/battle stage. Tankentai SBS script must move actor to target; no frame-local baked world-space x/y movement. F0 neutral, F1 stride/step, F2 plant/close-ready, each 40px and unarmed.
- Waiting original static (three identical frames), Walk three unique native frames with c0,c1,c2,c1 playback via reusing c1, Dodging user-selected T4 must remain unchanged.
- Other actions (Jump, Close Attack, Ranged Attack, Magic, Victory, Death) get own pose semantics. Final FX, weapon sprites separate.

## QA Gates
Provenance and SHA → input 18-joint pose audit (feet grounded/arms plausible/head 1:1) → real PixelLab 3 png → individual F0/F1/F2 visual preview → bbox/cropping and RGBA → facing angle and anatomy → action semantic naturalness → 3-frame one-shot GIF (loop only for Walk/Idle as appropriate) → user art approval → real SBS paper-doll actor stage render/VX integration. Never mark formal game PASS before engine and user art.
A41 R1 = ERROR CLUSTER ARM_FLARE_IN_DAMAGE (documented failure).
A41 R2 = conservative usable candidate, still artistic gate pending.
A42 approach = movement is visually subtle, usability in an actual battle requires SBS worldspace movement script. No false animation PASS.
