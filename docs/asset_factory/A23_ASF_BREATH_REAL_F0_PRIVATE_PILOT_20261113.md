# A23｜Agent Sprite Forge 0.6.0「呼吸」方法對 FS 真實 Actor01 F0 的第一次免費影格實測
日期：2026-11-13；**REAL F0 → REAL PNG/GIF OUTPUT；TECHNICAL DEMO ONLY / ART HOLD / VX NOT_RUN**

## 先說結論
這次不是只有寫規範：已從私人 Drive 回讀 A18 來源 ZIP，以**真正核准 48×48 Actor01 F0** 在 ChatGPT 隔離執行環境實際運算，產生 3 個 48×48 PNG 槽位、2-phase 原始呼吸 GIF、3-slot Waiting 示範 GIF、144×48 Waiting/原始 A62 RUN 兩個 Native Sheet、放大比對圖、測試碼與 QA JSON。

**保留限制：**這是依照 upstream `pixel_motion.breath_drawing` + `forge_pixelgrid.feet_runs/components` 原始程式演算法做的**FS 用 Python 局部移植／實際執行**，**不是完整 agent-sprite-forge CLI 運行**；沒有 image-to-video provider、新 RUN 或任何 PixelLab 生成。並未達成 FS 要求的三張**不同**自然 Waiting 姿勢；第 3 個槽位是 F0 的**明確重複**。它只展示零付費、零重畫的原始角色 identity-lock 二相位 breathing；**不能宣稱量產 PASS。**

## 真實來源與版本
- upstream 固定 commit：`0x0funky/agent-sprite-forge@25203d03900b46b444bdd72a75768c33d1895ad6`，版本 `0.6.0`。
- 原始演算法：`skills/video2dsprite/scripts/pixel_motion.py`，`breath_drawing`、`cmd_breath`，依賴 `forge_pixelgrid.py` 的 `feet_runs/components`。本輪不直接執行 upstream CLI，也沒有默默安裝到使用者 PC。
- A18 private source ZIP：`FS_A18_ACTOR01_RUN_PROVIDER_READY_PRIVATE_20261109.zip`，下載 SHA256 `f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c`。
- 原生 48x48 F0 PNG SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`；A62 三幀從同一 A18 私人 ZIP 読出；原來源未覆寫。
- 個人美術檔僅保存在 owner-only Google Drive，公開 GitHub 不存 PNG/GIF/base64/Drive 私人密鑰。

## 真正產物與 QA
- 原始 A23 `ACTOR01_A23_WAITING_1/2/3.png` 各 48×48 RGBA：`F0=原圖`，`F1=ASF 風格呼吸壓縮畫格`，`F2=F0`（重複，不冒充新姿勢）。
- `A23_WAITING_3SLOT_144x48_CANDIDATE.png`：格式/三槽位可供 Adapter 用，但美術尚不可用。
- `A23_A62_RUN_NATIVECONTRACT_144x48_REFERENCE.png`：直接由原版已核准 A62 的三張 PNG 拼出，**只是 unchanged PASS-THROUGH**，不是 A23 新 RUN。
- `A23_ASF_BREATH_RAW_2PHASE.gif`、`A23_FS_WAITING_3SLOT_CANDIDATE.gif`、`A23_A62_APPROVED_RUN_REFERENCE.gif`、1x 來源/7x 比對聯絡圖、原始 Python 試驗程式、`fs_a23_test.py`、JSON/README。
- 真實隔離 Python 執行 `8/8` 技術核對：來源 F0 pixel-exact、45° 原圖方向不變、透明 Alpha 只有 0/255、輸出只使用原調色（沒有新顏色）、48×48 ×3、F1 與 F0 有 327 pixel-level changes、F2 與 F0 相同，A62 reference 的 144×48 每個欄位都和私有原本 3 幀逐像素相符。
- F1 呼吸圖角色頭/身體高度的單格壓縮視覺偏明顯，**agent visual ART HOLD**。尚無使用者核准；神情/呼吸自然度失敗原因應標 `BREATH_LOWER_LEG_ROW_COMPRESSION`，不應繼續硬當 Run/Attack。
- 沒有真實 provider 影片、沒有 PixelLab 扣額、沒有真實 VX Game.exe，不能由 8/8 推廣到真正美術 PASS。

## 雲端實際封存（WRITE→READBACK→SHA / CRC VERIFIED）
- 正式 R2 private package：`FS_A23_ASF_BREATH_ACTOR01_PRIVATE_R2_20261113.zip`，`53,658 bytes`、`14 files`、`SHA256 41b4dc8c4a0a4195afa5363bd990a8ffadc8c35e26276128c2cfb8152673caac`。
- Google Drive file URL（owner-only）：https://drive.google.com/file/d/1E8JB4QhH_qlzxGTti_VFjMEgfn2cmk0_/view
- Google Drive parent：`FS_AI_ASSET_FACTORY_Restricted_Binaries`，元資料 `shared=false`、owner only；Google Drive 再讀取下載到隔離環境，SHA一致；ZIP CRC `None`（全部 PASS）。
- 人眼快速預覽：2-phase GIF https://drive.google.com/file/d/17adYsicraf41zavlhMzeOtiZHnf2-fXk/view ；3-slot 聯絡圖 https://drive.google.com/file/d/1GH9yu1bk54zqQR6WiiM6xn4-7zHZYDt2/view 。
- R1 原始 ZIP `FS_A23_ASF_BREATH_ACTOR01_PRIVATE_20261113.zip` 為早期紀錄，R2 額外含實際 runner script、8 項檢測與真實 Native Sheet；R1 保留供失敗紀錄，不當作正式結果。
- 本輪無使用者 PC 資料寫入，不觸碰正式 FS main、A62/A18 原圖。

## 正反判斷／下一個驗證才有價值
成功：原版 48px F0 可以不用重畫、免費產生 2-phase 合法 PNG/GIF 與原生 3-slot 格式。失敗：不能靠這個呼吸演算法直接生成三個不同的自然姿勢；這不解決 RUN 雙腳交替或新怪物動畫。
**下一步**不能再只修呼吸演算法，應測 ASF 的真正 1x master→image-to-video→pixel_motion frames/finish 的 45° RUN，或者對應 PixelLab A18 已批准的骨架導出**一次**真正 provider RAW 3 幀。兩種途徑要先取得可使用的合法 provider 及明確費用限制；免費替代方案只做能真的產出像素動作的部分，絕不偽裝成模型已生成。對比相同原始 F0 和已核准 A62，先看新 PNG 再評價。

### Gate / Handoff
`SOURCE/P0 READBACK PASS`；`SANDBOX FREE ASF-ALGORITHM PORT EXECUTED PASS`；`3FRAME FORMAT PASS (F2_DUPLICATE)`；`8/8 TECH QA PASS`；`ASSET_QUALITY ART_HOLD`；`UPSTREAM_CLI NOT_RUN`；`NEW_RUN NOT_GENERATED`；`USER_ART NOT_RUN`；`NATIVE_VX NOT_RUN`；`PROVIDER_CALLS 0`；`MAIN UNCHANGED`；`FORMAL SEAL NO`.
