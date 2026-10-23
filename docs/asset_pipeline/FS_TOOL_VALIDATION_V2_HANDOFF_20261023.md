# FS / Shared Game Art Tool Validation V2｜下一對話交接（2026-10-23）

## 本輪 baseline / 不可回滾
- Forest Symphony 地圖權威：FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2（2026-09-21）及 Shared Scene Graph / Fail-Closed Rules
- PMD / CG / FS 現有已 SEALED VX Scripts / Map 絕不修改。
- FS_ForestSplit_v3_2：50/50 Gate A–E、9/9 Negative、Godot headless 與原生 VX Game.exe 真實截圖背景 RGBA/RGB 合規，狀態 Candidate，未封版。
- 新增工具庫 E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023；測試入口 RUN_TOOL_TESTS.cmd，11/11 AUTOMATED SMOKE PASS。
- Google Drive 測試目標文件： https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit
- 工具與 Ground/PAR 經驗長期主手冊： https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit

## 各工具狀態
- Sprite Fusion Sprite Normals 0.1.0：Rust 1.99.1 / VS2022 在隔離 Rustup + Cargo 已編譯官方 MIT CLI。七輸入 PNG 成功，Alpha 7/7，4-frame sheet visible exact；透明 RGB 差異 2308 是 alpha0 下 RGB 多樣，要 normalize 再比對。
- Laigter 1.14：兩種真實樹 + 四格 sheet，3x4=12 maps，全數尺寸/修復 Alpha 通過。
- Pixelorama 1.2.3：原官方含 Shader Layer Effect 6幀PXO 在 headless 0xC0000005 CRASH；剔除效果並修改 export_profile 的 TEST-ONLY PXO 後可 CLI 匯出 384x64六影格 sheet，六組獨立色塊全部保持不錯位；--output 舊版行為不可靠。
- Tiled 1.12.2：1088x832、24 props，Tiled vs Python 完整 RGBA 0 diff；1px X-shift sign 測出669 diff。
- LibreSprite 1.3：sheet+四格 PNG batch roundtrip 5/5 RGBA exact，四格切割由 Pillow 做。
- SpriteLab：Chrome/Playwright 實際產生並下載 normal PNG，size/alpha pass；未證明原始碼開源，P2 Browser-only。
- Sprite Fusion Web：Chrome/Playwright 產生並下載 normal PNG，size/alpha pass；download 按單檔 item 的 aria-label，非 generic Download。
- Godot 4.7.2 Radeon RX 6700 XT：GPU SubViewport 3 screenshots，光源位置造成2223像素變化、Normal 有無造成2321像素變化；Dummy/headless 沒有畫面，須 GUI OpenGL。
- VX：正式 FS Runtime 還未整合；獨立 RGSS2 Engine Test Build PASS / Human visual pass pending。

## 下一步需做的事
1. 使用指定參考圖 + 使用者指定合法素材集來建立可稽核 Scene Blueprint/Manifest，做真正有變化的「豐富」森林/精靈村小型場景（避免重複貼四次算豐富）；重用 Drive Approved Kit/Style DNA，先對齊 viewpoint/style/scale。
2. 每個物件唯一 world-space integer geometry、asset hash、semantic masks；Ground=草地/土路/地板/地面草花；Complete PAR=非地表所有物件；base/occlusion/collision/event 作衍生輸出。
3. Tiled 獨立渲染 vs Python Master strict RGBA + 1px negative；VX/Godot 遊戲實機，包含樹冠遮擋與碰撞；不能用圖層視覺 mockup 或 PAR opaque checkerboard 當PASS。
4. 更新 fs authority/docs/Linear SHO-39 和新的 handoff；不宣稱 FORMAL PASS 直到 user visual QA。
5. 如需正式批次 SpriteNormals 可直接呼叫已編譯 CLI，不用再手動安裝 Rust；如要分發 OSS 核對每套軟體 License（SpriteLab 待證）。

## 高風險失敗案例
- Pixelorama 無 --output 與 Shader Effect 在 headless 不可靠，需 native PXO export_profile / shader-free input 才有效；遇新 effects 需 GUI/另測試。
- 對全 Alpha=0 的 PNG，RGB 可以不同；法線貼圖的透明像素要 canonicalize；但完整 PAR/ground 仍需 byte exact QA。
- Godot headless 不產生 GPU 2D 視覺圖片；要真實 GPU/renderer evidence。
- 地圖不能把參考概念圖當 Geometry 唯一真值；沒有指定坐標就必須先建立 Blueprint，允許人工驗收。
- 測試產物私有 Google Drive，不要在公開 GitHub 推送未驗證來源或封版 Binary。
