# 遊戲開源工具庫｜v2 實測操作手冊（2026-10-23）

## 核心狀態
2026-10-23 在 DESKTOP-90VT437 本機完整執行 scripts/run_all_tools.py，11/11 個自動化步驟通過。
分類：**TOOL_AUTOMATION_SMOKE_PASS_FORMAL_VISUAL_PENDING**。
通過的是「工具可重現執行、渲染物件和程式進入引擎」；沒有正式 Forest Symphony 大型地圖的人眼 Gate F，所以**不可標為 FORMAL PASS**。

## 使用方式（原本 Windows E 槽環境）
一鍵執行：`E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023\RUN_TOOL_TESTS.cmd`
測試程式：`scripts\run_all_tools.py`
機器報告：`reports\ALL_TOOL_TESTS_SUMMARY.json`
每一項詳細：`reports\T01_*.json` ... `reports\T07_*.json`。
累積實戰教學主檔：https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit
逐工具驗收目標：https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit

## T01 Sprite Fusion Sprite Normals 0.1.0
官網 https://www.spritefusion.com/sprite-normals
原始碼 https://github.com/Hugo-Dz/spritefusion-sprite-normals (MIT)
本機 Rust 已透過 rustup 官方 MSI toolchain 以 --no-modify-path、RUSTUP_HOME/CARGO_HOME 均放在本實驗目錄，**未加入系統 PATH**。
搭配本機 VS2022 Community vcvars64.bat，以 cargo build --release --locked 編譯通過。編譯成果留在本機原始碼資料夾 target/release/spritefusion-sprite-normals.exe。
已測七個 PNG 輸入（兩種真實樹木、四格圖集及四張逐格素材）；尺寸和 Alpha 7/7 相同、NormalRGB非均勻。--frame-size 32x32 後圖集在可見像素與逐格生成 100%相同。
**陷阱：透明像素 Alpha=0 的 RGB 值可以是 (128,128,255)，直接與 Pillow alpha_composite 產生的 (0,0,0,0) 做完整 RGBA 比對會出現 2308 假差異，但可見像素差異0；材質法線驗證要先將完全透明的像素 RGB 清零再比對，地圖 Ground/PAR 仍維持完整 RGBA bytes 嚴格檢查。**
可執行指令範例：`spritefusion-sprite-normals.exe image.png --output-dir output --frame-size 32x32 --normal-format opengl --force`。
如果要重新編譯，在隔離的 PowerShell 設定 RUSTUP_HOME、CARGO_HOME，並執行 VS2022 vcvars64.bat，再 cargo build --release --locked。
即便已能批次產生法線貼圖，它仍不會幫忙決定 Ground/PAR、遮擋或碰撞。

## T02 Laigter 1.14
官網 https://github.com/azagaya/laigter (GPL-3.0)
批次指令：`laigter.exe --no-gui --diffuse INPUT_DIRECTORY --normal --specular --occlusion --parallax --location OUTPUT_DIRECTORY`
3 個素材（Stage8A tree_A/B + 四格 sheet），12 張衍生貼圖全部輸出；RGB 法線 3/3 非平坦。注意原生 Alpha 部分不等於原圖，必須以來源 Alpha 修復，12/12 完成修復及驗證。真實美術 QA 另列。
詳細 JSON：reports/T02_LAIGTER_REAL_ASSETS.json。

## T03 Pixelorama 1.2.3
官網 https://github.com/Orama-Interactive/Pixelorama
可接受 .pxo 原生專案；直接將含舊動畫 Shader Effects 的官方 6 幀樣本餵到 headless，出現 Windows 0xC0000005 Access Violation，屬已記錄失敗，不可隱藏。
**繞過方法**：只在獨立測試副本將 `.pxo` 中 effects 清空，export_profile 目錄與名稱設定為預期路徑，用 `Pixelorama.exe --headless --quit -- --spritesheet --export project.pxo`，匯出 384x64 6 格圖集。另在六個 raw cel 位置製造不同 4x4 色塊，逐格驗證六個標記色完全匹配：6/6 正確。
已知另有 --output 在 1.2.3 可能默默失效、exit code 0 卻沒預期檔名，使用寫入 PXO export_profile 的路徑為相容 workaround。
限制：移除的是 **Shader 特效**，不能拿這組通過代表原始 Shader 動畫與效果都能 headless 匯出。應優先原生 PXO 純像素多幀作批次工作。
詳細：reports/T03_PIXELORAMA_SIX_UNIQUE_FRAMES.json 與原先 FAIL 紀錄。

## T04 Tiled 1.12.2
官網 https://github.com/mapeditor/tiled
使用既有 canonical source-first Scene Manifest 生成 1088x832 TMX（24 props），經 tmxrasterizer.exe 產生的 RGBA 逐像素與 Python Master 完全相同，差異 0；故意將一個路牌 X+1 會產生 669 個不同像素。
證明 **544x416 是 VX viewport 而非可製作地圖總大小上限**。大地圖在同一 Manifest 依然需要整數 x/y、source hash 與碰撞/遮擋語義。test-only TMX 在原 FS_ForestSplit_v3_2/work 底下，沒有修改正式 FS 專案。
詳情：reports/T04_TILED_LARGE_AND_NEGATIVE.json。

## T05 LibreSprite 1.3
官網 https://github.com/LibreSprite/LibreSprite
`libresprite.exe -b INPUT.png --save-as OUTPUT.png`
128x32 四格圖集 + 四張 32x32 單幀 PNG 透過批次另存：完整 RGBA 無損 5/5 PASS。
四格事前切割由 Pillow 完成，不能說 LibreSprite 自動辨識 PNG 內的四幀動畫。
詳情：reports/T05_LIBRESPRITE_SHEET.json。

## T06 網頁工具
SpriteLab：https://spritelab.dev/tools/normal-map-generator：Playwright 指定本機 Chrome，確實上傳 32x32 原圖並下載法線 PNG，尺寸與 Alpha相符。免費網頁工具，但**開源授權未證實**，不得歸類為正式 OSS 核心。
Sprite Fusion Web：https://www.spritefusion.com/sprite-normals：Playwright 上傳下載 32x32 Normal PNG，尺寸/Alpha PASS。陷阱：頁面普通「Download」按鈕不是單檔真正下載按鈕，正確目標是 `button[aria-label*="Download the normal map"]`。原始頁面誤點狀態保留 FAIL 紀錄，再於 T06B 通過。
腳本需要 Python playwright 已安裝在 `pydeps`，使用既有 Google Chrome，無須下載額外瀏覽器。相關網頁可用性依站方服務變更。

## T07 Godot 4.7.2 / RX 6700 XT
Laigter 真實樹木 Normal Map 搭配 Godot CanvasTexture+Sprite2D+PointLight2D，用 Radeon RX 6700 XT 之 OpenGL 相容渲染輸出實際 SubViewport PNG。不同光源位置：2223 個 Sprite 範圍像素改變；有無法線：2321 個像素不同。原 PNG 與 Normal Alpha 一致。
重要：`--headless` 環境 Dummy Renderer 無法產出預期 SubViewport 截圖，不可把此模式成功 Exit 0 誤當作 GPU render PASS；要用非 headless 的 Godot 原生 OpenGL 渲染再存 PNG，並用 T07 audit 查差異。
詳細：reports/T07_GODOT_NORMAL_VISUAL.json；圖：godot/NormalLightVisual/captures/。

## T08 已封版保護 / Ground+PAR
透過既有 `FS_ForestSplit_v3_2/run_dual.py` 重跑整條管線：50 Gate A-E、9 項錯誤回歸、Tiled strict、Godot、原生 VX Game.exe RGB 實景差異 0，結果通過。
限制：使用 544x416 小型森林 canonical 源素材測試，沒有證明 AI 可以根據任意示意圖 100% 還原「豐富的地圖」；必須先將參考圖 → approved Asset Kit → 可稽核 Blueprint/Manifest（人類審 Geometry）→ Ground/PAR 自動編譯，再做 Gate F。
**所有失敗案例應改成自動 QA，而不是再產生一張碰碰運氣。**

## Handoff
後續請先讀 Drive 的：Master Project State / CURRENT_DEVELOPMENT / CURRENT_HANDOFF，再讀 v3.2 地圖權威、本測試矩陣、遊戲美術工具主手冊、本 ZIP 的完整 reports 與進度 Handoff。
不要把結構 CI stub 誤當 Visual Candidate；正式 FS 專案 Runtime Seal 維持。
