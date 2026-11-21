# Forest Symphony | T-B 怪物量產工廠 | CURRENT HANDOFF
更新：2026-11-21（Asia/Taipei）｜分支：`feat/fs-pixellab-tb-monster-20261121`
線別：**T-B / SHO-37**｜階段：**M1 第一條進化鏈候選已生成、M2 Godot 工程已建立但原生未執行**
狀態：**ACTIVE / ART_HOLD**；絕不標為 VERIFIED_PASS。

## 1. 本輪真實施工 DELTA
- 本輪從**私人 Google Drive 真實來源**讀出 PMD0001、PMD0002、PMD0003 三個 128×128 透明背景概念母圖；建立三階 **64×64 PNG** 靜態 Sprite，維持來源輪廓而不只是換色。三階呈現「小型熔岩蛙→增厚玄武岩殼→外露熔岩核心」。這些是用既有來源建立的候選圖，不是新一次 PixelLab 生成的三張圖片。
- 將 **歷史 PixelLab 產出** PMD0001_WAITING_3FRAME_PROVIDER_SHEET（384×128）以 source-locked 裁切及等比例縮放整理為 **Idle 3F × 64×64，192×64 atlas**。只有 3 幀，不可虛稱 12 幀或新 API 生成。
- 以 PMD0001 已鎖定來源製作 **Attack 8F × 64×64，256×128 atlas**，包含壓低身軀、抬起前衝、噴射熔岩、回復。這組是 **deterministic procedural fallback**，**非 PixelLab 生成、不冒充已核准攻擊動作**，需在真實動畫視覺驗收中確認動作語意。
- 另產 **Idle 與 Attack GIF** 與三形態對照圖。
- 建立**獨立 Godot 4.7.2 展示工程**（專案 `project.godot`、`tb_demo.tscn`、`tb_demo.gd`、`tests/tb_validate.gd`），可使用 1/2/3 切換三階，Space 播放攻擊；完整 ZIP 包含私有PNG；未更動 FS 主線場景。
- 新增重現工具 `godot_port/tools/pixellab_tb/build_tb_monster.py`，可從合法原圖重建圖集／SHA manifest／幾何 QA。

## 2. B0 真實來源與 Hash
| ID | 真正來源 Drive file ID | 2026-11-21 實際讀取 SHA256 |
|---|---|---|
| PMD0001 | `1uW0MbruUOHjKu7f_coEr1ebuUQFnucdh` | `8fc8310ce3cf08a13582d9d84e33020e8cf362ab3b03dba8b4ac624ead164b2d` |
| PMD0002 | `1xw11JS2wR1tjxi-q2tb1DZeU1bQNUdb7` | `dcc3cd009912d38007bc4afdf794b68804265c02bd8553f4e5b03b9bc0d4c8fb` |
| PMD0003 | `1p3CFtpD2lpLNQmweFL1goZwV4xF0lgYO` | `64e61fb8409d784b5b294cae5d5162fc996c4494440664315a242f2d854c93ea` |
| PMD0001 真實歷史 PixelLab Idle sheet | `1An7EAOsy32v8bPuWr6YbOZSjEIvPV7EE` | `3c5c65bb35239869d83c8eab87a663e8a8c33c191a9dacd6752bf43572b22bf6` |

原生 PMD 34動作 XML 及前次 ZIP 來源 SHA 請參照既有 [A02 INVENTORY](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-asset-factory-v1-20261107/docs/asset_factory/SOURCE_INVENTORY_A02_20261107.md)；**本輪沒有重新下載完整原生 XML ZIP，未重核它的位元組**。原圖授權歷史註記有待 final licence gate；用戶私人資料嚴禁提交公開 GitHub。
視角沿用實際來源右前 3/4，但**45° 精準角度尚未原生視覺確認**，為阻斷正式 ART PASS 的待決事項。

## 3. Cloud deliverables
- 私人來源／素材／Evidence folder：[T-B 私人 Drive](https://drive.google.com/drive/folders/10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3)
- 三階真正可見對照：[Preview PNG](https://drive.google.com/file/d/14VqV8v5-jVR2IzCA6VQykOsKLglj7PLc/view)
- 母體 Idle 真實歷史 PixelLab GIF：[Idle GIF](https://drive.google.com/file/d/1-9mBZffp3RK5GwIDDKgzeOY4z7ErAVG4/view)
- 母體 Attack 程序化候選 GIF：[Attack GIF](https://drive.google.com/file/d/11DvfuJ2luTPVf5H4ocsJQoVBn4u64M0m/view)
- Godot 可載入獨立工程完整 ZIP：[Godot Candidate](https://drive.google.com/file/d/1iH3rdqN7KdACcFfxCI3CpHaqQ-BKHS4b/view)
- [FAMILY_MANIFEST.json](https://drive.google.com/file/d/1wR9gJye1CoflBqskEv5QRE6AzPPus9OZ/view) | [QA_SUMMARY.json](https://drive.google.com/file/d/1Kw5sAckxse1D1kQ5_CZpIEBM3gvkRlyj/view)
- ZIP：16 entries, CRC OK; SHA256 `e85f111c7b61390a818d526f873e348d0680887b36de3472b76e1bfb746f9a36`.
- GitHub 程式：`godot_port/tools/pixellab_tb/build_tb_monster.py`、`godot_port/experiments/pixellab_tb/*` （僅程式及說明，不提交私有PNG）。

## 4. QA 與人工 Gate
| Gate | 本輪實際結果 |
|---|---|
| 來源四張圖 SHA／來源 Drive id | PASS（僅這四張） |
| 三形態 64×64、alpha 無裁切、足點 y=59、色盤／剪影非單純換色 | 尺寸／透明幾何 QA PASS；肉眼家族風格為 CANDIDATE |
| Idle 三幀來源／差異／透明邊界 | SCRIPT PASS（歷史 provider；美術未過） |
| Attack 八幀圖集／差異／透明邊界 | SCRIPT PASS（程序化；攻擊可讀性 ART HOLD） |
| Godot 4.7.2 專案與可載入資源結構 | PROJECT BUILT；**NATIVE NOT_RUN** |
| 原生 Godot 截圖／動畫動態測試 | **NOT_RUN**（此 ChatGPT 隔離環境無 4.7.2 binary） |
| PixelLab 新角色生成／Skeleton／新 API credits | **NOT_RUN，job id null，當次 0 generations** |
| 第二樣本可重複量產 | NOT_RUN |
| 最終用戶 ART Gate | HOLD，未申請 PASS |

當次可核實 API 花費：**0 PixelLab generations**。本輪歷史來源可能含已付費舊結果，不應算當次新費用。ChatGPT 隔離環境轉換成本未測計；不杜撰金額。

## 5. FAILURE LOG / blockers
1. **PIXELLAB_API_UNAVAILABLE / BLOCKING for formal B2**：本輪沒有可授權的 PixelLab 生成呼叫工具；改用已保存歷史真實 PixelLab Idle，攻擊採可追溯程序候選並明確標示 HOLD；沒有假造 job ID。
2. **NATIVE_GODOT_BINARY_MISSING / BLOCKING for M2**：僅能產製工程 ZIP、幾何 QA；無 4.7.2 執行檔，無法提供本輪原生測試截圖。不能沿用舊工程截圖冒充。
3. **VIEW_45_ART_GATE / BLOCKING**：現有來源偏右前方 3/4，但 45° 精度需在戰鬥相機內確認；錯視角不得升版。
4. **ATTACK_SEMANTICS / BLOCKING**：八幀程序化壓縮／前衝／噴火有動勢，但尚不能替代 PixelLab 真正骨架或分段攻擊生成；不可宣稱 B2 ART PASS。
5. **SOURCE_LICENSE_AUDIT / BLOCKING for public reuse**：私有原圖已有可追溯來源與歷史記錄，本輪未查到全面可公開重用授權；PNG 限私人 Drive。
6. **PIXEL_FINISH / NON_BLOCKING**：少量局部 pixel/alpha 與視覺細節待人工審查；0 次修正。最多連修兩輪後記錄，禁止拖延完整成果。

## 6. 下一個完整成果單位
**M2+B2 可實測且 ART 可審的完整版**：在合法、隔離、可存回私人 Drive 的 Godot 4.7.2 測試執行器匯入此 ZIP、取得 native 截圖/動畫證據；如 Attack 動作語意不合格，改走「真實已核准 PMD0001 來源 + PixelLab Skeleton/Animate-with-text / key pose」重生完整攻擊，保留本次候選作對照。完成原生與美術 Gate 後，才做**第二個真正不同樣本**的模板驗證。不可先宣稱可量產 500 隻。

## 7. P0 storage / handoff
- 本次隔離環境工作檔在 ChatGPT sandbox，**未建立使用者 Windows PC 資料庫**。
- 實際成果持久化於上述私人 Drive + T-B 專屬 GitHub 分支；保留所有原始 PMD 舊工程不變；T-A、T-C、main 不動。
- WRITE→READBACK：GitHub 程式碼與 Drive folder/manifest 已回讀；完整 Godot native **未驗證**。


## 2026-11-21 R2 重要後續：Attack 正式 ART FAIL
- 使用者拒收上一版 Attack；已做像素還原：8 幀中的 **6 幀**可由全身壓縮/移動/扭斜完全重現，其餘兩幀僅額外疊加少量火球。此方法的關節、嘴部和命中語意有阻斷問題，**不再沿用**。
- 已從私人 Drive 取回 PMD0001 原生 G9 11F×8方向 Attack，解出 2 組 11F 透明 atlas 和 GIF、XML Rush2/Hit5/Return7，作為**動作參考而非正式美術成品**。
- [完整 Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_ATTACK_R2_FAILURE_LOG_20261121.md)｜[私人比較圖](https://drive.google.com/file/d/1axA8UO5tsupoZKK7psZTdhGFTuhQKucp/view)｜[Godot 對照工程ZIP](https://drive.google.com/file/d/1p2rZLZFVIEpPgYbpogX42YMhjyMD2upf/view)
- ZIP 18檔 CRC PASS，SHA256 `a0f63b7883acc963d5c9df929f627ff1fa35d07c6290aeaa352bebdeaab03ea6`；**Godot 4.7.2 native NOT_RUN，正式新 Attack NOT_CREATED，本次 PixelLab 0 generations**。
- NEXT：以原生 11F 當姿勢/時間參考，對既有已核准母體建立真正蓄力→蹬地→命中→收招的分段 keypose；再進 PixelLab 骨架/文字動畫及原生 Gate。三階和 Idle 保留，不因攻擊失敗重做。


### R2.1 正式替代製法已準備：普通 Attack = 前撲咬擊，噴火另列 Skill
- 已用上一版已鎖定 `PMD0001_STATIC_64.png` 不經重繪放到 **96×96 透明畫布**；原像素位置平移 +16,+24，bbox (29,51,67,83)，空間足夠讓四肢伸展及前撲，單張來源 SHA256 `e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72`。已存[私人 Drive First Frame](https://drive.google.com/file/d/1HlUptfEOtd9EZIZ9G9QkGevIreIJLTnb/view)。
- [11F V3 Keypose Contract](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/research/pixellab_tb/TB_ATTACK_V3_KEYPOSE_CONTRACT.json) 與 [96px source-first builder](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/build_v3_keypose_input.py) 已提交。以原生事件 Rush F2 / Hit F5 / Return F7 為權威，構成蹲伏→蹬地→跳擊／咬擊→四肢落地。原先不相干的火球排除普通 Attack，另作 Cast/Skill。
- PixelLab Skeleton v3 正式目標 **11F × 96×96 → 384×288 4×3 atlas**。Text v3 僅作替代，需用偶數 12F 並重新映射事件。**這是生成輸入及逐幀契約，並非聲稱已得到真正的 11F 新攻擊**。
- 本次仍 PixelLab 0 generations、native Godot NOT_RUN，Attack ART FAIL。下一個完整閉環：真的生成新 11F → native Godot 動態顯示 → 人工 ART gate。


---

### T-B R3 V4 實際輸出（2026-11-21）
- 重新生成 **PMD0001_ATTACK_V4_11F_384x288.png**：11 幀、每幀 96×96；F0/F10 與已確認 64px 母圖擺進 96px 畫布完全一致；10 種獨立畫面，背甲身份維持。**源圖 SHA256**：`fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c`；**Atlas SHA256**：`08327c031e3962c50623aeb15f11961b5c7795c8794ad359dafb54e7315686d7`。
- 此版使用 **independent keypoint deform**，三組腳部足點分別變化，嘴部開合而非只有 whole-body 尺寸晃動；保留 F2 Rush／F5 Hit／F7 Return，沒有噴射火球。**它仍是程序化重定向，不是新 PixelLab AI 輸出**。
- Python QA **16/16 PASS**（包括三個攻擊關鍵幀對比整隻平移至少有 70 px 變化）；**Godot Native NOT_RUN，ART HOLD**。視覺上仍有腿部拉伸、嘴部接縫，不能宣稱正式合格；無新增 PixelLab 消耗（0 jobs／0 generations）。
- [V4 動畫 GIF](https://drive.google.com/file/d/17PRN7eSUSKXguNdtC2G4xxEoSSbfVFol/view)｜[11F Atlas](https://drive.google.com/file/d/1cuLHQ64Dx1QLFF1CpXVUwTjdG6nhPwRN/view)｜[逐幀 Contact](https://drive.google.com/file/d/1kpCc-1TK5n4uJ3ntYhItvkfmadKi7uYB/view)｜[私人 Godot 4.7.2 比較工程](https://drive.google.com/file/d/1Fhnc4q6_gnc-2cySRdeJ8uyYf4eqtmLt/view)（12 檔 ZIP CRC PASS，SHA256 `0625508b4c6aed76bb6348cd4540d8ebbc7cb79edbd3699613aa036e52ec8d17`）
- [R3 詳細 Failure/QA/Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_ATTACK_V4_REWORK_20261121.md)；GitHub 同分支已新增 source-locked builder、QA script、Godot scene、headless validator。私有 raster 沒有放入公開 GitHub，PC 沒有被修改。
- NEXT_MACRO_UNIT：先驗證 Godot 4.7.2 native 與 V4 美術；繼而用已鎖定 PixelLab V3 姿勢契約生成真正有清楚骨架的 Attack（需可授權 API 與實際費用／job ID）；最後才進第二個不同樣本。**前輪拒收的 V1 一律維持 ART FAIL，不可回升。**


---

## R4 (2026-11-21) | Godot 4.7.2 Native SCRIPT QA PASS, PMD art HOLD
- Full [R4 Handoff + Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R4_NATIVE_TIMELINE_HANDOFF_20261121.md). Implemented deterministic 11-frame / 28-tick attack F2 Rush / F5 Hit / F7 Return, exact-once hit with frame skipping, cancellation and repeat. Existing FS battle damage code unchanged.
- [Real native Godot 4.7.2 CI run #44872832030](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872832030) completed/success. Job 136750948876, engine version 4.7.2.stable.official.ed1daf0bf, log marker TB_TIMELINE_NATIVE_PASS (R2,H5,T7,DONE, fast-forward, cancel, 60 Hz). **This native run uses synthetic nonprivate PNG. It is NOT the native verification of the private PMD art.**
- Private real-file Python regression 19/19 PASS. PMD0001 static 64px has 826 RGB colors. A shared 32-color transparent V4 variant was generated, with exact alpha-mask preservation. Art gate remains HOLD because of leg stretches and jaw seams, and the 32-color version is not approved.
- [Private Godot 4.7.2 R4 ZIP](https://drive.google.com/file/d/1sXZy5VfR3dUyJVl6myYmWJNmpilbrTzv/view) 22 files, CRC PASS, SHA256 9d37acde4ec5267c40f0dad3c6a8177d93fb9ca732deebe65755b90e87d6bfa7; [32-color frame comparison](https://drive.google.com/file/d/1ju4hXZjcz7saCtu3H4N1PZUFv0rjmvgz/view); [QA JSON](https://drive.google.com/file/d/1VUwGHiLIM2HVb1_VAJJ3-15JbSM5il5F/view).
- Gate summary: Godot native SCRIPT (synthetic) PASS; Godot native REAL PMD PNG NOT_RUN; ART HOLD; PixelLab new generation 0 jobs / 0 generations; second family NOT_RUN.
- NEXT COMPLETE UNIT: use true four-limb and independently drawn lower-jaw keyposes (PixelLab or authorized tool), keeping F2/F5/F7 events; run native Godot 4.7.2 with PRIVATE real PNG and human Art Gate. Do not repeat rigid-body/RBF warping; no private art in public GitHub, no files created on user's PC.


---

## 2026-11-21 R5 latest authority: real Godot 4.7.2 private atlas native QA
- [R5 full Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R5_HANDOFF_20261121.md) and [R5 Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R5_FAILURE_LOG_20261121.md) are the newest engineering instructions.
- Actual official Godot **4.7.2.stable.official.ed1daf0bf** Linux executable fetched from [GitHub Actions 44873427754](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44873427754), SHA256 8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e. Downloaded to isolated sandbox, not user's PC.
- **Real PRIVATE PMD0001 V4 atlas**, not synthetic PNG, loaded and native timeline regression PASS. **V5 11-frame 96x96 source-locked cutout candidate** generated, three independent toe masks, source torso and eye/shell pixels preserved. No RBF, no source-only whole-character resize. Sprite SHA256 778282e1135c47d46a511e7da6a4a979636c5d67e7f259c13959e21795b584f4.
- **Godot real-private V5 Native**: headless event validator TB_V5_REAL_NATIVE_PASS (F2 Rush / F5 Hit / F7 Return / exact-once / cancel), Xvfb OpenGL compatibility **Mesa llvmpipe SOFTWARE renderer** captured 11/11 real frames TB_V5_11_NATIVE_RENDER_PASS. All 13/13 source + identity + native screenshot checks PASS; these are technical only, not Art approval.
- Private complete ZIP (54 entries, CRC PASS, SHA256 190bd45ad22629944746d54261ff966fade9661ed13c1576fca4adfd5f50fe6f): [Drive private V5 Godot+sources+QA](https://drive.google.com/file/d/1xNFP3fitA0PRQccc2t0oFCh2DsxyKrwM/view). [Real native 11F screenshot contact](https://drive.google.com/file/d/12WBZ2pKn4vXdq394ALAxFuXxDD3bEQ_B/view), [native slow review GIF](https://drive.google.com/file/d/1GhyN5kYAP4yHhDaUyGPgJQF0aqcsRuUI/view), [V5 Sprite Sheet](https://drive.google.com/file/d/17Py9VJhcumRttBCA4XYP9XHrZvWoRgPF/view), [13/13 QA JSON](https://drive.google.com/file/d/1xNbqXrjGMRVz4wLv0v66n63qp2WFCVQI/view).
- **ART HOLD / NOT FINAL**: forelimb connection too mechanically straight, jaw bite gap too small, exact 45-degree combat view unverified. Two mouth-art iterations already logged, so the next method must be hand-drawn distinct source-consistent 3 key poses or a real PixelLab Skeleton v3 animation, NOT more whole-body warps/pixel polish. PixelLab **0 jobs, 0 generations this round**, second species sample NOT_RUN. No main/T-A/T-C edits. No owner's PC results library.

 
---
## 2026-11-21 R6 LATEST AUTHORITY | PIXELLAB PROVIDER COMPLETED / REAL GODOT 4.7.2 NATIVE PASS / ART HOLD
- Source and static 3-stage PMD0001/2/3 evolution preserved. Existing 3-frame authentic historical PixelLab Idle retained, no RX-VX regression.
- **Actual PixelLab v2/animate-with-skeleton-v3 SUCCESS**: job ID 3fea688e-1c8c-451c-aa3f-84941166dca2, generation ID 67dd6734-d3a5-4dc7-a860-ebb797f20964. Eleven 96×96 RGBA attack frames received, true 384×288 atlas. Custom source-locked 14-joint quadruped rig; no fake AI claim. **3.0 subscription generations actually charged**, balance 1387.7 → 1384.7; USD price NOT REPORTED.
- Input first-frame 96px SHA256 e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72; original provider PNG atlas SHA256 6d9b6690c3097225bf8fbba5f14eb5fbd667e815577543298898e71ea8e56252. Exact RGBA pixel bridge to private Drive was lossless (119 unique RGBA values) and re-encoded Godot PNG SHA256 9cd50cc5d5bf9aa21e505307e5dac9581a2473d23b49483590ed3632949d2162.
- **Godot 4.7.2 official native private atlas**: import and timed logic test PASS, F2 Rush/F5 Hit/F7 Return exact-once, cancel PASS; Mesa llvmpipe OpenGL Xvfb 11/11 actual native frame captures PASS; objective geometry QA 7/7. Runtime is isolated cloud/container, NOT user hardware GPU test.
- **ART HOLD, NOT Approved**: physical foreleg motion is better than V5; F5 actual bite still insufficiently open, F6 has a disconnected 2-pixel island, first/last provider redraw differs from exact authorized source, and exact southeast 45° battle view has not passed human review. Do not expand to second species yet.
- [R6 detailed GitHub handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R6_HANDOFF_20261121.md) · [R6 Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R6_FAILURE_LOG_20261121.md) · [Cloud index](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R6_CLOUD_INDEX.md).
- [Private 72-entry ZIP](https://drive.google.com/file/d/1LhXel6vpyKAGxVb0BMTIdIKoPIueBGxy/view) CRC PASS, SHA256 7e944f9f6b313ab8e6797849f3c2276ed5375c62abc4618fe1f820f1eb207003. [11-frame generated PixelLab sheet](https://drive.google.com/file/d/1ylrrncc6pPf58NpM9NSZhcWXvnTQ6XUl/view), [actual Godot 11-frame native contact](https://drive.google.com/file/d/1LD7eFRdglOx2JoU1TIAFOUWBWHbQ1dkS/view), [Native slow GIF](https://drive.google.com/file/d/1ljDFksnS-cyVNWcNZ4CefGATrpb3QQth/view).
- **NEXT COMPLETE UNIT**: keep V6 PixelLab body/legs; author 3 truly open-mouth F4/F5/F6 keyposes using masked local inpainting or hand-drawn separate jaw hinge (not global warp), then Godot full 11-native and 45° human Art Gate. Once whole first chain passes, test second unlike specimen; log per job costs.
- R6 images and 11 viewport screenshots are PRIVATE Drive only; scripts and handoffs GitHub T-B branch only; no permanent asset repository on user's PC. T-A/T-C/main untouched.
