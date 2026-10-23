# Forest Symphony | T15 Pixelorama Shader Effects 真 GPU 匯出驗證 (2026-10-24)

**狀態：T15_EFFECTS_RENDER_EXPORT_PASS + T15B_B0_SIX_UNIQUE_FRAMES_EFFECT_GPU_PASS**。地圖仍於 N5/B0 隔離 runtime 6/6 技術 PASS 檢查點暫停，505 個 SEALED FS Scripts 不變，Human Gate F PENDING。

## 根因界定與可行解法

已知 T11 失敗：Pixelorama v1.2.3 在 Windows 使用 `--headless --quit -- --spritesheet --export <file.pxo>`，具任何一個 Offset & Scale/Outline Effect 即 exit=0xC0000005，當時日誌顯示 **Dummy Renderer**；關閉兩效果可 exit 0。失敗後留下 PNG 不能作為 PASS。

T15 新實測：保持 Windows 有已登入且具圖形桌面的狀態，**移除 `--headless`，仍使用 `--quit` 自動完成工作並關閉**。命令：
```bat
Pixelorama.exe --quit -- --spritesheet --export "PATH\TO\ANIM_EFFECT_TEST.pxo"
```
四組皆 exit=0、產出新 384x64 RGBA PNG：NONE、BOTH、OFFSET ONLY、OUTLINE ONLY。四組 SHA256 相異；開啟 Shader 的 PNG 對照清潔組有真實變化；各啟用 Shader 的動畫幀也有可量測變化。原生啟動日誌：OpenGL 3.3 Compatibility, **AMD Radeon RX 6700 XT**, Windows 2 monitors，非 Dummy。第一組 4.53 秒、後三組約 3 秒，具重跑測試佐證（非通用保證）。

## T15B 不同影格 B0 實景回歸

將官方範例兩個 Shader Effects 注入原生 `b0_tree_six_unique.pxo` 的單層，但**不動原始 SOURCE PXO**，產生無效果與雙效果候選。
- 清潔版 GPU 輸出：384x96，六個不同的 64x96 RGBA 格子，與原 `tree_animation_6frames.png` 全部像素精確一致；相鄰影格分別差 2543 個 RGBA 像素。
- 雙 Shader GPU 輸出：exit 0，輸出 384x96；六格與各自無效果對照 RGBA 改動：[219,1470,2328,3030,3724,3567]。
- GPU log 判斷 RX 6700 XT、非 Dummy；因此為可見效果匯出技術 PASS。

## 安全邊界及未解項
- 這是「**需具可用圖形 GPU Session 的自動化匯出**」，仍不是 headless 的修復；Windows 已登出/沒有顯示器的情境**未驗證**。
- Pixelorama 退出時仍印出 GLES3 RID / Texture / Shader resource leak 與 ObjectDB 警告，屬未解的 cleanup 警訊，即使 exit 0。
- PNG 圖像變化不等同人眼接受的美術品質。正式 Forest Symphony Gate F、VX 法線光照與 Ground/PAR 多高度洞窟仍然 PENDING。
- 本測試使用官方 Pixelorama 範例與 B0 自製測試來源；官方範例美術素材不因編輯器 MIT 授權就自動具有商用授權。來源未核準不得直接放進 Approved Assets 或正式遊戲。

## 可重現資料
- Windows 測試工作區：`E:\GameAssetToolLab_20261023\ToolValidation_T15_20261024`
- 一鍵：`RUN_T15_GPU_TEST.cmd`
- 報告：`T15_PIXELORAMA_GPU_DIAGNOSTIC.json`、`T15B_PIXELORAMA_B0_SHADER.json`
- 對照：`outputs/T15B_B0_CLEAN_VS_EFFECTS.png` 左側正常、右側 Shader
- LOG: `logs/*.log`；原生 PXO 差異候選：`inputs/*.pxo`；輸入樣本：`fixtures/*.pxo`。
- 完整本地 ZIP：`E:\GameAssetToolLab_20261023\deliveries\FS_PIXELORAMA_GPU_SHADER_T15_T15B_20261024.zip`，30 files，65,485 bytes，SHA256 `559902ded7d78ec78a5e96319a099f056107dad24aecf3b3fbde8daf05b7b8f3`。
- GitHub 程式：`tools/fs_oss_toolchain_v3/t15_pixelorama_gpu/`；正式 V3.1 基準保留：https://drive.google.com/file/d/17c7fkGMyLZenBJrfAJz4pCajlbg4G2aJ/view

官方文件：https://pixelorama.org/user_manual/cli/ 。`.pxo` 內容可以在 Pixelorama 文件的 Project 格式規格中查核：https://pixelorama.org/concepts/project/

**下一輪：T17 合法權利 LPC/PMD/SBS 六向/動作/武器疊圖對位，來源優先核對既存 Asset Registry，而非重新廣泛搜尋。**
