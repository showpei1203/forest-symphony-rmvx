# PIXELLAB T-A｜CURRENT HANDOFF

## R3 2026-11-21｜私人真實原圖 Godot 4.7.2 Native GPU PROOF（最新）

### REAL DELTA (not mocked)
- GitHub public CI downloaded the exact official Godot 4.7.2 stable binary; engine-only artifact run: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44833614643
- Godot executable was securely copied to an **isolated cloud execution container**, verified version 4.7.2.stable.official.ed1daf0bf. No user PC asset repo used.
- From owner-private Drive, the actual approved A35-derived RUN Body, R2 A52-weapon-retarget RUN Weapon, transparent RUN FX by design, and unchanged A52 ATTACK Body/Weapon/FX were separately staged. All six 256x192 source PNGs and SHA hashes verified before render.
- Native renderer: OpenGL 4.5 / Mesa llvmpipe software GPU, Godot 4.7.2 official. 24/24 **actual private source** rendered 64x64 PNGs (12 RUN + 12 ATTACK), process EXIT0.
- GPU vs alpha-composite original PNG comparison: **RUN 12/12 all 0 RGBA pixel mismatches**; ATTACK 0 alpha mismatches over all 12 frames, only **59 RGB pixel differences total** in 5 frames (F5-F9), concentrated on FX overlaps; do not incorrectly claim zero RGB mismatch for ATTACK.
- Source-oriented native capture tool committed: godot_port/tests/capture_ta_actor01_private_source.gd; requires the six private PNG assets to be staged, fails closed without them. Does not expose source PNGs to GitHub. See private QA ZIP including 24 native frame PNGs, native 4× animations, source SHA/metrics JSON and native GPU log.
- **Owner-private QA ZIP (readback verified):** https://drive.google.com/file/d/1iNuBTTvC0Zyfs3yHp1Lovobu8vnMU0CF/view
- GPU RUN 1× Atlas: https://drive.google.com/file/d/13M9gUrwemvWTbYEQTXRKUEajZ_CJTTcl/view
- GPU ATTACK 1× Atlas: https://drive.google.com/file/d/1k4U4YffBJCeeGAC4fU6a4UGwqr6hb7KH/view
- Native 24-frame comparison at 2×: https://drive.google.com/file/d/18NRzyFQNEdLbRQqyzyZM17eM0ds1jOPW/view
- Native 24-frame comparison at 4×: https://drive.google.com/file/d/1qBH5X8t5zUY8gMxkqn1-xcnMpGCsK-9K/view
- Attack F7 4× GPU-vs-CPU pixels: https://drive.google.com/file/d/1Ro1jsX8wV5lu89276aDNZtoEp5VvbXWi/view

### QA UPDATED, 3 gates kept separate
- Source SHA / format / RUN Weapon 12/12 connected: **PASS**.
- Official Godot 4.7.2 **real private asset 24/24 native frame GPU rendering: PASS**, with 59 Attack FX RGB-blend mismatch pixels duly recorded. The original public native rig timing CI remains PASS (run 44833193171); that CI uses synthetic textures.
- Original approved private asset **continuous live runtime through the actual FS gameplay scene**: **NOT RUN**. This standalone proof intentionally steps 24 frames, rather than proving in-game ATB choreography and full frame-rate timing. Attack presentation F7 t=0.63sec and 70ms Hitstop had been tested in rig CI but not revalidated with private assets under actual gameplay.
- **ART: HOLD**. RUN A35 F6/F7 known pose defect and optical-flow-inbetween motion semantics remain; real pixel render cannot magically correct running motion. The user has not approved the 1× full loop.
- New PixelLab V3: **NOT RUN**; new job NONE; new model spend 0. Original A52 ATTACK artwork unmodified.
- M4 second fresh sample **NOT RUN**.
- Next macro unit: full 12-frame run newly produced or corrected with genuine PixelLab V3/Skeleton V3, correct alternating legs and approved sword, then validate full continuous in-engine gameplay motion and 0.63sec attack marker with authentic sources, ART approval. Do not return to one-pixel fixes.

---

## 2026-11-21 R2 最新增量｜完整 12 幀 RUN 持劍候選

**狀態：M1 完整候選已補齊 Body/Weapon/FX，M2 Godot ENGINE PASS，ART HOLD。**
R1 武器為透明佔位的記錄在下方保留作為歷史；R2 已有原始 A52 真實長劍素材之 12 幀獨立 Weapon atlas。

- RUN Body 沿用 A35 8 幀真實 PixelLab 素材，加 4 幀光流補間，SHA256：fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb
- RUN Weapon：A52 真實 PixelLab 長劍 F5 原樣平移（不重新繪畫或生成），對齊 12 幀的握劍 hand anchor；來源 A52 Weapon SHA256：6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b；新圖 SHA256：ff3be6c132da2d8ac285ef60db48be195549b155f22ea5ac490c86a85f120eb7。
- RUN FX 獨立透明是因為跑步時沒有攻擊特效，並非缺少武器。FX SHA256：ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7。
- 全部 12/12 影格武器有可見像素，12/12 武器和人物 alpha 區域重疊；重疊像素分別為 12、8、13、10、11、28、30、17、16、11、11、11；全部武器沒有裁切或碰邊。
- 已把方法寫成來源 SHA 鎖定的可重用建構器：godot_port/tools/ta_actor01_run_weapon.py。相同原圖重新跑出完全相同武器 SHA256；原圖更換即拒絕。
- 新 Godot 4.7.2 FSTAActorMotionRig 增加 Body/Weapon 不可為全透明的防呆驗證；RUN FX 可空。專屬 GitHub Actions 原生 + Python mock self-test 成功：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44833193171
- **驗收界線**：真實 PNG 來源、格式、武器接觸幾何已核對；公開 CI 只驗證 synthetic atlas 的 Godot engine，不代表真正私人素材 GPU 1× 動態渲染通過。A35 F6/F7 的腿部美術問題尚未解除；ART HOLD，M4 NOT RUN。
- 這輪 PixelLab Animate with Text V3／Skeleton V3 均 NOT RUN；新模型 job NONE，新增費用 0；A52 ATTACK 原始 12 幀保留不動。
- **下一個大單位**：一次生成或骨架修復 RUN12 完整換腳／原武器整組，接入 Godot 私人 6 PNG，產生真正 1× GPU 動態 QA，再評估 ART Gate，不修零碎單影格。

私人 Drive 素材 / QA（均已 upload + list/readback）：
- https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT
- RUN12 R2 Weapon：https://drive.google.com/file/d/1zSNUKTpGR5FXd8ni1RXtdLmspILHD-cU/view
- RUN12 R2 FX：https://drive.google.com/file/d/1CpTeXJFvGcZgDG6hy-mLIwUdKNEXrrVG/view
- 1× 對照：https://drive.google.com/file/d/1y1qXJeLuzaS6dGSOcbDRE5iVHZuBuOzB/view
- 3× 對照：https://drive.google.com/file/d/1xplRRIJtrTkDUtwiMLzKIK7Tjr4KMBYt/view
- 合成畫面 QA（非遊戲素材）：https://drive.google.com/file/d/1vuJGkQoBGYALtOh2i06Ci2KlaX_5_PFm/view

---
Updated: **2026-11-21 Asia/Taipei**. Owner: T-A character/motion branch.

**TARGET:** T-A / ACTOR01, 45° 3/4 battle-view white hair. **STAGE:** M1 real 12-frame candidate + M2 runtime-engineer wiring; M3 blocking artwork remains. **STATUS:** ART_HOLD (NOT VERIFIED_PASS).

## BASELINE
- Repository: `showpei1203/forest-symphony-rmvx` dedicated branch `feat/fs-pixellab-ta-actor-20261121`.
- Source A62 original approved idle SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`.
- A35 PixelLab RUN 8 source SHA256 `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`.
- A52 real PixelLab Skeleton V3 original Body SHA256 `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f`; original A52 job `094a45f9-c279-4c06-94e4-a1708a13daac`; original Handoff https://docs.google.com/document/d/1D1n1NSHW4xQS_vhkq79BkxMZr_V5xvKe/edit .
- No A54 newer source found via this round's accessible Google Drive/GitHub search; no unverified override of A52.

## DELTA: what was actually done
1. Read original approved A62 / A35 RUN / A52 ATTACK Body, Weapon, FX bytes from private Drive; computed raw sha256 and inspected candidate motion sheet.
2. **RUN12 candidate atlas** produced from actual A35 RUN8 plus 4 algorithmic optical-flow in-between frames; confirmed 12 different image frames at 64×64 and 256×192. A35 original leg exchange is visible. This is **not a new PixelLab model result**.
3. Kept existing A52 **ATTACK12** original source exact, including distinct Body/Weapon/FX, F7 at 0.63 sec and 70ms hitstop metadata. No already-passed old animation was overwritten.
4. New public *Godot 4.7.2* rig: `godot_port/scripts/animation/FSTAActorMotionRig.gd`, 3 separate sprites, 12-frame RUN and ATTACK timing and fail-closed cloud private atlas loader. Isolated `TAActor01Preview.tscn` + script to play RUN/ATTACK with staged private Drive files. No change to damage, map, old ATB, VX or main.
5. Dedicated CI regression in `.github/workflows/fs-ta-actor.yml`; 4.7.2 official download + headless engine tests, no owner-private images inside public CI.
6. Motion manifest in `godot_port/docs/handoff/TA_ACTOR01_MOTION_CANDIDATE_MANIFEST_20261121.md`, failure log in `godot_port/docs/handoff/TA_ACTOR01_FAILURE_LOG_20261121.md`.

## ARTIFACTS (PRIVATE GOOGLE DRIVE, verified cloud readback)
- Folder: https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT
- RUN body real candidate: https://drive.google.com/file/d/1_iP5j4LRtPXyd-VKpmDiotmlr-Z7_ziX/view
- RUN Weapon placeholder: https://drive.google.com/file/d/1377yLyqjLh8a5T8jnmhWIxrVdX3HbLLs/view
- RUN FX placeholder: https://drive.google.com/file/d/1p2878CC0FXnHQSR8exER_YJPVwgKH5k9/view
- 12+12 storyboard: https://drive.google.com/file/d/1tmdxXfHbt5gPyROa48kXrTWgu2PhmWfF/view
- A52 original Body/Weapon/FX remain only in their previous private Drive location.
- Source SHA256 and requested staging filenames: [Motion Manifest](TA_ACTOR01_MOTION_CANDIDATE_MANIFEST_20261121.md).

## PIXELLAB
- 2026-11-21 `Animate with Text v3`: **NOT RUN**. `Skeleton v3`: **NOT RUN**. API/model job: **NONE**. New model expense: **0**, no invented price.
- Existing A52 Skeleton V3 paid 3.0 units already completed Nov 16, **not today's expenditure**.
- Cause: available connected tools do not expose PixelLab generation API or authenticated provider action. Never call offline optical flow "real PixelLab" generation.

## QA gates, do not conflate
- **SOURCE SHA / IMAGE FORMAT:** PASS on input PNG SHA and candidate atlas 256×192 / 12 distinguishable cells. Approved source identity preserved in source selection; candidate full animation visual remains HOLD.
- **NEW GODOT ENGINE RIG (synthetic in-memory atlas):** PASS in official GitHub Actions Godot 4.7.2 run https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44830768516 : layers, loop, F7 0.63 contact once, cancel. This runner was from first rig commit. The **preview scene + rig** follow-up official Godot 4.7.2 native run also PASSED: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44831183948 (fresh editor import + scene resource import + 12-frame layered rig/timing). This continues to use **synthetic/in-memory test textures**, NOT real private Drive art.
- **GODOT NATIVE REAL PRIVATE PIXELS:** NOT RUN (no authorized private Drive-to-runner staging); original A52 prior proof does not count as new T-A candidate art proof.
- **ART:** HOLD: A35 F6/F7 remains suspect, four newly interpolated in-betweens need whole-motion review, RUN has no validated equipped sword, 12 distinct frames is not same as 12 valid run poses; ATTACK is existing approved A52 reused, not a second fresh animation.
- **M4 REPRODUCIBILITY:** NOT RUN.

## FAILURE LOG / blocker gate
- B1 Major / ART: RUN weapon layer transparent placeholder, identity/equipped weapon **not preserved**. Need real separate weapon consistent with source.
- B2 Major / ART: A35 RUN F6/F7 previous deformation not resolved; new interpolation does not repair existing source.
- B3 Major / AUTH: fresh PixelLab v3 unavailable in current tool connections; no new provider-backed run.
- B4 Major / TEST: private source image staging not present in public GitHub CI, cannot claim genuine private-art Godot GPU PASS.
- No micro-pixel fine-tune cycles. **0/2** repeated minor-fix loops.

## NEXT_MACRO_UNIT
Generate **one entire native PixelLab Text v3 RUN12 cycle** grounded in original A62, selecting correct left/right boot poses, 45° view and separate sword all at once; if this fails twice, switch to Skeleton V3 keyed limbs. Replace only RUN candidate on T-A branch/private Drive, then stage six legal atlases into isolated Godot preview, capture actual 1× GPU animation, verify 0.63 attack contact and artwork side-by-side; then validate second motion/character for M4. Do not revert to VX or rewrite unrelated game systems.

## STORAGE / SAFETY
Only T-A branch GitHub text/GDScript and owner-private Drive binary sprites/QA. No user's PC new repository. Existing baseline unchanged, not merged into main. Google Drive folder list READBACK passed. No PixelLab paid retry or API secrets.
