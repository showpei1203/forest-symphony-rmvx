# FS CURRENT_HANDOFF｜A14 F0 姿勢條件化輸入（2026-11-08）
> **ACTIVE PROGRESS:** [FS 唯一現行施工規範](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) 不變。本次是 A14 的實際輸入與生成失敗紀錄；A11、A13 的內容保留為歷史。**沒有已通過的新增動畫！**

## A14 真實交付與否決
- 第一張白髮 Actor01 F0 SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，原圖 48×48 RGBA，來源位元保持原狀；A62 Run 144×48 參考第一影格與 F0 逐像素相同。
- 供 PixelLab Skeleton v3 使用的**輸入包**：RUN、WAITING 各三組人形 18-joint 姿勢，透明 pose-only PNG、F0 局部疊圖、64px padded source（偏移 8,8）與 48px 回裁檢查；各動作 playback Run 0,1,0,2 / Waiting 0,1,2,1。
- 私人 ZIP `FS_A14_POSE_CONDITIONED_PIXEL_LAB_READY_INPUTS_20261108.zip`，26 檔、47,164 bytes、SHA256 `20f37ba85922d7c679a318d8fc210c67a46bd7a3ebfd552d077ea7d98990d8b0`。owner-only Drive 限制 Binaries，已上傳、原檔與 47,164-byte readback verified；私人 PNG 不放公開 GitHub。
- 完整 private scripts `build_a14.py` 和 `validate_and_export.py`，真實本地 4/4 PASS。公開 `tools/asset_factory/a14_f0_pose_provider_gate.py` ＋六個合成負例測試。
- 在此對話對一般 ImageGen 的**三次實際生成**，輸出都錯誤地變成棕髮 elf 與流程資訊圖，不能當白髮 Actor01 的 48px Sprite。三次 **IMAGEGEN_REJECTED_WRONG_ARTIFACT / WRONG_IDENTITY**，不以修改圖片尺寸冒充通過。這不是 PixelLab v3 的實際測試。
- PixelLab 2026 v2 docs 支援 `animate-with-skeleton-v3`，可由 F0 與逐格 Skeleton 生成 3–15 幀，但本對話**沒有 PixelLab 可直接使用的已授權工具／token/扣額上限**；尚未呼叫 PixelLab，工具參數仍需在供應商實際 API Schema/estimate-skeleton 確認，不可把內部 canonical 18 joints 直接冒稱合法 v3 request。
- 本輪新可用 sprite 0、PixelLab 消耗 0、藝術自然度 NOT_TESTED、原生 VX NOT_RUN、Formal Seal NO。
- [A14 完整真實 QA／方法依據](A14_F0_POSE_CONDITIONED_REDRAW_READINESS_AND_FAILURE_QA_20261108.md)。
- **下一個製作節點：** 只有在 PixelLab 有可直接使用的連線且已確認本次扣額上限後，先以此 package 跑**一次** RUN 三幀；若 48px 白髮 F0／骨架／自然度達標，再跑 WAITING，最後再測第二角色。仍未能呼叫時不再生成無關海報；可以讀原始 FS game/effects 做 Native Adapter 的靜態準備，但不能假稱新美術成功。

## A11 舊階段紀錄（唯讀歷史，不再當本輪產出）
# FS AI Asset Factory CURRENT_HANDOFF — A13 / 2026-11-08

CURRENT ENTRYPOINT: [ONE ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) and [A13 honest ART failure QA](A13_ARTICULATED_POSE_F0_SOURCE_PROTECTION_FAILURE_QA_20261108.md). This file describes actual project state, not new policy.

## A13 happened; do NOT resume A11/A12 same-pose warps
- Original Actor01 F0 45°/48×48 from A62 historical user approval: exact binary SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba (source unchanged). Also compared against approved 144×48 A62 Run strip.
- Three new real pose candidates _1 neutral, _2 LEFT leading stride, _3 RIGHT leading stride, loop 0,1,0,2. V1 overwide legs ART FAIL; V2 manually redrawn arm tubes ART FAIL; V3 narrower stride with original sleeve pixel patches, **still visibly below approved A62 art**, ART SELF-REVIEW FAIL. It is NOT a valid new sprite asset even if left/right feet actually alternate.
- V3 each PNG 48×48, 144×48 strip and GIF. V3 frame changes vs F0: 0/129/140 pixel locations; face/hair upper 33px pixel identical; all palette pixels belong to F0. None of those numeric invariants prove visual quality. No native Tankentai/Game.exe run.
- New `pose_spec.json` and pose-overlay guide records actual left/right hip/knee/ankle/elbow/wrist targets to feed a SOURCE-IMAGE-conditioned + skeleton-guided pose redraw generator next. The pose guide is a tool input, NOT accepted art.
- One non-reference-constrained image generation created unrelated elf instructional graphic; rejected and NOT included in candidate or private package. Do not mistake it for the user's Actor01.

## Real private ZIP — byte-level Drive verification
`FS_A13_ACTOR01_ARTICULATED_RUN_ART_FAIL_AND_POSE_JOB_20261108.zip` — 84,797 bytes / 31 entries / SHA256 `0aa0792667f3bfc88c96bd81796ced072538ee2c32bd09a3fff80d8d90c40867`. Stored under owner-only `FS_AI_ASSET_FACTORY_Restricted_Binaries`. Cloud metadata `shared=false`, only owner. **Actual Drive bytes materialized back into isolated container and SHA256 + ZIP CRC confirmed exactly equal**, not metadata-only verification. Protected source JPG/PNG/GIF/ZIP and Drive private binary download ID are NOT embedded into public GitHub.
- Contents include exact approved F0, previously approved A62 reference strip, all V1/V2/V3 source PNG/GIF, comparison/contact and 12x pose guide, repeatable Python build scripts, exact frame/pose JSON, QA+CRC manifest.

## Stop conditions and next real production task
- Actual ART gate failed for V1–V3. Stop any V4/V5 pixel-warp, manual patch, leg-splitting or shoulder-shaking approach; this was an explicit user preference and repeated source of wasted time.
- Next single generation experiment: actual F0 reference image + explicit 3-pose skeleton guide into an **image-conditioned / pose-guided animation tool** (PixelLab if callable and budget authorized, or comparable). Generate whole pose sprites at native 48px preserving F0 material and 45-degree camera; verify two legs alternate and opposing arm motion. Only then choose image generator vs rig-assisted branch and normalize to FS three frames.
- Provider generation was **NOT** executed by this A13 pipeline. No direct proven PixelLab integration or explicit per-run credit ceiling; cost 0, new Orca 0. Native VX/Tankentai NOT_RUN. Main/sealed source untouched and no new user PC workfiles. Formal seal NO.
- Ground/PAR tracks remain at A11 Master-first source-pixel QA with bridge mask semantics still ART HOLD. Do not claim they improved in A13.

## Authority boundaries
ACTIVE_MASTER remains the sole rule, no extra SOP created. [A11 actual source-preserving map/F0 QA](A11_REAL_MASTER_F0_TRANSLATION_PILOT_QA_20261108.md) stays historical. PR #15 Draft branch feat/fs-asset-factory-v1-20261107, not merged. After this handoff, verify latest branch HEAD Actions run and Mirror handoff to owner-only Drive.
