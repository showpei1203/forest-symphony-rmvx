# Forest Symphony｜T-C 地圖美術工廠｜CURRENT HANDOFF

- Date: 2026-11-21 Asia/Taipei
- TARGET: T-C / FS_01_VILLAGE 苔光村 → FS_01_MAZE 幽葉迴廊
- STAGE: M1 完整可檢查樣本 + M2 Godot 4.7.2 原生驗證啟動
- STATUS: ACTIVE / ART_HOLD
- BRANCH: `feat/fs-pixellab-tc-map-20261121`
- PREVIOUS BRANCH HEAD: `4a2a50e3aacb3115dbb3418b6e229b8a34c430d0`
- SOURCE CODE COMMITS: `d7f2ade886fd180a3617cc40aae4a6bf62e1c359` → `ad6e8e1d2892b28875577206385cd6b550287b1c`
- ACTIVE RUN: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44830675005
- FORMAL ART SEAL: **NO**. 此工作未改變原 A35 R2/R3、FS_01_MAZE R12/R14 或任何 VX 正式來源。

## Baseline 權威、Drive Handoff

1. 正式 [T-C launch prompt](../research/launch/T_C_MAP_LAUNCH_PROMPT.md) 與 [3 experiments roadmap](../research/FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md)。
2. 原始 Ground3 正式身份：`Graphics/Parallaxes/ground3.png`，SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`，不是 `Overlays/ground3.png`。
3. 苔光村 A35 R8 R3 已有 187 PAR / 175 canopies，Godot 4.7.2 native + nav 舊測 PASS、藝術 HOLD。完整私人 Drive: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view。
4. 幽葉迴廊 R12，80×58 tiles，326 complete PAR / 310 trees，來源原生 + 231 foot sweeps 舊測 PASS，藝術 HOLD。私人 Drive: https://drive.google.com/file/d/1VikZtZc0YWhHFNMjylNGXFEbN2_oW6qR/view。
5. Nov18 R14 對迷宮 PAR 樹型及 Ground 做候選修改，但 native GPU 未驗證；ART HOLD。私人 Drive Handoff: https://docs.google.com/document/d/1iibkZ2MSgwEoWZUpUKTpNUTuaDRXgpcs/edit。
6. 本輪 SOURCE：公開既有 A36G PixelLab 村落整圖來源 `experiments/route_b_25d_20261031_stage16/a36g_pixellab_r3b_20261104/` 的 `A36G_GROUND_1280x928.png`, `A36G_PAR50_RGBA_1280x928.png`, `A36G_SCENE_MANIFEST.json`，而非原 A35 私人編輯工作圖。這些來源屬歷史 PixelLab 成果，不是本輪新生成。裁切起點 (256,115)，尺寸 544×416 = 17×13 格。

## DELTA：已真正提交的程式與工作單位

- [build_tc_village_pilot.py](../../tc_factory/build_tc_village_pilot.py)：用真實 A36G Ground+PAR+Manifest 生成獨立 544×416 T-C 候選及小範圍原生像素花草變化；嚴格來源驗證，缺檔直接失敗，不生成合成偽原圖。輸出單一 MASTER、同源四層：
  - `MASTER.png`
  - `Authoring_GroundOnly.png`
  - `Authoring_CompletePAR.png`
  - `Runtime_FullGround.png`
  - `Runtime_OcclusionPAR.png`
  - `occlusion_owners/owner_*.png`、兩項 JSON QA/owner manifests
- [TCVillagePilot.tscn](../../tc_factory/TCVillagePilot.tscn) + [TCVillagePilot.gd](../../tc_factory/TCVillagePilot.gd)：專屬非正式地圖場景，544×416，Nearest，Ground 與精靈屋/樹冠分離，依測試角色足點條件顯示局部遮蔽物。測試角色為佔位畫像，**不是**已認可的 FS 正式角色。
- [test_tc_village_native.gd](../../tc_factory/test_tc_village_native.gd)：使用 Godot 4.7.2，啟動場景並採集真正 SubViewport 1× 幀，移動測試角色驗證 roof/canopy 的前後遮蔽，原始 framebuffer PNG 和執行 JSON。
- [.github/workflows/fs-pixellab-tc-map.yml](../../../.github/workflows/fs-pixellab-tc-map.yml)：在獨立 T-C 分支由 GitHub Linux runner 完成 Pillow source/layer 產出、Godot 4.7.2 原生匯入、xvfb GPU screenshot QA、生成 ZIP 供私人 Drive 轉存。原專案正式 main/Phase1 CI 不變。

## QA 最新、不得提前升版

| Gate | Status | 實際證據 |
|---|---|---|
| T-C source generator | **PASS，GitHub runner** | run 44830675005 build step completed success，實際圖像保存在 runner 暫存空間 |
| Godot 4.7.2 editor import | **PASS，GitHub runner** | 同 run，editor import step completed success |
| Godot 原生畫面、測試角色遮蔽 | **NOT YET VERIFIED** | CI 正在執行時記錄；需取得獨立 framebuffer PNG 及 JSON，驗證才可 PASS |
| collision/footpoint source-independent semantic QA | **HOLD** | 目前測試中 actor 不是完整 CharacterBody2D 碰撞驗證，且 owner masks 暫採 combined PAR crop |
| overall FS art / house / forest ecological diversity | **ART HOLD** | 完整小樣尚待原生 1× 整圖 review，不能把可輸出等於藝術可接受 |
| FS_01_VILLAGE/MAZE full-map artist approval | **NOT RUN** | 這是 17×13 pilot，不是兩張全圖交付 |
| PixelLab Create Tiles Pro / Map Workshop / Object Creator new job | **NOT RUN** | 本輪重用 A36G 已有 PixelLab image，沒有呼叫新的 API、無 job ID / seed / actual charge |
| Drive new candidate / native QA | **PENDING VERIFIED UPLOAD** | CI 原始 art 和 QA 必須轉存 owner-only Drive，並讀回 size/shared |

## FAILURE LOG（不得假 PASS）

- `TC_SOURCE_OWNER_MASK_OVERLAP` **BLOCKER**：第一版為各獨立 source owner bbox 在已合成的 CompletePAR 取 alpha，可能含其它樹/屋物件的重疊像素。改善方法：下一版使用同名 `SOURCE_INDEPENDENT_RGBA` 的每個 owner 真正獨立 alpha/mask，再依 frozen MASTER 取 RGB，不從整張 CompletePAR 估計個體。
- `TC_OLD_ART_STILL_HOLD` **BLOCKER**：歷史 A36G 的森林與建築先前未取得 ART PASS；此 pilot **不能**消除既有視覺缺陷。換方法需重新生成具有統一材質的完整屋舍和自然森林 Master。
- `TC_PIXELLAB_NEW_JOB_UNAVAILABLE` **DEPENDENCY**：目前可用 connector 未曝露 PixelLab 直接生圖/Map Workshop 操作，本輪只可合法重用 A36G 現成來源。若日後接通，記錄精確 job/model/seed/cost 並封存私人 Drive。
- `TC_DRIVE_TRANSFER` **PENDING**：GitHub Actions 1 天暫存 artifact 僅為轉送用，必須轉私人 Drive 並驗證，不當正式雲端來源。

## NEXT MACRO UNIT

**先完成 1 個真的可審核「完整視覺場景」**：通過 Native QA 後，使用每個獨立屋頂/樹冠 alpha 重建遮蔽所有權；在私人 Drive 保存全部五圖＋兩張 1× 原生幀與 Source Manifest；做第一輪 1× 視覺評分，若整體樣式不合格換完整樹型/屋舍素材，不對像素尖角連改超過兩次。接著擴大至苔光村真實 1280×928 完整區段，再依同源四層及風格規則延伸至幽葉迴廊的 2560×1856 完整森林區段。**禁止碰傳送、存讀檔或 NAV 重構。**

## P0 Storage/Sync

- GitHub 只保存公開程式、QA 計畫、Manifest/Handoff 文本；二進位生成圖片及真正 source QA 必須在私人 Google Drive 保存。
- 不在使用者 PC 建立工程/素材庫。GitHub CI runner 是暫時工作空間。
- 本輪 GitHub first write OK，CI build+editor import readback OK。Drive WRITE/READBACK 與 Linear SHO-39 本輪操作須另行驗證後填寫。
