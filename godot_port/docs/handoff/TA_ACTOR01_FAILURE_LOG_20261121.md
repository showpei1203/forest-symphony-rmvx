# T-A Failure Log / 2026-11-21

## R11B new failures / gates 2026-11-22

TA-19: R11 source-fusion created disconnected three-pixel foot artifact (x31 y46-48) in F0 and F8-F11, total 15 pixels. R11B removed ONLY components <=3px and blocks larger detached body. 12/12 remaining frames exactly one 8-connected human silhouette. PASS.
TA-20: User prohibits ALL weapons. Independent Weapon and FX atlases full transparent, actual Godot source verified 0 opaque pixels, zero strange guide signs or blade art. PASS.
TA-21: Official LPC original has only FOUR CARDINAL angles. R11B front/right pixel-source fuse still shoulder and depth artifacts and a mostly static expression, NOT artist-approved 45-degree sprite. ART HOLD, requires genuine full-body pixel redrawing, not new rubber arms.
TA-22: Official Godot 4.7.2 Windows 60Hz real input 73/73 native OpenGL frames, all 12 motion IDs observed, visual contact F7 0.630 once, all 12 CPU-vs-GPU source RGBA pixel diffs ZERO. Engine PASS only, live FS gameplay NOT RUN. QA ZIP owner-authorized E: 91 members, CRC PASS, SHA256 7a878c581342faecc46ed56a224c52c61e46a87d0351f854ea6e0dac180755ef.
R11B source SHA fcd2c7ee0c16acca95cb1497e75514c1ec9fe0c7907e380ce01514ea24540018. Old A52 and R8/R9 remain untouched. No PixelLab V3 API job/cost.

---


**CI gate note / current validated commit:** GitHub first public CI run 44918945179 FAILED specifically because the source-free R9 --self-test module imported a private default /mnt/data output folder at top level on hosted runner. Fixed by deferring OUT.mkdir to production main(); neither private art nor generated output changed. New GitHub public Godot 4.7.2 CI: **SUCCESS** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44919186389 . Geometry native cloud proof remains separate from public synthetic CI. Current private R9 authority is https://docs.google.com/document/d/19vnoZ8Kf5c8Fhxtn8JPXZdiCIEiNsIOJ/edit .

## R9 2026-11-21 | USER BLOCKERS, actual root cause & attempted repair

- **TA-14 R8 REJECTED: Rubber arm**. Root cause explicit R8 `animated_body()` method drew arbitrary-length shoulder→elbow→hand lines using unbounded pose landmarks, no segment-length constraints. R9 redesigned to circle-intersection **10px/10px** fixed IK and unreachable target hard failure, not stretched arms. Public source-free test plus actual private 10 active frames PASS. **Structural pass only; all-art HOLD**.
- **TA-15 R8 REJECTED: invented gold badge/logo**. Root cause R8 injected a gold ring and shiny shoulder emblem around the IK shoulder. R9 removed all added gold ring/cross markers, keeps only original A52 costume pixels. Original ACTOR01 true shoulder costume details not erased. Human ART HOLD.
- **TA-16 Detached crescent arc**. Root cause original A52 FX F7 crop does not spatially match newly retargeted F7 sword blade; previous R8 showed it floating like a symbol. R9 disables detached source FX atlas but preserves original file SHA and F7 0.630 sec timing event. Correct source-based hit FX **NOT YET AUTHORED**. This is an explicit ART blocker, not a PASS claim.
- **TA-17 Sword stretch/clipping**. R8 `reorient_sword` used affine matrix with `dl/bl` scaling, which varied the original sword length as user noticed. R9 source sword uses rigid rotation, no scale. Candidate weapon has no out-of-bounds frame and 0 detached tiny components; **geometric pass**.
- **TA-18 Natural arm/shoulder acting**. R9 fixed bone geometry currently remains visibly stylized/capsule-based and could look stiff. **ART HOLD** until a human-approved full-frame rigid authored arm and face silhouette is completed. Godot native 12/12 plus 67/67 timeline is an ENGINE proof, not an ART approval.
- Native source ZIP https://drive.google.com/file/d/1oEKI-SDfJ05D-RoenJrGR75i1F2q2O2D/view ; source code in T-A branch; no private PNG in public GitHub; no new PixelLab call.

---


## R8 USER REJECTION → WHOLE-BODY SOURCE SWITCH (latest, 2026-11-21)

- **TA-14 R7 rejected by user / P0 ART**: original R7 procedural high-guard pose still lacks coherent shoulder/elbow/hip/foot integration. DO NOT recycle R6/R7 arm-only deform as another complete animation. New authority is original LPC pose source plus Actor01 unchanged visual DNA. Status R7 REJECTED, not V7 Art Pass.
- **TA-15 authentic LPC source reacquired / resolved**: P1C 11 independent source slots ×24 cardinal frames 128px, ZIP source SHA `5fbfc15c36e122d7bd38dcaafe2ca03f53e83330bd72338c1d6be18a2f3de582`; P1 18-action composite SHA `e6d57dbb38e86a80001edd676754b4b432d710fd481841d531c181a97f9de0c7`. ALL true source files examined; cardinal only, no direct native 45°. Missing 147-slot original remains BLOCKED; no mock source.
- **TA-16 R8 first new complete 12-pose ART HOLD**: Real LPC right-facing slash silhouette/hand/feet measurements used as pose references, high-guard 45° bridging artist-specific, original ACTOR01 Body/Weapon/FX identity. Three native-ready 256x192 atlases and true 12-key frame native comparison delivered. R8 elbow/sleeve procedural geometry remains stiff and stance shift needs artist-level review. This is **NOT** PixelLab v3 generation, **NOT** a newly approved visual asset; don’t mistake source-locked procedure for aesthetic acceptance.
- **TA-17 R8 native evidence PASS in isolation ONLY**: official Godot 4.7.2 Mesa Xvfb, 12/12 key pose, 67/67 real 60Hz source frames, exactly 1 visual contact at 0.630 sec, 0 alpha mismatch 56 RGB difference vs CPU, true sources staged private. Full 93-member ZIP https://drive.google.com/file/d/1l0BLyGjJYzREVdmuDtp1SvekLGEGv4YO/view. Original FSBattle / ATB real in-game presentation NOT RUN; R7 old is rejected, no main merge.
- **STORAGE**: formal Drive+GitHub R8 authority written and read back, all 3 private atlases/4× montage/full ZIP saved owner-private Drive and folder readback verified; public Github policy/manifest/failure/handoff T-A branch only. No user PC output. Next repair must replace whole action with artist/Skeleton-v3 source-backed keyposes, not another tiny animation tweak.

---


## R7 user-critical failures addressed (latest)
- TA-10 R6 expression stiff: F1-F10 new eyebrow, gritted mouth, shouted open mouth and recovery; 10/10 real face pixel changes, ART HOLD pending 1x owner signoff.
- TA-11 R6 backswing amplitude too small: R7 F4 right hand y19 (about 18px higher than R6) and ACTUAL native sword top y5 (R6 y15; 10px more overhead). Source-proven body/weapon connectivity, no crop. Artistic naturalness HOLD.
- TA-12 first R7 draft extra turquoise swing arc across hair: rejected in first full-cycle inspection, removed from final candidate. Original A52 F7 impact FX preserved.
- TA-13 --headless Dummy renderer returned null GPU texture, frame0 FAIL. Switched same genuine Godot 4.7.2 to Xvfb/Mesa OpenGL4.5, 181/181 PASS. Do not misreport the failed trial as pass.
- Model API: fresh PixelLab V3 NOT RUN, cost 0. 64px face readability and full live FSBattle ACT integration remain HOLD/NOT RUN separately. Verified final Drive ZIP https://drive.google.com/file/d/1RLpMnw_RwgCq3pBNbaI9CvUN8fPV82hn/view
---



## R6 root-cause diagnosis and non-fake repair

**TA-13 / MAJOR ART BLOCKER (user reported): A52 ATTACK visually moves arm/weapon but does not significantly articulate head/shoulders/chest.** This systemic flaw survived earlier R3-R5 GPU/CI PASS because those tests only checked timing/texture format, not whole-body motion.

- R6 corrective route: one new complete 12-frame ATTACK, hip-anchored head/torso rotations from genuine A52 artist pixels, multiple keyposture phases instead of a F7 single-frame micro-adjustment. Original Body/Weapon/FX SHA preserved. Original impact FX F7 and frozen 0.630sec unchanged.
- Measured F7 candidate delta: head y14..31 changed 293 pixels; chest y32..44 changed 260; total Body 567; unchanged boots y51..63. Original arm/weapon-only problem addressed at measurable silhouette level.
- New automatic anti-regression guard in godot_port/tools/ta_actor01_attack_body_gate.py rejects static head or static chest at F3/F4/F7/F8; synthetic CI only tests the guard, actual R6 private QA is in Drive. It MUST NOT be promoted to independent ART PASS.
- R6 181/181 native GPU PASS; before A52 native and new R6 native comparison is preserved. Real PixelLab Skeleton V3 not available; output only procedural retarget. New model expense 0.
- New R6 candidate may still look mechanically deformed/too much head pitch because it is nearest-neighbor source warp, not physically reauthored torso pixels. **ART HOLD** awaiting entire-motion review. If rejected, next route must be proper PixelLab Skeleton V3 or artist-specified 12 complete full-body keyposes; no more engine-only QA being presented as artistic progress.
- Private zip: https://drive.google.com/file/d/1OL6d8d8vzemJmPaDxERaxGc1l3KZd5wa/view (196 files, ZIP CRC PASS). Original body source never overwritten. Other T-A R5B RUN defects remain separately logged.

---


## R5B follow-up (latest 2026-11-21)
- TA-10 / **ART BLOCKER / R5a REJECT**: R5a reconstruction discarded original A35 suspect F6/F7 and retained F0-F5, but direct F5->F0 optical loop produced **86 silhouette-alpha seam mismatches** vs R4 older 20. Exactly **1 whole-motion strategy attempt**, then switched to A62 foot-neutral bridge (R5B). R5a was not sold as an approved result.
- TA-11 / **ART HOLD / R5B candidate**: Source-locked, 12 unique poses (6 authentic PixelLab F0-F5 + 1 approved A62 idle + 5 non-model optical transitions), all 12 weapon overlays physically contact Body and are not cropped. New seam **62 alpha mismatches**: better than R5a, still worse than old 20; A62 transition may cause an unnatural stopped beat. **No claim of motion-art PASS or full model-created RUN12**. Do not continue optical-loop micro-tuning indefinitely; a real PixelLab / skeleton model approach is next.
- TA-12 / **NATIVE R5B PASS**: Actual owner-private six sheets rendered 181/181 frames using official Godot 4.7.2 Mesa OpenGL in isolated cloud. RUN native vs source composited image **0 RGBA differences** (12 frames); ATTACK **0 alpha mismatches and 59 RGB overlap/blend differences** (12 frames). 24 unique native (motion, frame) combinations. Public CI synthetic source SHA lock run https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872901830 . Native ZIP https://drive.google.com/file/d/1iGvTqTxRpyHY--TgXdAoeRt5iOHvNpAq/view.
- TA-03 PixelLab API **NOT CONNECTED**, new job NOT RUN, new charges 0. TA-08 actual live FSBattle R5B character+ACT state bridge NOT RUN. M4 second different actor/action NOT RUN.
- Most important distinction: **new 181 native frames can make an imperfect gait clearer, not automatically make it good**. Preserve ART HOLD and do not merge into accepted A52.

---

## R4 blockers and native results

- TA-04 PRIVATE GPU CONTINUOUS PROOF: **RESOLVED** for standalone scene. Actual original private six atlases in Godot 4.7.2, 181/181 frames continuous 60Hz capture, separate from synthetic CI. Private ZIP: https://drive.google.com/file/d/1W7WHwgtAGFKaRE2RR_SPdWV4AKf3rOxk/view .
- TA-08 NEW INTEGRATION GAP: Existing official FSBattle real action queue live scene + original actor approach/attack choreography not yet wired from T-A independently; main phase1 branch has a presenter already. **NOT RUN** without touching other's branch.
- TA-09 NATIVE BLEND DIFFERENCE: Real native 181-frame alpha mismatch = 0; 382 RGB mismatches across attack FX blends and repeated frames. Non-blocking for independent motion timing, record real QA rather than overclaim zero.
- TA-01 RUN F6/F7 pose + four non-PixelLab optical-flow intermediates: unresolved **ART HOLD**, requires alternate full-run PixelLab/Skeleton v3 model. No microscopic repeated edits.
- TA-03 PixelLab provider credential/API not accessible; new PixelLab job **NOT RUN**, new cost 0. A52 attack source unchanged, source SHA verified.
- M4 second separate actor/animation **NOT RUN**. Original 45° identity, run/attack 64px and multi-layer restrictions preserved.

---

## R3 Native GPU evidence and blocking gates

- TA-04 R1 'no private Godot GPU proof': **RESOLVED for per-frame native GPU rendering**. 24 actual source frames imported and rendered in official Godot 4.7.2; 24/24 PNG generated, EXIT0. **Still NOT RUN: full original private continuous gameplay loop/ATB hit-time integration.** Owner-private QA ZIP https://drive.google.com/file/d/1iNuBTTvC0Zyfs3yHp1Lovobu8vnMU0CF/view
- TA-08 FX color delta: 59 RGB pixels across ATTACK F5-F9 differ from CPU Pillow composite (mainly alpha blend differences), 0 alpha mismatches; nonblocking for silhouette, flag for 1× art inspection. No unverified claim of zero pixel difference.
- TA-09 official engine retrieval: earlier download from GitHub in local container failed due outbound network restriction. Switched strategy to **public GitHub Actions engine-only artifact**, downloaded through authorized connector, no user PC changes. One strategy change, **RESOLVED**.
- Remaining blocking art: A35 RUN F6/F7 original defect, new V3 RUN not yet generated, 4 optical-flow frames awaiting motion art QA. Zero frame-only cosmetic repair loops. Status ART HOLD, not an engine blockage.

---

## R2 後續驗證及阻斷變化（下面保留 R1 歷史問題表）

- TA-02 R1 空白 RUN Weapon：**幾何問題已解除**。R2 已建立 A52 真實來源剛性手部對位的 12 幀 Weapon，12/12 與 Body alpha 相接、12/12 無裁切，像素 SHA 可重製。**整體美術／持劍姿勢仍 ART HOLD，未完成原圖原生 Godot 動態驗收**。
- TA-07 透明武器錯誤通行：Godot rig 現新增 Body/Weapon 可見像素驗證，4.7.2 headless CI PASS（mock images）。https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44833193171
- TA-01 原 A35 RUN F6/F7 腿部缺陷：**未修，阻斷美術 PASS**。
- TA-03 無可呼叫 PixelLab V3、TA-04 私人真正 GPU 原生 1×、TA-05 A54 最新權威：**仍待補，不能冒稱 PASS**。
- 工具第一次本地 self-test 曾因 grayscale overlap Image 沒有 A channel 失敗；已改用依圖像頻道取 alpha / histogram 計數，重新跑 12/12 synthetic + 12/12 真來源自動檢查皆 PASS。紀錄 1 輪，未在細節無限迴圈。
- 新增 PixelLab 付費 0，新 job NONE；已通過的 A52 ATTACK 不重做。

---
Only record genuine issues; never conflate construction QA with ART PASS.

| ID | Gate | Severity | Finding | Attempts | Next macro action |
| --- | --- | --- | --- | --- | --- |
| TA-01 | ART | BLOCKER | Old A35 RUN frame F6/F7 pose previously on ART HOLD; optical flow preserving those poses cannot eliminate source pose drift | 0 new repair iterations | Rebuild one **entire** RUN12 by PixelLab Text V3 with reference identity, use Skeleton V3 keyed gait if needed |
| TA-02 | ART | BLOCKER | RUN candidate independent Weapon/FX atlases are all-transparent **placeholders**; no sword-to-hand contact proved during run | 0 | Full RUN12 complete equipped sword layer at 45° view |
| TA-03 | MODEL | BLOCKER | No PixelLab paid endpoint available to this agent; fresh Text V3/Skeleton V3 generation NOT RUN; additional cost 0 | 0 | Obtain connected PixelLab provider authority or run same exact source in authorized provider tool |
| TA-04 | NATIVE ART | BLOCKER | New native GitHub CI has synthetic memory atlas proof, not original Drive asset runtime/GPU screenshot | 0 | Secure private, authorized Godot asset staging for 1× screenshot/video and contact play |
| TA-05 | SOURCE | NOTICE | A54 updated handoff not located by this round's Drive/GitHub name/path searches | 0 | Confirm A54 authoritative link before replacing legacy approved baselines |
| TA-06 | ENGINE | RESOLVED | 12-frame rig timing/3-layer structure needed independent validation; added Godot 4.7.2 CI; first run success | 1 | Keep CI green after preview scene and do full original-art validation later |

Nonblocking isolated pixels/soft shadow tuning: 0 cycles; no endless single-frame loop. The demonstrated initial RUN frame count and technical 256×192 atlas check are not art acceptance.
