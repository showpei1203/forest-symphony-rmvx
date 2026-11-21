# PIXELLAB T-A｜CURRENT HANDOFF


## R6｜2026-11-21｜修復「只有劍動、頭與軀幹不動」根本缺陷（當前最新）

**TARGET:** T-A / ACTOR01. **M1:** complete ATTACK12 articulated-candidate. **M2:** genuine Godot 4.7.2 private-source 181/181 GPU frames PASS. **M3:** ART HOLD, requires whole-action art review and possibly genuine Skeleton V3 frames. **M4:** other motion/character NOT RUN.

### User correction is the new blocking design authority
User identified the actual old systemic defect: the A52 12-frame attack primarily moved arm/weapon, while white-haired ACTOR01 head, shoulder and chest stayed nearly locked. Earlier R3-R5 invested in run/gpu testing while silently reusing this flawed ATTACK source. STOP accepting technically runnable but still static-torso attack as success.

### Implemented this round
- Constructed new R6 **entire 12-frame ATTACK** in an isolated working area, not just single F7 pixels. Each frame uses original approved A52 artist-authored pixels but reposes head/shoulder/chest over waist-anchored nearest-neighbor articulated warp. Windup F1-4 backward, F5 transition, F6-F8 forward head-shoulder-followthrough, F9-11 recovery. No new face, no change to actor ID, original equipment, 3/4 camera or base art.
- Added source weapon wrist-following shifts and fixed **source-existing detached late recovery sword F8-F10**. The actual A52 F7 FX is unchanged. RUN continues to use previous separate R5B candidate. Original A52 originals are unmodified, with source SHA locks. No PC repo, no edits to other branches or gameplay damage authority.
- New public GitHub exact-source-locked **R6 generation script + static-head/chest regression gate**, with dedicated CI hook. The static geometry gate is *necessary*, not user ART approval. The full Python production script and authentic native QA source are also bundled in private ZIP.
- Full Godot 4.7.2 60Hz **R5B RUN→R6 ATTACK** original-source timeline with **181/181 native GPU readbacks EXIT0**. A52 original GPU-vs-R6 GPU side-by-side slow GIF and 60Hz MP4 are included; both Godot, not a composite CPU substitute. Existing F7 0.63 sec frame index and combat source authority remain unchanged. Actual integrated combat FSBattle queue still NOT RUN.

### Verified R6 source and artifacts
- Original UNMODIFIED approved A52 ATTACK Body SHA256: a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f
- Original A52 weapon SHA256: 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b
- Original A52 FX SHA256: 46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c
- R6 new Body candidate SHA256: 573a1a707bee819408e3e75c24a07387dbb56e56ab172a04f9d36943c3b3e53d
- R6 new Weapon candidate SHA256: 47d0623084372068f38f30ceedf3cefe232b8a41927f90c38604af43b54755b6
- R6 FX independently layered SHA256: ab805496de7fdab088a01458e4825f28afae868ba9e4650464086a29cbdf196a
- All three 256×192 RGBA, 12×64×64, Body/Weapon/FX. F0/F11 exact original poses, feet y51..63 100% unchanged.
- At original A52 F7 / presentation time 0.630s: **293 head-region changed pixels** in y14..31; **260 torso-region changed pixels** y32..44; **567 total body changed pixels**; **0 changed feet pixels**; F7 approved A52 attack FX unchanged. Whole original F7 head centroid moves approximately 4.478 pixels and chest centroid 1.308 pixels. Geometry change proves the old static head/torso defect was addressed, NOT art naturalness.
- F8/F9/F10 original A52 detached recovery sword fixed with -3/-2/-3 px source-blade retarget; 12/12 frame source body/weapon contact when weapon is visible (10 weapon-on frames) by alpha overlap. F0/F11 no drawn blade as in original.
- Stage: **R6 candidate from original A52 procedural articulated torso/head rotation / vertical squash / shoulder twist**. Not a new PixelLab image generation; NOT an actual new skeleton-authored frame. Price/spend 0. R5B RUN remains separately ART HOLD; no changes to original A52, main, or phase1 battle.
- **Real source Godot 4.7.2**: Official executable 4.7.2.stable.official.ed1daf0bf, native OpenGL 4.5 Mesa llvmpipe, 181/181 60Hz frames EXIT0, comparing A52 original GPU versus R6 candidate GPU at exactly same action ticks. This is standalone source-private engine QA, NOT full integrated FS ACT/ATB gameplay.
- Godot R6 QA ZIP **196 files, 813,320 bytes, ZIP CRC PASS**, containing 181 genuine native PNGs, the 60fps A52-vs-R6 comparison MP4, slower original/modified native GIF, 1×/4× comparison, private source manifests, detailed verification JSON, logs and generation script. SHA256: 82998fac77a77eaa5894f4625c0a1dfadf72c01f50db84f3c258f550dd303f0d .
- Private Drive ZIP: https://drive.google.com/file/d/1OL6d8d8vzemJmPaDxERaxGc1l3KZd5wa/view
- Direct private Drive slow original-vs-new real Godot GPU GIF: https://drive.google.com/file/d/1DiltvPJCGjQgJtKBBPFIQTobvXULedk0/view
- Private 4× original-vs-new keypose comparison PNG: https://drive.google.com/file/d/1zaxPU7UY0GHA3l4TRqj7k9djVXX0A-AE/view
- Private R6 Body: https://drive.google.com/file/d/1ukhU0eg3L__ZX6gvmx6tx-UGIG9vWm0W/view
- Private R6 Weapon: https://drive.google.com/file/d/1EPKsnCVOjYSq2syRdloG4HIVmEZ9fx2w/view
- Private R6 FX: https://drive.google.com/file/d/1gZcS4kWCIdEcKVT7otttCRDPxWjgUVdb/view
- Reproduction generator in public text-only GitHub: godot_port/tools/ta_actor01_attack_r6_fullbody.py, source SHA-locked. New regression gate: godot_port/tools/ta_actor01_attack_body_gate.py; must block static-head/static-chest instead of treating engine frame count as animation quality.
- **VISUAL ART HOLD** until original identity/proportions, deliberate rotation, sword followthrough, upper/lower torso silhouette and 45° angle are reviewed. A procedure modifying 293+260 pixels is a necessary geometric advance, NOT a sufficient full-body high-quality sprite-sheet art PASS.

### Current independent gates
- Original A52 SHA and R6 source actor identity, 12×64×64 sprite format, head/torso actual changed-pixel QA, feet pivot stable, legal original weapon and effect layers: **PASS as candidate geometry**.
- Real staged R5B RUN + R6 ATTACK Godot 4.7.2 native 181/181 GPU capture: **PASS**; GPU alone never means good animations.
- Public GitHub automated head/torso regression: **pending until R6 CI conclusion checked**.
- Art Gate: **HOLD**, because per-pixel nearest-source rotation can still visibly deform head/torso or not have authentic hand-drawn twist. User visual approval NOT RUN. A52 remains fallback, do not promote R6 to official canonical sprite yet.
- PixelLab v3/Skeleton v3 new job: **NOT RUN**. API connector unavailable; no fabricated model job or price.
- NEXT COMPLETE UNIT: evaluate R6 full animation **as a whole** with approved ACTOR01 45° reference. If pose warp is judged artificial, author a complete **full-body 12-frame Skeleton V3 sequence**, then new real native gameplay ACT animation QA; stop revisiting leg-run/weapon-tip polish instead of actual full-attack posture.

---


## R5B｜2026-11-21｜完整 RUN12 原圖重編＋A62 中立步態橋接＋181/181 真 Godot 4.7.2 GPU（目前最新）

**TARGET:** T-A ACTOR01. **M1:** New full run candidate R5B created and separately preserved. **M2:** Standalone owner-private R5B 60Hz real-source GPU proof PASS. **M3:** ART HOLD; natural gait and in-game FSBattle remain NOT RUN. **M4:** Second different character/action NOT RUN.

### REAL delta since R4
1. Examined actual original A35 8-frame source: A35 F6/F7 had earlier ART HOLD with exaggerated stride. **R5a** regenerated all 12 by retaining authentic F0-F5 + 6 code optical frames, but direct F5→F0 transition had **86 alpha silhouette difference pixels**, worse than R4 original seam **20**. R5a was **REJECTED as a gait loop**, not promoted.
2. Changed the **complete-loop strategy** to **R5B**: 6 UNMODIFIED A35 original real PixelLab poses F0..F5 + 1 original approved A62 IDLE neutral in the foot-switch portion + 5 CV2 nearest-source-color algorithmic in-betweens. Output Body 256×192 RGBA 12 UNIQUE poses, weapon from original A52 F5 12 rigid hand-targeted original blade (independent layer), RUN FX empty by design. **Still not new PixelLab creation**. R5B seam alpha silhouette delta **62** vs original R4 **20**, so its continuity isn't approved! There may be an unnatural standstill beat around A62; ART HOLD.
3. Original A52 ATTACK12 six private inputs preserved SHA exact. New self-contained deterministic source-locked rebuild tool: godot_port/tools/ta_actor01_run_r5b.py. Anti-source-swap SHA tests, 12 independent frames. R5B real native GPU capture script: godot_port/tests/capture_ta_actor01_r5b_private.gd. These T-A-only code files and CI trigger added without modifying main, phase1 gameplay, T-B or T-C.
4. Actual owner-private **Godot 4.7.2 stable official** + Xvfb Mesa llvmpipe GL compatibility rendered **181/181 native 64×64 PNG frames** with R5B RUN x2 followed by unchanged A52 ATTACK. 24/24 distinct (motion,frame) pairs. Owner-source native RUN GPU vs Pillow source composition **0 RGBA pixel mismatches** across 12 unique frames; ATTACK **0 alpha pixel mismatches** and **59 RGB composite mismatch pixels** across 5 of its 12 unique frames, matching R3 known FX blending. This proves R5B renderability; time sequencing was **standalone source-based playback**, NOT the actual FSBattle live ACT queue.
5. Engine CI: link to current workflow run https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872901830 ; **check its actual conclusion before claiming CI PASS**. The owner's original private GPU capture was independently executed, EXIT0, not public CI. Do not publish original PNGs in public GitHub.

### SOURCE SHA / MANIFEST
- A35 RUN8 original PixelLab: ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b
- A62 approved idle (bridge): 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e
- A52 original sword: 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b
- R5B new Body 12 frames: 122f306454157084115b8348d3c4b6af7aceadbe096b64a3bd28557e5ea34027
- R5B new Weapon 12 frames: c829788d1ffe309488a9be6f9d8d937932b5b9fb82d89a12e192770a82dd68cd
- R5B RUN FX transparent by intentional design: ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7
- A52 attack Body/Weapon/FX source unchanged from R4. Official build uses source PixelLab generations from historical A35 and A52; this round new PixelLab Animate Text v3 / Skeleton v3 **NOT RUN**. New paid job NONE, cost 0.

### PRIVATE owner-cloud artifacts, upload + folder readback verified
- R5B actual Godot 4.7.2 continuous 60Hz MP4, directly viewable owner-private Drive: https://drive.google.com/file/d/1OUi9zMAseCKKYnk1yyN1yGH0SOmriVuP/view
- R5B original PNG Body: https://drive.google.com/file/d/1ftppVAF6LGb-0R9u0AR1qqXbma9M_muw/view
- R5B original PNG Weapon: https://drive.google.com/file/d/11kEvmrDbMe__OncpMdXx7GNh7uJdOVvO/view
- R5B 24-frame native 4× PNG storyboard: https://drive.google.com/file/d/1DTlmHDumz1EpPmhQkkYPEEfAZvGWGL0y/view
- R5B **full actual QA ZIP** (193 entries, 181 GPU frames + 60fps MP4 + 30fps GIF + logs + standalone source code + SHA manifest, CRC PASS): https://drive.google.com/file/d/1iGvTqTxRpyHY--TgXdAoeRt5iOHvNpAq/view . Local ZIP SHA256 1e1d5caacfd1afc7ddd119e134017e288c26ce1d4299e76d6cf46a9877822651 .
- Folder readback: https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT . Original, approved A52 assets are retained in original private Drive locations. No user PC project or file touched.

### SEPARATE QA GATES and NEXT MACRO
- **SOURCE SHA PASS**; 12 unique frames and separate Body/Weapon/FX, 256×192 dimensions PASS.
- **Standalone private owner-source Godot 4.7.2 GPU PASS 181/181**, with nonzero ATTACK FX RGB blend differences transparently recorded.
- **ART HOLD**: the new complete-loop strategy replaces bad A35 F6/F7 but R5B neutral bridging may stop running and has 62 silhouette seam pixels, so it does NOT count as a corrected professionally approved RUN12. PixelLab generation API not connected, no fresh model-backed 12-frame run created. The user's final visual approval NOT RUN.
- **Actual Godot FSBattle ACT queue + this new R5B** NOT RUN, do not conflate standalone playback and battle integration.
- **NEXT_MACRO_UNIT:** stop source-image optical-flow redesign now. Using a connected, credentialed PixelLab Animate Text v3/Skeleton v3 route, make a genuine independent 12-frame left-right alternating cycle from approved A62, preserving identity, separate original A52 sword and 45° angle; one whole candidate -> Godot source GPU native -> final human ART gate. If no PixelLab provider available, mark the blocker, do not falsely declare new generation or endlessly repeat mid-frame arithmetic.

---

## R4 2026-11-21｜真實原始素材 60Hz 連續 Godot 4.7.2 渲染（最新）

**TARGET T-A ACTOR01. M1=complete candidate; M2=isolated real-source full-motion native proof PASS; M3=ART HOLD; M4=NOT RUN.**

### REAL DELTA
- New Godot actual sequence controller: godot_port/scripts/animation/FSTAActor01ContinuousShowcase.gd . A standalone scene at godot_port/scenes/ta_actor01/TAActor01ContinuousShowcase.tscn allows 12-frame RUN for two complete loops, then preserved original A52 ATTACK12. Three Body/Weapon/FX layers. Source exact private SHA locks. No gameplay HP/MP or battle queue authority mutation, no changes to T-B/T-C/main/VX/A52.
- Synthetic native Godot 4.7.2 CI, including full RUN x2 → ATTACK, one-shot visual contact at F7 / attack-local 0.630sec, cancel, big delta: **PASS** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44837631706 . Code commit f6136606a50457158139d0bd174d21cd0caf7adf.
- Actual private owner-source native Godot capture was executed SEPARATELY in isolated cloud using official Godot 4.7.2 and Mesa llvmpipe OpenGL 4.5: **181/181 PNG** 64×64 real rendered frames, 60Hz deterministic stepped 0...3.0sec, both motion frame IDs 0..11 seen. Real six original/candidate private 256×192 PNG inputs SHA verified, no private images uploaded to GitHub.
- RUN loop x2 → ATTACK at first 60Hz capture t=1.933333sec; ATTACK completes at t=2.983333sec. Original F7 presentation contact emits ONE event exactly 0.630sec into attack; first 60Hz frame observation at global 2.566666sec, tick154. This is one stable single presentation clock, not proof of full live FSBattle queue choreography.
- True GPU pixels vs original CPU alpha composites: **0 alpha mismatch pixels / 181 frames**, 382 RGB blend differences total (attack FX overlays). Do NOT claim exact RGB equality. User-approved art remains ART HOLD.
- Exact source SHA: RUN Body fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb; RUN Weapon ff3be6c132da2d8ac285ef60db48be195549b155f22ea5ac490c86a85f120eb7; RUN FX ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7; ATTACK Body a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f; ATTACK Weapon 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b; ATTACK FX 46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c.
- Source-locked private capture script: godot_port/tests/capture_ta_actor01_continuous_private.gd. Capture proven at real source, unlike public synthetic CI.

### VERIFIED CLOUD ARTIFACTS
- Private Drive ZIP **181 native PNG frames + timeline JSON + actual source 60fps MP4 + annotated 4x GIF + QA + Godot logs + reproduction scripts; ZIP CRC PASS**: https://drive.google.com/file/d/1W7WHwgtAGFKaRE2RR_SPdWV4AKf3rOxk/view
- 60Hz native selected frames with RUN loops & F7 contact at tick 154, owner-private QA: https://drive.google.com/file/d/1LBFpHdDNE7MHVFbXBeFYNEbT_skqIeDv/view
- Private folder: https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT . Upload/readback verified. No user PC asset repository.

### GATES / IMPORTANT LIMITATIONS
- SHA provenance, 12-frame atlas/independent layers, true GPU render 181/181, standalone full-motion timing and once-only F7 0.630sec **PASS**.
- Formal existing FSBattle ACT action queue control and integrated game battle: **NOT RUN**. The source gameplay branch already contains FSBattleActor01Presenter; read-only observed, deliberately not overwritten to avoid conflict.
- A35 original RUN F6/F7 alternating boot stance remains **ART HOLD**, four optical-flow inbetween frames do not constitute new model art. User ART acceptance NOT RUN.
- PixelLab Text v3/Skeleton v3 new job **NOT RUN**, model charge **0 new units**, no fabricated job. M4 second character/motion **NOT RUN**.
- NEXT MACRO UNIT: genuine PixelLab v3 or Skeleton v3 FULL corrected RUN12 grounded in approved white-haired 45-degree Actor01 and A52 sword; after visual validation, source-based active FSBattle queue hookup and owner ART acceptance. Do not waste loops on individual pixel polish.

---

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
