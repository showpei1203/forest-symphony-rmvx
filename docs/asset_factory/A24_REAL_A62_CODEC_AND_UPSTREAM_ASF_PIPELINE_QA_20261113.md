# A24｜ASF 原版四指令＋FS Actor 48px 對接＋真實 A62 壓縮回復試驗
日期：2026-11-13 ｜狀態：**REAL SOURCE CODEC PASS / UPSTREAM CLI PASS ON SYNTHETIC / NATIVE ADAPTER SYNTHETIC PASS / NEW ART 0 / FORMAL SEAL NO**

## 已實際完成的事（不是研究計畫）
1. 從 owner-only Drive 已封存 A18 ZIP 回讀真實核准白髮 Actor01 F0 與 A62 三幀，核對原始來源 SHA。
2. 使用真正 A62 48×48 三幀 `F0→F1→F0→F2` 重播 4 循環形成 **16 幀、12 fps** 的純來源 MP4，經 ffmpeg H264 CRF18 yuv420p 編碼、OpenCV 實際解碼、8x 視窗中央子區域 median、原 A62 RGB 色盤最近色與 magenta key 判定、回復 48×48 二元 Alpha PNG；獨立於新的生成供應商。
3. GitHub Actions 在獨立 Ubuntu 雲端 Runner 真正 clone、checkout upstream **`0x0funky/agent-sprite-forge@25203d03900b46b444bdd72a75768c33d1895ad6`**，並執行實際原版 `pixel_motion.py breath→prepare→frames→finish`。合成 48×48 人形 + 靜態重播 MP4，非私人美術、不花模型費用。原版 `frames` 成功返回 24 幀、`finish` 成功輸出三槽位。
4. GitHub 新增原版 ASF 的安全 smoke runner、pinned upstream 工作流程，以及 **ASF → FS Actor 48px** fail-closed 轉換器。Adapter 強制 F0 以核准原始 bytes 替代供應商的 F0；保留 45° 原圖方向、48×48×3=144×48 的像素位置與錨點；無雙線性縮放；禁止模糊 Alpha、外來色盤、被裁切、非整數根點、三格相同。人物鏡頭與跑步節奏仍需 ART/原生 VX 判定。

## 真實 A62 本機隔離環境（非使用者 PC）的量測
- 來源 A18 ZIP：`19706 bytes`，SHA256 `f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c`。
- 正式 F0 PNG SHA256：`a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`。A62 三幀為原版 approved source，非此輪 AI 新畫。
- 原 A62 三幀合併可見 RGB 色盤 35 色；已知來源 PNG 每張 48×48，二元 Alpha。
- H264 16 幀回復：**中位 1 像素／幀不同；單幀最多 5 像素不同**（48×48=2304 像素，最大約 0.217%）；回復的 35 色沒有出現來源外顏色。這是**可預測、固定格線來源重播**的測試，只證明後處理保真能力，不是模型創新姿勢。
- 原始影片、16 幀逐格誤差 QA、PNG 144×48 靜態回復、原始 A62 GIF、放大對照、程式、README 放在 owner-only ZIP。
- **私人 Drive ZIP：**`FS_A24_ASF_A62_CODEC_PILOT_PRIVATE_20261113.zip`，`52737 bytes／7 files／SHA256 dce51a0d5ac3c5a41ec71ace984114250a2b4c8d194887379d56818500d8af58`。Drive WRITE→DOWNLOAD→SHA256/CRC 回讀吻合，metadata shared=false，唯一 owner。**禁止將此 ZIP 或私有原始圖像放到公開 GitHub**。

## upstream CI 真實執行結果／失敗與修復
- 首次 Run [43410460262](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43410460262) **FAIL_ENVIRONMENT**：ASF `breath`、`prepare` 已執行，但 Ubuntu Runner 找不到 `ffmpeg`。
- 第二次 Run [43410756037](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43410756037) **FAIL_ENVIRONMENT**：已給出 ffmpeg，但 upstream 真正影格解析另依賴 `ffprobe`；缺少探測器而失敗。前兩次均未證明模型或美術錯誤。
- 修復 workflow：Runner `sudo apt-get install ffmpeg`，真實驗證 ffmpeg + ffprobe，都在 PATH 中；不碰使用者 PC。
- 真正 upstream 0.6.0 四個動作通過的 CI：[Run 43410909471](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43410909471)，合成公開安全 evidence artifact `FS_A24_ASF_UPSTREAM_SYNTHETIC_PROOF`： `breath` 2 frames、`prepare` 8x grid、`frames` 24 frames、`finish` 3 frames；裁切後 `frameSize=[30,44]`，不是原生 FS 48px。
- 新 Adapter 10 個正反向單測及既有測試合計 **158/158 PASS** 的最新 FS CI：[Run 43411642701](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43411642701)；同一 HEAD 上游 smoke：[Run 43411642742](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43411642742) completed/success。
- ASF 的 `frames` 對完全靜止的假影片也能成功輸出 24 幀，`finish --pick` 能選出 3 個*相同姿勢*；所以**上游技術成功≠RUN三姿勢成功**，FS Adapter 必須嚴格判定 F1/F2 不同並人工審查左右步態，不能繞過 fail-closed。

## 現行程式與證據
- `tools/asset_factory/a24_upstream_asf_smoke.py`：原版 ASF 批次執行、公開合成 source、無提供者／無付費。
- `.github/workflows/fs-asf-a24-upstream.yml`：完整 SHA 固定、純合成素材、ffmpeg/ffprobe、上游 smoke 與 artifact。
- `tools/asset_factory/a24_asf_actor_adapter.py`：三幀角色單點原生定位、F0 位元保真、色盤/Alpha/裁切/動作差異防護，**僅產生 Candidate**。
- `tools/asset_factory/tests/test_a24_asf_actor_adapter.py`：10 個合成正／反例（包含非法 F0 SHA、不足三張、相同姿勢、外來顏色、半像素、視野裁切、非二元 Alpha）。
- 真實私人試驗程式 `a24_video_codec_probe.py` 已在上述 Drive ZIP；**這不是 upstream CLI**，不能混淆證據來源。

## 未解問題／下一個真正應施工的步驟
1. 新的供應商 I2V 影片或 PixelLab Skeleton v3 真正付費動畫皆**未生成**，其實用美術與 identity 實績仍為 0。User 權威已要求付費呼叫前要有一次明確費用上限與安全權限通道；無法以「繼續」或 CI 通過自動跳過。
2. 需使用核准 48×48 Actor01 F0 與已存在 A62 RUN 為對照基準；選一個真正 image-to-video 來源，在 F0 鎖定下做 **一段** 新 RUN，實際 decode、source palette lock、3 個不同關鍵姿勢、45°、左右腳 counterphase、1x Art Gate、native VX `Game.exe`，證明不只是復原舊動作。
3. ASF `finish` 自動裁切 30×44 已有 FS adapter 預備，但目前只跑過合成單測，尚未把真正 ASF 新輸出用原生 48×48 Actor01 TestCase 接上並完成人工驗收。
4. PMD 另遵循 AnimData.xml 的動作格數與方向，不能把此 Actor 三幀 adapter 冒充 PMD 原生格式。

## Gate 與 Handoff
- `FS_CANONICAL_F0_READBACK`: **PASS**
- `A62_H264_REPLAY_DECODE`: **PASS**（新動作 **0**）
- `UPSTREAM_ASF_V0.6_EXACT_PIN_CI`: **PASS SYNTHETIC ONLY**
- `FS_48PX_NATIVE_ADAPTER`: **PASS SYNTHETIC 10 CASES**
- `FS_FACTORY_ALL_TESTS`: **158/158 PASS**
- `PRIVATE_DRIVE_WRITE_DOWNLOAD_SHA_CRC`: **PASS**
- `UPSTREAM_PROVIDER_NEW_RUN`: **NOT_RUN**
- `USER_ART_NEW_RUN`: **NOT_RUN**
- `VX_NATIVE_GAME_EXE_NEW_RUN`: **NOT_RUN**
- `PIXELLAB_CHARGE`: **0**
- `MAIN_OR_SEALED_EDIT`: **NO**
- `FORMAL_SEAL`: **NO**

新對話：先讀 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`、P0 儲存規範、本 `A24`、`docs/asset_factory/CURRENT_HANDOFF.md`，再決定能否提交**一次真正的生成**。禁止回去大量疊加無新素材的骨架與壓縮重複實驗。主線仍是**新角色動作與高品質 Master-first Ground/PAR**。
