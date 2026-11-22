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

 
---
## 2026-11-21 User acceptance supersedes earlier R6 ART HOLD for PMD0001 Attack
- Owner explicitly reviewed and said: **「這個攻擊動畫很好，繼續」**. Treat **PMD0001 ATTACK V6 = USER_ART_ACCEPTED** at the quality level shown in [original V6 native slow GIF](https://drive.google.com/file/d/1ljDFksnS-cyVNWcNZ4CefGATrpb3QQth/view). This is user's creative approval, not an assertion that every pixel is technically perfect.
- Preserve the original 11-frame PixelLab V6 exact file and all cost/source/job records; **DO NOT reroll F4/F5/F6 just to open the jaw wider**. Earlier F6 two-pixel island is NON_BLOCKING; original F0/F10 source difference is recorded, not a reason for additional rerolls. Do not overwrite user-approved V6.
- Broader first-family approval still distinguishes evolution static three-stage, Idle provider and actual 45-degree battle camera; only ATTACK V6 user accepted.
- NEXT: complete the release registry and full three-stage+Idle+Attack preview of first family, then use P1E MIT-provenance independent non-frog bat as B2 controlled style-transfer test, not another frog or recolor. Keep new B2 ID separate from PMD0001-3 until its original art and species are approved.
- This user-approved ART milestone supersedes the earlier ART HOLD comments specifically for ATTACK. All historical Failure Logs remain immutable.

 
---
## 2026-11-21 R7: PMD0001 V6 USER_ART_ACCEPTED; TB02 second species TECH PASS, ART REVIEW PENDING
- The user explicitly approved the lava frog V6 Attack: preserve exact 11F PixelLab animation, no more jaw/2-pixel micro-fixes.
- [R7 FULL HANDOFF](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R7_HANDOFF_20261121.md) and [R7 FAILURE LOG](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R7_FAILURE_LOG_20261121.md), plus [R7 control summary](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R7_CONTROL_STATUS.md) supersede earlier R6 next-steps; history retained.
- First PMD family: 3 stages + genuine historical Idle 3F + user-accepted V6 attack 11F, integrated Godot 4.7.2 native 3-stage/Hit-once regression PASS. Existing private [first-family ZIP](https://drive.google.com/file/d/1RssdQoIWl-Tcy6R-JPNi1vWOKexj8IzQ/view) preserved.
- **Second different family TB02_LEAF_BAT**, documented original bat semantic source P1E MIT 16px, PixelLab frog as STYLE reference ONLY; true pixel generation with different purple body and paired emerald leaf-vein wings. Static 96/128/160px stages with silhouette IoU 0.467 and 0.528, not recolors. Mother PixelLab Idle 8F at 96px, Attack 11F at 128px on padded source: true **14-joint wing rig**, not frog quadruped rig.
- INITIAL 96px Attack 10/11 edge contacts = rejected. NEW padded 128px Attack job 75368d39-ba66-42fd-b90c-b1b19833258d, generation 8c9dfea5-dd81-4e14-953b-df2d4ae2f41a; atlas 512x384 SHA256 0a4327d1a951673f2fea6ce982f5b9790a9398066d614d9a85809d9daad5da58; **all 11 frame border counts 0**.
- Python QA **16/16 PASS**, native Godot **4.7.2.stable.official.ed1daf0bf** live private Sprite Sheet test HIT EXACT ONCE PASS, OpenGL Mesa llvmpipe Xvfb 8 Idle + 11 Attack actual screenshots PASS. Godot test was repeated after switching to 128px cell_size. Frog family native regression also PASS.
- **TB02 TOTAL 22.0 subscription generations across 7 real PixelLab jobs**, including rejected 1-generation middle edit and 3-generation clipped attack. Not USD. Stage3 final 2 edge pixels NONBLOCKING; second species ART_REVIEW_PENDING until owner approves, and exact FS battle-camera view not verified.
- PRIVATE RELEASE ZIP: [R7 two-family Godot + 19 native frames + QA + original images](https://drive.google.com/file/d/1EGL4eOiZq3Bx0Rxl83fIBjlzklGMHEEo/view), 80 items CRC PASS, SHA256 7c8d84fc1e0b7dfc9081222e31728e521d452897603ef77985c29b68ecdf317f. [TB02 Godot screenshot](https://drive.google.com/file/d/1dXB8AQrNHXCuqQD_AjKEjHF3ruKNlCsQ/view), [native Idle GIF](https://drive.google.com/file/d/1HIsgGUkTrKd2bn1CPwn9H0vrR63Tb2u4/view), [native Attack GIF](https://drive.google.com/file/d/1ja7b3CNzMD0i-H9sR2Y6HKDEUhmpM0qE/view).
- NEXT MACRO: user visual approval of TB02 family and wing animation; then integrate accepted sprites into the real FS battle camera using same RushF2/HitF5/ReturnF7 interface, next third-species benchmark. No main/T-A/T-C changes. GitHub code and records only; Drive private art/ZIP, no permanent user PC results.

 
---
## 2026-11-21 R8 latest authority: TB02 Leaf Bat mouth-only bite, old R7 attack REJECTED
- User explicitly rejected TB02 R7 attack: **「攻擊需要改成用嘴巴攻擊，現在這樣很像身體突然長出一隻手」**. Unlike PMD0001 frog V6 (still owner APPROVED), TB02 R7 claw attack now **ART FAIL**. Its real native tech PASS did not mean approval.
- ROOT CAUSE: R7 PixelLab prompt was `claw and bite`, custom rig projected talon joints horizontally (R7 F5 resembles new hand growing out of torso). New **source-locked R8** v3 rig removes arm/claw/talon strike, moves head + upper/lower jaw and small stabilizing wings, features an actual dark open mouth and fang bite.
- TRUE new PixelLab job `ef8135ef-2a6e-4992-8125-6c4ca2fb631a`, generation ID `6ca82361-d5b6-4506-a13f-34acdd75787d`, **3.0 generations billed**, TB02 cumulative **25.0**. Sprite 11×128 RGBA → 512×384 SHA256 `b258678a7a4b59251b13126ed905c47afd9b9dffd0a618fbb64f584ad9ceeee7`. First frame source and 3 stages / Idle remain source-locked; first family frog unchanged.
- Independent **11/11 semantic QA PASS**: F5 old horizontal arm-purple count **30→0**; F6 **22→0**; dark open-mouth F5 **21→101**; fangs **0→5**; 11/11 frame border count 0, no clipping.
- TRUE Godot **4.7.2.stable.official.ed1daf0bf** native 3-stage + Idle8 + Bite11, F2 Rush/F5 mouth bite once/F7 Return, new mouth contact `(14,0)` PASS; Mesa llvmpipe Xvfb **19/19 actual native frame captures** PASS; PMD0001 first-family regression PASS. This is not yet user's GPU or the production FS battle camera.
- [R8 full GitHub handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R8_HANDOFF_20261121.md) · [Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R8_FAILURE_LOG_20261121.md) · [Short Status](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R8_SHORT_STATUS.md).
- PRIVATE Drive [R8 full 98-file Godot ZIP](https://drive.google.com/file/d/1lEMQoZ6ayaNC6UV3IorvXjQPGuIBQ2mA/view), CRC PASS SHA256 `24ad0556d53213bf8e04a30a62ff729a3f798d06905118e99b0280b44d42d0ee`. [R8 real Godot bite GIF](https://drive.google.com/file/d/1Th_NZ6CFAxFfFiFim41U_NMCgFx-xyVq/view); [R8 vs R7 F5](https://drive.google.com/file/d/1t3iXet3N5BOUPXzf_2rg2Oz5LVdaxWDi/view); [R8 exact provider atlas](https://drive.google.com/file/d/1hr50GCxcvsKZ_LGGaJbRyF4hjfhqrmjg/view).
- **R8 ART_REVIEW_PENDING**, owner has not approved new GIF yet. Next complete macro unit = owner approval → lock exact R8 asset → true FS 45-degree production battle-camera integration. Do not restart frog, overwrite prior archives, touch T-A/T-C or main, or rebuild PC asset library. Source / images private Drive, programs GitHub.


---
## 2026-11-22 R8 Owner Art Acceptance / next real FS Battle integration
- User explicitly confirmed the revised TB02 R8 mouth bite with **「可以。繼續」** immediately after reviewing the R8 real Godot GIF and F5 comparison. Lock original R8 11F 128px mouth-bite atlas as **USER_ART_ACCEPTED**. R7 arm/claw attack remains REJECTED; user-approved PMD0001 frog V6 unchanged.
- DO NOT substitute the later illustration-generated Stage2/Stage3 concept sheets for the true PixelLab provider sprite sheets. Those have no per-frame identity/alpha/source-lock/native QA and are REFERENCE ONLY.
- New next macro unit **FS production-facing battle presentation integration**: hook source-shaped Tankentai ACT completed receipts, show approved sprite per explicit monster visual ID, F5 emits VFX/contact cue exactly once. F5 NEVER mutates HP, MP, action queue, original battle target or cost; FSBattle/FSActionQueue remains the sole gameplay resolver. Prototype must be opt-in on T-B branch only, with native Godot 4.7.2 QA. Do not claim FS 505 source-parity or verified production BattleScape if still blocked.

---
## 2026-11-22 R9 CURRENT | R8 OWNER ACCEPTED, REAL FSBattle + FSScreen NATIVE PASS, ORIGINAL BATTLESCAPE PENDING
- **Art authority:** PMD0001 V6 frog Attack and TB02 Leaf Bat **R8 mouth-only bite** are USER_ART_ACCEPTED. R7 phantom hand/claw remains rejected. The later illustration-based Stage2/3 sheets are references only, NOT source-locked PixelLab production sprites.
- **New T-B code**: `godot_port/experiments/pixellab_tb/FS_TBMonsterBattlePresentation.gd`. Loads R8 private Attack/Idle under exact SHA-256 and geometry, only when combat battler has explicit `fs_monster_visual_id=TB02_LEAF_BAT`. It watches actual `FSActionQueue.completed` successful enemy attack receipts, deduplicates action serials, plays 11-frame mouth-only bite, emits one F5 **VFX** cue and never changes HP/MP/ATB/target/damage.
- **Real FSScreen BATTLE UI opt-in** (T-B branch only): `godot_port/scripts/FSScreen.gd` mounts the source-locked presenter for an explicitly tagged enemy, and unbinds at MENU. Synthetic QA flag default OFF.
- **FULL FS native Godot 4.7.2 CI PASS:** [run #44962397741](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44962397741), job `137023852226`. Real FSBattle + enemy AI + ATB/ACT receipt test HP500→430, F5 one visual cue, extra damage zero. Actual FSScreen opt-in mount and MENU teardown PASS. Public CI uses synthetic art, not private PNG.
- **REAL PRIVATE R8 Godot 4.7.2 native PASS:** Attack exact SHA `b258678a7a4b59251b13126ed905c47afd9b9dffd0a618fbb64f584ad9ceeee7`, Idle SHA `5153e58ccf29dee9d924937fb185169f45e2d0f748a36373cc2f53d4eb72e0a2`. Original 544×416 presentation-stage screenshot generated with native Mesa OpenGL software renderer. Neutral demonstration backdrop, not original BattleScape.
- [R9 PRIVATE 18-file ZIP](https://drive.google.com/file/d/1UdMwxWx55o5hHlOnrhMdAlI5FAhyv8OX/view) (CRC PASS, SHA256 `19e1ab8bf3966ef31da1eabe19ba3fe6dd05224ee39c2512808b02a204370fdc`) | [R9 native screenshot](https://drive.google.com/file/d/1PsM21atnxGV0IzcX7Gu0OsXdzJcLHrOF/view) | [R9 full Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R9_HANDOFF_20261122.md) | [R9 Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R9_FAILURE_LOG_20261122.md).
- **HOLD:** Canonical original Enemy ID/Troop→TB02 mapping and actual FS BattleScape 45° camera remain NOT_VERIFIED. Damage still commits in FSBattle queue BEFORE cosmetic F5 cue; do not change/defer/reapply in T-B. Full 505 source parity NOT claimed.
- **NEXT COMPLETE UNIT:** source-confirmed enemy IDs and original BattleScape real camera gate, then T-A handoff. R9 PixelLab jobs=0 / generations=0. T-A/T-C/main unchanged; code GitHub; private raster/evidence Drive; no user-PC results repository.

---
## 2026-11-22 R10 CURRENT | USER OVERRIDE ART-ONLY, COMPLETE LEAF BAT 3-STAGE 4-MOTION BASELINE
- **USER OVERRIDE**: 「妳先不用考慮整合進戰鬥系統，專心把怪物都生成好，我們怪物需要的動作很多，整串進化鏈也還沒做完」. STOP battle engine/UI/ATB/ACT/BattleScape/Enemy-ID integration. R9 is historical, not a next step.
- **REAL NEW PIXELLAB ART**: TB02 Leaf Bat 3 stages EACH with own-source Idle8, mouth-only Attack11, Hurt6, KO8 = **12 clips / 99 original frames**; 10 new motions, first-stage original R8 owner-approved Attack unchanged. Stage2 160px, Stage3 192px Idle and 224px mouth Bite/Hurt/KO. 12/12 technical QA PASS; no missing atlas or boundary clipping in selected releases.
- **Cost/provenance**: 11 actual PixelLab Skeleton v3 jobs * 3 generations = 33.0 generations, including one rejected stage3 192px Attack with F5 edge touching 3px. Corrected by re-generating 224px padded source (new job, true 11 frames), NOT pixel retouch. TB02 lifetime usage 25.0+33.0=58.0 generations; USD cost not reported.
- **Godot 4.7.2 ART-only native PASS**: independent 3-stage gallery displays each unique 4 action sprite-sheets, 12/12 clips validated; Xvfb Mesa llvmpipe OpenGL original 1280x768 F5 screenshot captured. Does not touch the real FS battle system.
- PRIVATE ZIP [R10 51-file original sources, PNG atlases, animations, QA, Godot art gallery](https://drive.google.com/file/d/1Hlm9Fo2F1MYrrpzForejRN2P25EaEfBZ/view) SHA256 `615edf4913337b6d3a4bf722681d363babbdc3e098797974d036870f9b06d37d` / ZIP CRC PASS. [3-stage four-action visual matrix](https://drive.google.com/file/d/1R0Sf8Gu9kJ1Zh7ZexHfMT2rTuSW4eA-t/view); [Original native Godot F5](https://drive.google.com/file/d/1H-AZ3zkr51kOLK7TOwu7wvAEnaaBy5-A/view); [three-stage mouth Bite GIF](https://drive.google.com/file/d/15P4Y5d_QtRLsguuoepngWwteJEi7rBGM/view); [Hurt GIF](https://drive.google.com/file/d/1ahU5FpvO8hR7vAUe5ei6V9dKgH0dQFmg/view); [KO GIF](https://drive.google.com/file/d/1iVt-IES_DqjAq8U_67HXuB6EWVvibOQn/view).
- ART gate: only original stage1 R8 Bite was **USER_APPROVED**. All 10 new animations **USER_ART_REVIEW_PENDING**; Stage3 mouth F5 smaller than Stage2; don't equate technical QA with aesthetic approval.
- **NEXT MACRO**: finish original PMD Lava Frog Stage2/Stage3 own-source Idle+Attack and then Hurt+KO, followed by the motion-expansion wave Guard/Skill/Fly for both 3-stage families. No business/gameplay integration. Keep code and docs GitHub/T-B, all original sprites and proof private Drive. Do not leave permanent user PC assets.

---
## 2026-11-22 R11 CURRENT | ART-ONLY evolution family complete | STOP battle UI/integration
- User explicitly prioritizes monster art, many motion clips, and complete evolution chains; T-B stops all BattleScape/ATB/ACT/Enemy ID/UI integration until told otherwise.
- R11 PMD lava frogs 3 stages now each have authentic separate Idle / Attack / Hurt / KO. Stage1 keeps original 3F Idle and user-approved PixelLab V6 11F Attack unchanged, with new independent Hurt 6F, KO 8F. PMD0002/PMD0003 each independently source-lock their own original 64px PNG to generate 8F Idle, 11F quadruped mouth Attack, 6F Hurt, 8F KO.
- **R11 = 12 clips / 94 frames; 10 REAL new PixelLab Skeleton v3 jobs x 3.0 generations = 30.0 new generations** (USD not reported). All 10 new clips tech PASS: nonempty alpha, zero border, ≥3 distinct RGBA frames, original source SHA, real Godot 4.7.2 isolated art gallery 12/12 imported and Xvfb/Mesa native 1280x768 screenshot PASS. New clips remain ART_REVIEW_PENDING; original PMD0001 V6 Attack owner accepted.
- Prior R10 Leaf Bat = 3 stages / 12 clips / 99 frames, 33.0 generation costs across 11 provider jobs including rejected clipped F5 first attempt. **Two families total 6 forms / 24 clips / 193 sprite-frame slots** (not full action checklist nor owner approval for all).
- [R11 68-file private art ZIP](https://drive.google.com/file/d/1JZdf929b8ieFi-TUZ_LEkAjMFcXUd0pp/view) SHA256 541285fff326c968e80d570e24e510f925f792e180bb0b114055f0501347f0ee CRC PASS; [3x4 matrix](https://drive.google.com/file/d/1fir3IVS6AIkL1Rqzg6QGAp6_F-wWLmol/view); [real Godot native screenshot](https://drive.google.com/file/d/1qcp7wYB5UY_0Bx9f5FYBfbcgSaU7Pz3C/view); [full R11 Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R11_HANDOFF_20261122.md).
- Next ART macro: add Guard/Skill, species locomotion (frog walk/hop, bat fly) for all 3 stages; benchmark third species; never return to battle-engine work under current mandate. No main/T-A/T-C changes, images private Drive, scripts/docs GitHub T-B. Windows API credential runtime files temporary only, clean after Drive readback.

---
## 2026-11-22 R12 CURRENT | MONSTER ART 7-MOTION BASELINE | NO BATTLE INTEGRATION
- User override remains authoritative: focus 100% on generating complete monster stage graphics and multiple animations. No BattleScape/ATB/ACT/UI integration; T-B isolated branch.
- R12 truly generated new unique motions FROM ORIGINAL STAGE SOURCES: Leaf Bat Stage1/2/3 each Guard 7F, Skill 8F, Fly 8F; PMD Lava Frog Stage1/2/3 each Guard 7F, Skill 9F, Hop 10F. These are 18 genuine PixelLab Skeleton v3 jobs / 147 original output frames, all 18/18 technical QA PASS. Each successful job provider usage 3.0 generations; R12 cost 54.0 subscription generations. USD not observed.
- R12 combined private art review: Two species families x three stages x seven actions = 6 forms / 42 clips / 340 authentic frame slots. All original R10/R11 atlases copied byte for byte. PMD Stage1 approved V6 bite and TB02 Stage1 approved R8 bite untouched.
- R12 Godot 4.7.2 actual standalone art-only native test FS_TB_R12_GODOT472_NATIVE_ART_ONLY_PASS clips=42 frames=340 stages=6 actions=7; independent Mesa llvmpipe/Xvfb native 1280x900 screenshots GUARD, SKILL, LOCOMOTION PASS. No combat changes.
- Private Drive ZIP (137 files, 2,938,340 bytes, SHA256 a06510611f4b765b352a45bf8abf425d48ad2d688a78c45c5a20f1c06d938c82, CRC PASS): https://drive.google.com/file/d/1X3K9lPmXdIdLYRP7i6STLjhVXesR1Yef/view
- Private review contact sheets BAT https://drive.google.com/file/d/1n28BDcaW7y05Dc7yUa35RsdgzycIdcln/view ; FROG https://drive.google.com/file/d/1CCXZDpu8ktahvziK5PovOrzDGeQCXtyl/view ; native Godot GUARD https://drive.google.com/file/d/13iRBak09ZQMt8hOE8loZe_rVtV_Dn6kF/view ; FULL original pixels and 18 GIFs only in private Drive ZIP.
- Explicit failure tracked: first high-stage bat fly submit rejected with HTTP429 concurrency cap 8; retried, new job succeeded and 8F validated. Draft builder corrected frog Skill 9F; Godot gallery parser corrected invalid named call. No PixelLab reroll needed for these code issues.
- Very important: all 18 R12 new motions OWNER_ART_REVIEW_PENDING despite technical PASS; source-approved older bites remain approved. Do not call full species art complete for all future actions, additional facing directions, attack variants, status and transformation animations.
- Next ART unit: monster-specific Charge, Cast Release, Stun, Revive, Evolve transformation (and needed directional movement), then benchmark a 3rd species evolution chain. T-B never touches main, T-A, T-C, FSBattle or battle UI. Code/docs GitHub; private raster artifacts Drive only.

---

## 2026-11-22 R13 CURRENT | 2 SPECIES × 3 EVOLUTION STAGES × 9 ANIMATIONS | NATIVE ART-ONLY PASS
- **User override still authoritative**: T-B does MONSTER ART ONLY, not battle engine / HUD / AI / ATB / ACT / Enemy ID or T-A/T-C/main.
- **Genuine new source-locked PixelLab**: 12 successful NEW Skeleton v3 provider animations, **each 8 frames**. Both TB02 Leaf Bat and PMD Lava Frog, each Stage 1/2/3, gain **STUN** (disoriented species-correct wobble) and **TAUNT** (fanged bat scream / magma frog croak). All new clips have distinct source per evolution stage, exact SHA-linked authorized originals, no touch to V6/R8 approved mouth attacks.
- New **12 clips / 96 original frame slots**, 12 jobs × 3 real provider-reported generations = **36.0 subscription generations**; USD price unreported; **12/12 new atlas QA PASS**. Cumulative **6 original forms / 54 clips / 436 original slots / 9 actions per form**, prior R12 42 atlases retained byte-identical.
- **Genuine Windows Godot 4.7.2.stable.official.ed1daf0bf native engine import and headless gallery test PASS**: `FS_TB_R13_GODOT472_NATIVE_ART_ONLY_PASS clips=54 frames=436 stages=6 actions=9`. R13 technical engine playback PASS, new R13 non-headless renderer screenshot NOT_CAPTURED. Native review contact images are generated from genuine original source frames, not claimed as Godot screen capture. New 12 actions remain **OWNER_ART_REVIEW_PENDING**, not USER_ART_ACCEPTED.
- **Verified private Drive ZIP**: [FS_TB_R13 190-file full original art + Godot + GIF bundle](https://drive.google.com/file/d/1PGNJZfHKsL66zl1G1K-l-r4X6lYq_dEN/view), **3,984,990 bytes**, ZIP CRC PASS, SHA256 `eebd4d0e1bb12252d8ae1bea8fef87227ce7b9719a71f0da1539b19ea79492d7`. Real Google Drive readback confirms `shared=false`, same folder. [Leaf Bat contact](https://drive.google.com/file/d/1v1SpdSMBmtdQ17tRNZePkS1e_v3-mEe2/view) | [Lava Frog contact](https://drive.google.com/file/d/1ivnLsSQHMATIO7WReXZSB08wvhVxsXWe/view) | [Native log](https://drive.google.com/file/d/1edaQdofOzn0vhxzPXFMu2eEEZDHBfyI7/view) | [provider ledger](https://drive.google.com/file/d/1Yb4KYwJVv6pUEFIr8p5L--6KR5BXIaKB/view).
- [R13 full handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R13_HANDOFF_20261122.md) | [R13 failure log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R13_FAILURE_LOG_20261122.md). Windows CP950 stdout parsing error repaired and re-run; no image rerolls.
- NEXT ART full unit: exact-authorized family **Charge / Cast Release / Revive / Evolve Transform** and evaluate 3rd distinct specimen after visual review. No battle work and no renumbering of previous clips. PC temporary outputs **to be cleaned after verified Drive readback**, never a local permanent image database.


### R13 release finalization (2026-11-22)
- **Animated real-frame visual review (private)**: [Leaf Bat three stages / STUN+TAUNT GIF](https://drive.google.com/file/d/1L9tbWsuY2XfWEiHsEIzU0Q9YJ56mhhcf/view), [Lava Frog three stages / STUN+TAUNT GIF](https://drive.google.com/file/d/1UbN2HRU54wAERMz1Mc4rHdFZzpXy-Sig/view). These are frame-accurate previews, NOT replacements for RGBA original PNG source clips.
- **R13 ephemeral PC cleanup FINISHED**: after private Google Drive synced readback, removed **117 strictly R13 temporary files**, retained original R10/R11 work, preserved R13 private Drive ZIP intact; rechecked the 190-file ZIP's full SHA/CRC after cleanup. Handoff is no longer TEMP_CLEANUP_PENDING; state **P0_TEMP_CLEANUP_VERIFIED**.
- Nine actions × six stages, 54 clips / 436 source frame slots; Windows Godot 4.7.2 engine QA PASS. New R13 ART remains OWNER_ART_REVIEW_PENDING.


---

## 2026-11-22 R14 CURRENT | THREE NEW ANIMATIONS / STAGE + SOURCE-EXACT EVOLUTION FX | ART-ONLY
- **User's art-only override remains in force**: NO battle engine/ATB/ACT/UI/Enemy-ID, no edits to main/T-A/T-C.
- Existing TB02 Leaf Bat and PMD Lava Frog 3-stage source-authentic creatures preserved. Two original owner-approved stage1 bite atlases PMD V6 and Bat R8 untouched; **54 R13 PNG atlases unchanged byte-for-byte**.
- **18 NEW REAL PixelLab Skeleton v3 successful jobs** (3 per stage per 6 forms), **10F Charge, 9F Cast Release, 11F Revive**, 180 original output frame slots. Every stage uses original source SHA. Release derives first-frame from **real preceding same-stage Charge F6**; Revive derives from **original KO F7**. Provider reports **54.0 generations** (18 jobs × 3). USD not reported. All 18 new technical QA PASS.
- Four **source-locked procedural 16-frame evolution VFX** (Bat/Frog 1→2 and 2→3), old/new form exact original RGBA source on F0/F15; middle is deterministic pixel dissolve + sparks, **NOT PixelLab-generated morph**. 4 clips /64 additional frame slots, ART review pending.
- R14 cumulative **two separate families / six stages / 12 real PixelLab action atlases per form = 72 base clips (616 slots)**, plus **4 procedural evolution clips (64 slots)** => **76 total art-only clips and 680 frame slots**.
- **Godot official 4.7.2.stable.official.ed1daf0bf Windows native actual PRIVATE PNGs**: editor headless import PASS, art-only `FS_TB_R14_GODOT472_NATIVE_ART_ONLY_PASS baseline=72 evolved=4 clips=76 frames=680 stages=6 actions=12`. No new non-headless render screenshot and no battle integration; technical PASS is not human ART PASS.
- [Verified PRIVATE R14 272-file complete ZIP](https://drive.google.com/file/d/1X3V0Mk6ppVyNwLthZkYoLpqGGjLG8Cem/view), **6,439,086 bytes**, CRC PASS, SHA256 `07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575`, Drive owner-only shared=false.
- [Leaf Bat R14 3-stage art contact](https://drive.google.com/file/d/1SGMgFoiBo0rA4fitvY_6IQ-av50OTMJu/view) | [Lava Frog art contact](https://drive.google.com/file/d/1KP5BpsR5jxkBsL3gFZ-ijn-1inHO2cgi/view). Four procedural evolution GIFs: [Bat 1→2](https://drive.google.com/file/d/1lL-RbhnLcrSJWXgRR2nFvlGszH6u9sEd/view), [Bat 2→3](https://drive.google.com/file/d/1gCTMoEG73HrKy8MxOZRI_BWmZCHuiuDf/view), [Frog 1→2](https://drive.google.com/file/d/1P5wHXe7LoNyG6vKZJDOkFb4xwQO_82Fe/view), [Frog 2→3](https://drive.google.com/file/d/1XSvRZr7RjuPTE2K_xd4Z0Y8L7-q9pDy8/view).
- **ART REVIEW PENDING**: Bat Revive mid-animation visibly shifts away from locked SE 3/4 view, Frog Revive facing needs GIF check; evolution effect is dissolve, not true morph. Do NOT mark full art accepted based on native PASS.
- **P0 TEMP CLEANUP VERIFIED** after Drive readback: removed seven R14-specific temporary outputs, preserved R10–R13, revalidated original ZIP hash after cleanup. GitHub pinned code replay fixed. No private raster submitted to GitHub.
- [R14 complete Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R14_HANDOFF_20261122.md) | [R14 Failure Log and recovery](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R14_FAILURE_LOG_20261122.md).
- **Next complete art-only macro unit**: address blocking Bat Revive off-angle (and Frog Revive facing) with max 2 bounded pose-controlled iterations, native playback/review gate, then third distinctly different species' complete three-stage template. Do not return to old R9 combat wiring.


---

## 2026-11-22 R15 → R15P CURRENT | THREE SOURCE-LOCKED FAMILIES + SOURCE-SAFE FROG REVIVE | OWNER ART HOLD
- **Scope invariant:** T-B monster **ART ONLY**, no FSBattle / combat ATB/ACT/HUD/Enemy ID, no main/T-A/T-C edits. R14 original ZIP and existing 76 atlas clips preserved.
- **R15 genuine PixelLab** new third species **TB03_GLACIER_JACKAL**: stage1 new Pixen original → stage2/3 edit-image derivative locked with stage predecessor source SHA, all three visually distinct. 12 new genuine 8-frame action clips: 3 stages each Idle/Attack/Hurt/KO. Six original Bat/Frog 10-frame KO→Idle source-anchored Revive V3 AI candidates. Total R15 18 genuine jobs, 174 true raw provider returned frames, 156 exported slots inclusive of exact original source endpoints; **R15 provider usage 68.0 generations** + 3 source generations + **3.0 rejected** clipped Frog S1 original trial = **74.0 provider-reported generations, USD not reported**. Rejected art and provider job provenance retained in private ZIP.
- R15 native official Windows Godot **4.7.2.stable.official.ed1daf0bf** imported and tested: `FS_TB_R15_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=802 third_species_actions=4 revised_revives=6`.
- [Verified owner-only R15 354-entry ZIP, 9,302,874 bytes](https://drive.google.com/file/d/1svlqtT0M3e88n62FH_qF8afUlIr9qqyK/view) SHA256 `5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c`. [Third family three-stage 4-action original contact](https://drive.google.com/file/d/1hWEjGXs9PrfFhtMwR6gBMUmB3nEXprrZ/view).
- **R15 ART HOLD found by actual visual inspection**: Frog V3 Revive produced giant detached magma/flame figures despite alpha/native PASS; Glacier Jackal three-stage KO animations fail to show visibly collapsed defeated creature. Never designate owner art accepted.
- **R15P corrective actual art work**: all Frog stages now get an 11-frame actual source pixel retime: genuine same-stage KO 8F in reverse (defeat→rise) then actual Idle first 3 frames, 0 new AI cost, source SHA and real pixel lock. Non-destructive historical R15 AI Frog candidates retained. Total R15P **3 families / 9 stages / 84 authentic motion clips + 6 independent programmed evolution FX clips = 90 clips / 805 original-source frame slots**. Wolf still only **4 of required 12 actions per stage**, KO ART HOLD.
- R15P **actual native official Windows Godot 4.7.2 PASS** `FS_TB_R15P_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=805 frog_source_retime=3`.
- [Latest R15P owner-only 373-entry ZIP, 9,643,175 bytes](https://drive.google.com/file/d/1Hr-nshnDqyAXnlEMP3g-VyiD_nPnAsdo/view) SHA256 `a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7`, CRC PASS and Google Drive metadata verified `shared=false,user:owner`. [Real Frog R15 fire error vs R15P source-safe three-stage comparison](https://drive.google.com/file/d/1CXr-7U2Blxc83-aIinJI2ZYo_S-a1da_/view); [Stage1 real GIF](https://drive.google.com/file/d/1i5537mb2LI5Bdlp23Q1f4eNLy49N6WrT/view) | [Stage2 GIF](https://drive.google.com/file/d/1XMN7zFKbPhBuFS56V9_-VUPFlXN2rMI8/view) | [Stage3 GIF](https://drive.google.com/file/d/1wOQJvFMkmzpQzLEqh58oz57szaRz16G_/view).
- [R15 detailed Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R15_HANDOFF_20261122.md) | [R15P latest Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R15P_HANDOFF_20261122.md) | [R15 genuine failure log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R15_FAILURE_LOG_20261122.md) | [R15 Art acceptance](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R15_ART_ACCEPTANCE_PROTOCOL_20261122.md).
- NEXT fully executable ART macro: remake Frost 3× KO into genuine on-ground collapsed motion (current KO native TECH PASS but ART FAIL), then create three-stage remaining 8 action types each (Guard/Skill/Locomotion/Stun/Taunt/Charge/Release/Revive) with real source-locked PixelLab, maintain no battle integration. All images private Drive, GitHub only scripts/Handoffs.
- **P0 TEMP cleanup** is to be performed ONLY after verified private Drive R15+R15P ZIP SHA/CRC and content readback; archive all rejected providers and avoid deleting original R10–R14 files.


### R15 / R15P P0 closeout | 2026-11-22
- Owner device actual `cleanup_tb15_r15p_ephemeral.py` executed and **P0_TEMP_CLEANUP_VERIFIED**: after private Google Drive owner-only readback of both R15 (354 files / SHA256 `5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c`) and R15P (373 files / SHA256 `a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7`), safely removed exactly **9 allowlisted R15/R15P TEMP outputs**, preserved R10–R14 originals and all cloud images, reran **full ZIP SHA256 + CRC + entry counts after cleanup: PASS**.
- Original R15 rejected PixelLab Frog S1 Revive PNG and genuine billed usage record confirmed present in private R15 ZIP *before* cleaning TEMP. Never misrepresent this cost or error.
- R15 `orchestrate_tb15_native_release.py` was corrected to pin the actual source-tested builder commit `8bd7f67f6fdce1b3b281fb83f00889610cecbc3c`. Current recommended playable art-only review package is **R15P**, but Wolf KO remains OWNER ART HOLD and remaining 24 Wolf actions unbuilt.
