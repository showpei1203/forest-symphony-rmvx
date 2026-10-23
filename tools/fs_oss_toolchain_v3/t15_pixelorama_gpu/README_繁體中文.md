# Forest Symphony｜Pixelorama Shader GPU 實測 T15 + T15B
日期：2026-10-24｜類型：開源工具獨立隔離測試，不修改 Forest Symphony 地圖或 505 個封版腳本。

## 正式結果
T15：4/4 非 headless、具圖形桌面的 OpenGL/Radeon RX6700XT 六幀 PNG 匯出 exit=0；
none/both/offset/outline 四個結果 SHA 各自不同；兩效果同時套用後六格至少有明顯像素變化。
T15B：真實 6 格各不同 B0 樹木，每格 64×96、整表 384×96。無效果輸出與原始 B0 六幀完全一致；啟用兩 Shader 效果後六格各變動 219、1470、2328、3030、3724、3567 個 RGBA 像素，6/6 通過。
先前已知 headless（Dummy Renderer）有 0xC0000005 崩潰：仍標 FAIL，不能改成已修復 CLI headless。
新版無 --headless，但 --quit 會在完成匯出後自動結束，可當桌面型自動批次管線。若遠端桌面已登出或 GPU 上下文不能建立，可能不適用。
WARNING：Godot GLES3 資源在 Pixelorama 結束時仍記錄 RID/Texture leaked；非零 exit、無輸出或效果像素不變都不得當 PASS。

## 執行
將資料夾解壓至 E:\GameAssetToolLab_20261023\ToolValidation_T15_20261024；
依賴現有 E:\GameAssetToolLab_20261023\tools\Pixelorama\Pixelorama-Windows-64bit\Pixelorama.exe，
以及既存 ToolValidation_v3_20261024/inputs 原生 PXO/B0 Test Sprites。
雙擊 RUN_T15_GPU_TEST.cmd。正式測試使用 Python 3/Pillow，真實 GPU 圖形登入狀態。
可單獨執行 python run_t15_pixelorama_gpu.py 和 python run_t15b_b0_shader.py。
測試輸出不包含 .exe，不會修改 B0、N5 或其他封版資產。

## 文件與證據
T15_PIXELORAMA_GPU_DIAGNOSTIC.json、T15B_PIXELORAMA_B0_SHADER.json、inputs/（測試候選 PXO）、outputs/（PNG 圖）、logs/（原始 stdout/stderr）。
視覺對照 outputs/T15B_B0_CLEAN_VS_EFFECTS.png（左無效果、右啟用雙 Shader），審美仍由人眼評估。

## 來源限制
Pixelorama 官方示範原版來源：https://github.com/Orama-Interactive/Pixelorama （專案程式 MIT；示範藝術素材仍需獨立確認授權）。本包做私有技術驗證，不允許把官方展示 PXO 直接當作正式商用品。
B0 樹木是我們先前自製的技術測試素材，不代表正式 SCENE04 美術品質，也不等於 Map Human Gate F PASS。

## 獨立版本邊界
地圖正式 N5 Runtime Adapter 6/6 技術 PASS，505 Scripts SEALED；Human Gate F PENDING。下一項 T17 合法 PMD/LPC/SBS 素材整合另行驗收。
