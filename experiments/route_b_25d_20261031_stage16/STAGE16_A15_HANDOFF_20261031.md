# Forest Symphony Stage 16 A15 — 格點恢復原生工具實測交接

日期：2026-10-31。**真正的原始 A14 AI PNG 輸入 PASS；獨立格點轉換工程 PASS；外部 perfect-pixel 上游核心確實執行 PASS 但要求的尺寸契約 FAIL；Ground3 像素美術 FAIL；Godot / RPG Maker VX 實機 NOT RUN；Formal Seal NO。**

## 來源與範圍

- 保留 A10–A14 的全部已有基準和 FS 正式專案，沒有修改既有 Ground／PAR、碰撞或 Game.exe。
- 唯一美術來源是 A14 先前確實生成的 RGB 原始圖 `A14_GENUINE_AI_SOURCE_1435x1096.png`（1435×1096；SHA256 `4701511907354048515a969f88f18b77bd5608f6259c286335c7c78f29c6dca7`），中心裁切到 1433×1096。此次沒有再次發動 AI 生圖，也沒有使用 Ground3 原始私有圖做新的素材拷貝。
- A14 原始 PNG 和完整 ZIP 已補齊 Google Drive `STAGE16_A14_GENERATIVE_ART_20261031` 資料夾，A15 可直接透過相同的私有來源實測。

## 原始 AI 圖是否存在可恢復的格點？

實作原始影像的「差分邊界模格距週期檢查」，搜尋每軸 2–16px。用真正 4×4 最近鄰整數像素格的人工陽性控制，測得 4px 的極強週期訊號，亦會在 8px 等諧波位置出現強訊號（所以不能單看最高峰猜原始 pitch）。A14 原始圖最高雙軸峰值比值僅約 **1.0272**；未達測試前設定的 2.0 篩選門檻。這只表示**此簡易方法沒有量到強週期格點**，不是全世界所有格點恢復方法的否定證明。

## 本機第一輪：固定格點對照（獨立實作，非 PixelPipeline 原生 node）

使用 NumPy/Pillow 在固定分數來源格內取 5×5 色彩樣本，選取與分量中位數最接近的實際取樣像素（robust medoid）；與中心單點取樣做 A/B。輸出可選 128／64 色無抖動色盤。直接產生以下 544×416 新 PNG：

| 方法 | 色數 | 幾何格點驗證 | 美術判定 |
|---|---:|---|---|
| A14 Lanczos 128 色基準 | 128 | 未指定固定 2px 方塊 | 細節破碎、偽像素 |
| A15 544×416 robust | 128 | 1px output raster（非自動恢復原始格點） | 細節破碎 |
| A15 272×208 robust，再最近鄰 2× | 128 | 每個 2×2 色塊完全一致（100%） | 植物花朵形狀被簡化 |
| A15 272×208 center，再最近鄰 2× | 128 | 2×2 色塊完全一致（100%） | 隨機雜色較突出 |
| A15 136×104 robust，再最近鄰 4× | 64 | 每個 4×4 色塊完全一致（100%） | 失去多數植物細節 |

以上的 100% 只代表輸出「幾何格點均勻」，絕非 100% 藝術像素品質。四區域原生 32px 最近鄰放大、六版本原生 1× 比較圖均已輸出。

## 真正的外部工具上游測試

在授權的 Windows DESKTOP-90VT437 隔離目錄 `E:\FS_ROUTE_B_STAGE16_A15_PIXELPIPELINE_UPSTREAM_20261031` 成功 `git clone` **PeaarLi/ComfyUI-PixelPipeline**，固定 commit `55002622ece5153eab8d485be7a8de5bf64db5d2`，隔離安裝它使用的 `perfect-pixel==0.1.4` 上游核心。透過 Google Drive 同步的原始 A14 PNG，實際呼叫 `perfect_pixel.get_perfect_pixel`，manual grid、`sample_method=median`、`refine_intensity=0`、`fix_square=False`，沒有重新發動模型生圖：

| 傳入上游函式要求 | 真正回傳的尺寸 | 產出 PNG | 能直接整數倍成為 544×416？ |
|---|---|---|---|
| 544×416 | 478×365 | 是，SHA256 `6ff41ffa1341df847b5573b9d0a45948b1bc69896788a9a0e7c3110517c858ec` | 否 |
| 272×208 | 286×219 | 是，SHA256 `f7c51efd3e2aa996e88414490c45eec29d362ad226d84f656ec8762e7fc14464` | 否 |

兩者非合格 VX 原生輸出；沒有強制把不合尺寸的圖片拉伸來冒充 544×416。其實際 PNG、Windows 原始腳本和執行 JSON 也已從 Drive 同步回 A15 ZIP。此為**原生上游函式庫核心**的真實測試；**尚未直接啟動完整 `ComfyUI-PixelPipeline` V3 node**。當前實驗 ComfyUI v0.3.40 環境也缺少該節點要求的 `comfy_api.latest`，因此不能把這次稱為 node 端到端 PASS。

## 門檻評估

- 原始 PNG SHA256 和轉換輸出完整性 PASS。
- 強制規則 2×2／4×4 色塊生成 PASS。
- 維持自然草葉、花朵與 ground3 原生 32px 美術：**FAIL**，不是色盤或整數放大就能補回先前細節。
- 外部上游核心實際執行 PASS，但 requested manual logical grid 結果不符合輸入規格：**FAIL**。
- Ground3 真正原圖沒有在 A15 本地容器中進行直接同畫面參考並做使用者視覺簽核，絕不可宣稱原始風格 PASS。
- Godot／VX Game.exe／PAR／碰撞全部 NOT RUN；Formal Seal NO。

## A16 研究決策

停止同一張高解析 AI 地圖反覆改小格點、改調色盤。要測試**原生邏輯像素的專用美術生成／原生局部重畫**，而不是希望下採樣能重新創造本來就沒有的草葉輪廓。另可先在獨立版本相容環境測官方完整 V3 PixelPipeline node 的「By Grid Count」，但即使工程上成功回傳所需尺寸，也仍須先檢驗原生 32px 植物形狀；不可拿幾何 PASS 當藝術 PASS。

所有來源、固定格點轉換、外部核心輸出、格點診斷與失敗紀錄已納入私有 A15 ZIP。GitHub 只放程式碼、狀態和 SHA，沒有公開原始地圖或 AI 模型權重。

**A15：ENGINEERING PARTIAL PASS / EXTERNAL TOOL TARGET SIZE FAIL / ART FAIL / GODOT NOT RUN / VX NOT RUN / Formal Seal NO。**
