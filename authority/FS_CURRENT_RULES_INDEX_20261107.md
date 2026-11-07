# Forest Symphony｜CURRENT RULES INDEX & PRECEDENCE｜2026-11-07

> **唯一現行規則入口。** 此索引與 [P0 Cloud-only](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md) 對 FS 專案持續適用。舊版 Handoff、舊 Agent Skill 與版本流程若牴觸，以此索引、使用者最新指令、實際已驗證的版本為準。保留所有歷史原文和 SHA/失敗紀錄，不以新政策改寫已發生的測試結果。

## 優先權（必須依序執行）
| 優先 | 來源與政策 | 最新生效含義 |
| --- | --- | --- |
| P0 | [Cloud-only Storage](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md) / [Drive P0](https://docs.google.com/document/d/1ai55-_Hs8SKZ2XOmlhsDNMHDrLQfCtLq8g3dOUaiNzg/edit) | **任何需要保存的新產物全部 Drive/GitHub，不放 PC**。只允許必要安裝與極短本機實機執行暫存，需雲端 SHA 驗證再清理；既有未備份舊資料不可直接刪。 |
| P1 | Drive [SHARED_GAME_ASSET_GENERATION_AUTHORITY](https://docs.google.com/document/d/1TF4wGLqwiALO-IJ_1R-5m9J7fGS-47tKmNi5yH_LMdc/edit) + [ASSET_GENERATION_PRECHECK_FS](https://docs.google.com/document/d/1vqYsJ4tWXDdn8-adm9VK6DNVu-gFoXPlWgxplEHnNIg/edit) + [v3.2 Scene/Source/Gate authority](https://docs.google.com/document/d/1cqhSsN9EcAlY0K4691AHUAIUglwTTKiq_c2PUHDmbLY/edit) | 維持原始素材 SHA、權利、Scene Manifest、目標視角 32px、Gate A-F、正負例與 Fail-closed；任何新規不得覆蓋已封版原資產。 |
| P2 | [FS Master-first V1 Gate](../experiments/agent_skills_20261107/MASTER_FIRST_GROUND_PAR_QA_V1.md) / [V3 native Handoff](../experiments/agent_skills_20261107/MASTER_FIRST_V3_NATIVE_203_COLLISION_HANDOFF.md) | **FS 新精靈村**：先生成並凍結單一完整 MASTER RGB；AI 只提議隱藏地面補繪／語意物件 mask，再以相同 XY 的 Master RGB 建 Authoring/Runtime 四層。原生 Game.exe 203／Map050、碰撞和使用者 Art Gate 獨立，不得用合成零誤差偷換成美術 PASS。 |
| P3 | [FS Agent Skill](../.agents/skills/fs-rmvx-router/SKILL.md) / [Repository AGENTS](../AGENTS.md) / [Asset Precheck](../ASSET_GENERATION_PRECHECK.md) | 每次 FS 作業先讀 P0、本索引、專用 Skill，再讀 Shared/Project Precheck，才作畫、跑腳本、測 VX。Godot 只做輔助 QA，主要引擎 RPG Maker VX RGSS2。 |
| P4 | [Source-first Provenance](FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md), [Ground3 Art Quality](quality/FS_MAP_REFERENCE_RICHNESS_TARGET_20261024_V1.md), native VX collision/foot semantics | Source First 的來源、Alpha、Manifest、編譯、Collision 和美術驗證是技術法，不限定新場景必須 Ground-first。角色基本 32×32 grid，視埠 544×416，完整場景可為 1280×928。 |
| P5 | [FS Character Motion](FS_16_ACTION_POSE_REFERENCE_FAIL_CLOSED_SOP_20261101.md) | FS/PMD 戰鬥角色固定原始 45° 鏡頭/來源身份，**每個動作 3 張 Keyframe**，真正 loop 需交替左右腳並做原始骨架QA，不再重跑已通過的來源；成果同樣 Cloud-only。 |

## 四圖契約（新 FS 場景）
1. `Authoring_GroundOnly`：真正地表＋合理的遮擋物底下補畫；原圖未遮擋區保持來源註冊。
2. `Authoring_CompletePAR`：從 MASTER 的原 XY 抽出全部地上物件，Source/Mask/Manifest 可追溯。
3. `Runtime_FullGround`：**完整 MASTER 原樣（不切除房樹）**。
4. `Runtime_OcclusionPAR`：**只有真正站在角色前面的樹冠、屋簷/屋頂突出、橋欄、崖邊等**，RGB 必須和 Master 同 XY 完全一致。不能把 CompletePAR 全部拿來蓋角色。

**V3 範圍說明**：只證實兩個樹冠的真 VX 原生走入/走出＋空地對照、草案 Map050 格子與引擎一致；**無合法屋頂可走遮擋測試**，整圖碰撞語意與 Art Gate 仍未全過。Formal Seal **NO**。

## 廢止的執行入口（歷史原文保留）
- `authority/research/FS_R17_DIRECT_GROUND_PAR_AUTHORITY_20261029.md` 和 `FS_R17_DIRECT_GROUND_PAR_SOURCE_FIRST_AUTHORITY_20261029.md` 曾自稱「最後決定：AI 各自獨立 Ground+PAR／不需要 Master」。**2026-11-07 新需求明確推翻這個作圖優先順序。**
- `authority/research/FS_GROUND_ONLY_PIPELINE_V2_SPEC_20261030.md` 的「禁止 Master-first」僅為 2026-10 舊候選判定，現在不能作 FS 新村落生圖 Gate。
- `MAP_DUAL_OUTPUT_AUTHORITY_V2_2/2_3/2_4.md` 為已廢止通用迭代；v2.5 是其他場景的一般 Ground-first Source 方法，**FS 新 Master-first 為專案最新覆寫**。
- `authority/FS_DIRECT_GEN_GROUND_FIRST_NO_PIXELLAB_DEFAULT_V1_20261102.md` 與 `FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md` 保留 2026-11-02 前技術成功/失敗，Source-first 可以沿用，**Ground-first 順序不是新 FS 地圖最終權威**。
- `docs/CURRENT_HANDOFF.md` 是 2026-08 戰鬥腳本/Runtime 交接；其中「GitHub 無法連通」已是歷史說法，主 repo 2026-11-07 已可透過連接器讀/寫/合併，應依最新 Handoff 判斷當期地圖。

## 儲存與檔案權利
- 驗證報告、PNG、素材庫與 ZIP：**私人 Google Drive**。任何第三方授權未確認素材只能私人研究，禁止上傳到公開 GitHub。
- 程式、權威規則、QA JSON、可公開 Manifest 和版控：**GitHub**。不要把 GitHub repo 當二進位原始圖集倉庫。
- 實機 Windows VX 用 PC 為必要「執行」時，限制隔離的最小暫存，Drive 對帳／SHA256 完成後清理。不得把 `E:\FS_...`、`E:\GameAssetToolLab` 當成新常設儲存位置。Google Drive 的 PC 同步磁碟 `G:\` 也不等於無本機儲存，優先用 Drive Connector 直接存雲端。
- 原 PC 上舊工程先盤點雲端版本再清理；本次稽核**只查閱遠端 API 資訊（記憶體）而未在 PC 建新工作檔案**，既有老檔仍未清理，不得聲稱不存在。

## 本次稽核方法與範圍
- 在 GitHub `main` 對專案 **507 個可讀文字／JSON／規範類檔案進行 read-only 掃描**；其中 **157 個**含明確的 Windows/本地路徑樣式。這 157 大部分是歷史 Handoff、研究腳本／失敗證據或早期本機施工來源，**不應自動全域取代路徑或改寫試驗**；優先修仍活躍的 `AGENTS.md`, `ASSET_GENERATION_PRECHECK.md`, `MAP_DUAL_OUTPUT_AUTHORITY_V2_5.md`, `BACKGROUND_EXECUTION_AUTHORITY.md`, `README.md`, `docs/CURRENT_HANDOFF.md`，及明確自稱 ACTIVE/HIGH 的舊 R17/GROUND_FIRST 權威。
- Drive 盤點 `Forest Symphony/00_Project_Authority` **37 件**、`05_Handoff` **31 件**、`07_Tools` **27 件**，也交叉搜尋 Shared/PMD/CG 共用規則與 **6 份同名 WSL 存放規範副本**。Drive Active/Legacy 權威已增加最前方 P0 和新 Master-first 覆寫說明，六份 WSL 原有「E: HDD should be preferred for archives/downloads/handoff」建議全部精準替換為雲端保留方案；**C: WSL 本身是必要執行環境例外**。
- Drive 與 GitHub 的文字掃描不構成「每個封存 ZIP／PDF／影像裡的文字和所有未索引檔案已逐位元全文稽核」。這些歷史二進位證據不應就地變更；其執行說明一律由 P0＋本索引覆寫。
- 本次更改**沒有覆蓋任何歷史 SEALED source、修改正式 Game.exe/Map050 或移除舊素材**；舊本機工作夾是否已備份完整還沒有被逐案核對，待未來單獨安全清理任務。

## Preflight / Handoff Gate
每次新任務都需回答：
- 新成果是否只去 Google Drive/GitHub？臨時 PC 必要性已確認？
- 是否先讀最新 P0、FS Skill、共用生成 Authority、FS Precheck 與本索引？
- Master-first／同源 RGB／四層／Source owner／32×32 通行／動態 203／Art 之各 Gate 是否分開判定？
- 雲端實際檔案 ID、QA/CRC/SHA、GitHub branch/PR、PC 暫存清理結果是否可核驗？
- 未能證明的部分一律 **NOT RUN／FAIL／ART HOLD**，禁止編造成 PASS。


## P6 | A08 user-mandated Sprite + Map dual production methodology (2026-11-08)
Latest user instruction: fully operationalize the complete 22-page PixelLab-led FS Asset Factory research report, for BOTH sprites and Ground/PAR, not only bridge details.
- Shared active rule: [FS dual-lane authority](FS_ASSET_FACTORY_BOTH_LANES_RULES_V1_20261108.md).
- Page audit: [A08 22p research mapping](../docs/asset_factory/A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md).
- Required stage-specific rules: [Sprite Factory SOP](../docs/asset_factory/FS_SPRITE_FACTORY_SOP_V1_20261108.md) and [Master-first Map Factory SOP](../docs/asset_factory/FS_MAP_FACTORY_SOP_V1_20261108.md).
- Next production gates: [A08 execution queue](../docs/asset_factory/A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md) and [CURRENT_HANDOFF](../docs/asset_factory/CURRENT_HANDOFF.md).
- Build both: reference Style Bible -> archetype/scene template -> real direction skeleton/semantic object family -> bounded batch -> automated QA -> exception-only repair -> native FS exporter -> user 1x Art + Game.exe. NO V0/V1/V2 per-rail-color masking iterations as routine factory work.
- **Native schema clarification for P5**: three *stored* Actor key poses (loop such as 0,1,0,2) or interim PMD pose templates are not the universal native PMD atlas count. Only genuine per-species AnimData.xml determines exported Idle/Walk/Attack frame counts, durations, XML CopyOf aliases, Anim/Offsets/Shadow and 1/8 native rows. PMD0001 Idle3/Walk6/Attack11; PMD0002 Idle4/Walk4/Attack9; PMD0003 Idle4/Walk4/Attack11. No fake 5->3/6 fitting of A26 unapproved candidates.
- **P2 remains**: Master-first complete picture remains Runtime FullGround; Runtime OcclusionPAR needs SOURCE-AUTHORED semantic object ownership and conditional legal actor footpoint depth, not RGB similarity or all Authoring PAR.
- This is a plan/static production-contract gate, not user approval of newly produced assets or license to spend PixelLab credits. Keep P0 source and PC-safe rules intact.

## P7 | A09 real-source production template progress (2026-11-08)
- Latest active [A09 CURRENT_HANDOFF](../docs/asset_factory/CURRENT_HANDOFF.md) and [private-source public QA](../docs/asset_factory/A09_SOURCE_LOCKED_SPRITE_AND_SEMANTIC_SCENE_QA_20261108.md), while A08 dual SOP remains binding.
- Sprite source recovery: actual approved historic PMD0001 G3R1 in private P3_G9 three-stage evolution package was verified, together with Actor A62 previously accepted run poses. Private A09 37-file source kit SHA256 `9b1465828dd40b4fedf63e49f7598583b2a08ac9e2181c5a0c85ebb86c5b389a`. This is source reuse, not new approved AI art. PMD0002/3 freshly generated G9 frames remain ART_HOLD.
- Ground3 original `Graphics/Parallaxes/ground3.png` source verified at SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`, do not use `Overlays/ground3.png` as source palette/art reference.
- Two distinct 40x29 Tiled semantic-layout blueprints are generated by common `scene_blueprint.py`/`export_a09_scenes.py`. Deck is source-class ground, near rail is separate conditional foreground with actual source/mask still pending. No art Master or runtime Ground/PAR was created in A09. CI artifact is object-level layout metadata ONLY.
- Next A10 must fill semantic family object sprites and approved rig templates with REAL style-consistent image source, then native 1x human/Engine Gates, not more bridge micro-edit or synthetic test inflation.
- Protected source imagery stays owner-only Google Drive; public GitHub does not expose private art download URLs. PixelLab usage 0 in A09, no PC workfiles, no main merge; Formal Seal NO.
