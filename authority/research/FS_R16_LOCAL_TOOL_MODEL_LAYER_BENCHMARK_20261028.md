# FS R16｜本機模型工具及遮罩精修實測 Authority｜2026-10-28

## 判定
**局部遮罩技術測試 PASS；整村 PAR 美術精度與原生 FS VX 完整測試仍 HOLD。**
正式 R12 美術 Master 與 K4/FS 封版完全未修改。R13 整格補像素及 R14 只有兩種地板圖塊拼貼不得再做正式量產方案。

## 工具部署與實際執行的區別
| 工具 | 完成事項 | 尚未做到 |
| --- | --- | --- |
| SAM2.1 + OpenCV GrabCut | 本機 CPU 實跑 3 組 1280x928 原圖 ROI；2 修正 accepted、1 rejected，實際輸出 RGBA 與視覺比較圖 | 全村各物件語義遮罩、人眼視覺 Gate F |
| LayerDiffuse_DiffusersCLI | shallow clone f527? 以正式 Git SHA 3061d9aed52a6c52a13fcf2b196c0fef4d727824；從官方 lib_layerdiffuse/vae.py 執行原 build_alpha_pyramid + pad_rgb CPU 函式，3 個RGBA候選完成透明區 RGB Padding，可見Alpha255 RGB 最大改動 0 | SDXL 透明生成/推論（官方建議 Nvidia VRAM8GB），本輪未執行模型 |
| Meta SAM3 | shallow clone commit f1647e8d0c1d280991f4d1b7d974c2704537fe66；實際 import sam3 出現 pkg_resources 缺失；WSL torch.cuda.is_available()=False | 模型Checkpoint未下載、未推論；官方 CUDA12.6+ 和 Hugging Face 模型存取權未具備 |
| Qwen-Image-Layered | shallow clone commit 54c4fe47e76d745775e03fc66ee38457280ed9ea；程式已可研究 | 20B BF16正式權重未下載；SAM2 venv 無 diffusers、AMD 6700XT 12GB 非官方 CUDA範例，故未推論 |
| PixelART | 查看2026-09論文及發布資訊 | 未驗證到正式可用權重，沒有實際推論 |

官方工具網址：
- https://github.com/facebookresearch/sam3
- https://github.com/QwenLM/Qwen-Image-Layered
- https://github.com/lllyasviel/LayerDiffuse_DiffusersCLI
- https://arxiv.org/abs/2609.22789

**私人 FS 圖片未傳到外部推論服務，沒有未經授權的付費推論。**

## 本輪真正本機遮罩A/B
本機 1280x928 完整 Master `R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png` SHA256 eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80。

SAM2 Mask 作 GrabCut 原生解析度 Trimap，4/3正向 seed、6/5負向 seed、GrabCut 5次迭代，禁止32px整格自動Opacity。每個提案需「正點零漏／負點零誤收、R12 Ground-only候選多邊形不能較舊版惡化、Mask範圍不能暴增」才accepted：
- TREE_LEFT_MAJOR：SAM2 Alpha20536 → GC20613，漏正點0／誤收負點0、已記Ground-only區0→0，**accept GC**。旁邊枝葉灌木仍須人眼。
- CAFE_RED_HOUSE：27613→30325，原Ground-only多邊形重疊1429→2077，**reject GC，fallback SAM2舊候選**。
- LAMP_FOUNTAIN_NW：1851→1565，舊SAM2原漏1正點，GC變0／負點0，Ground-only多邊形0→0，**accept GC**。尖端燈飾輪廓仍可能未全。
資料：`R16_GRABCUT_SAM2_GATE.json`、三張`*_SAM2_GC_COMPARE.png`、三張`*_R16_SELECTED_SOURCE_RGBA.png`。

上面 R12 Ground-only區域仍是專案自訂候選多邊形，不是使用者逐像素Gold Truth，因此accepted只是一個技術判斷，不能直接Art PASS。

## LayerDiffuse前處理實驗
對以上三組 SAM2 來源透明PNG執行官方 `build_alpha_pyramid` 和 `pad_rgb`（AST抽取來源函式只避開CUDA/diffusers相依載入），透明區原空白RGB被補色，Alpha255可見像素RGB差0。**這是訓練/生成前的RGB-padding輔助功能，並不能自己產生透明前景輪廓，更不代表跑了SDXL模型。**
驗證在`R16_LAYERDIFFUSE_PAD_GATE.json`。

## Godot實際1280×928全尺寸結果
建立 `R16_MODEL_TOOL_EVAL_20261028/godot_selected3/ArtFirstVillage.tscn`：Ground=原R12完整精緻Master、不使用重複tiles，PAR=樹GC／紅屋SAM2舊版／路燈GC三份同源RGB精細候選、Actor=FS32。
使用真正 Windows AMD RX6700XT + Godot4.7.2 OpenGL產出5張圖（沿用`R15_*.png`輸出名稱）。
- 原Master vs Godot Master RGB差 **0 px**。
- 原Master vs Godot Composite（無人物）RGB差 **0 px**。
- 合成 PAR Alpha不透明 49,791px，RGB每像素由Master同座標。
- 人物前後圖有渲染，並非新生成全村PAR、更未做原生VX Game.exe整合。
- 這些數字只證明坐標精準與不必重拼Master；如果Mask吃到地板，同源0px也可能PASS，故ART HOLD。

## 錯誤回歸（必記）
1. R16初跑Python NumPy int64不能json.dumps再現R11類失誤，已將seed計數轉Python int並重跑成功；共用腳本需統一NumPy→JSON序列化守衛。
2. R16首次Godot Windows PowerShell輸出log路徑使用單引號變數`'$p'`誤判，改雙引號並真GPU匯出成功。
3. Windows驗證環境缺NumPy，以PIL ImageChops替代並重跑`R16_FINAL_GATE.json` PASS。
4. 不可以把LayerDiffuse padding成功稱作LayerDiffuse模型成功、或把SAM3 git clone成功稱作SAM3推論。

## 後續
維持 Master-first。下一輪先做多區ROI+負例點與真正細輪廓邊界，建立全村語義物件漏件表、檢查所有細線/樹幹/欄杆/燈柱誤收地面，配合人眼修正。大模型只有在環境/權重/授權符合時才開始推論。正式 FS/K4 sealed unchanged，Art F HOLD。