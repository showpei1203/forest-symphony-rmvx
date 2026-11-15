# Forest Symphony｜A49 真正 PixelLab 18 關節揮劍動作｜正式工程交接

**日期：2026-11-16**  
**狀態：MODEL REAL PASS／Godot ENGINE PASS／ART HOLD／正式 FS 戰鬥 ATB NOT RUN**

## 為什麼停止 A42–A48 的方法

使用者已多次指出，過去 Pillow 水平像素切片、局部變形、自動 QA 雖通過，人體仍有多處脫節；購買的 PixelLab 也未用於 A47/A48。A49 不再使用 Pillow 生成 Body 姿勢，改用真正的 **PixelLab Estimate Skeleton + Animate with Skeleton V3**；Pillow 僅裁切、對齊武器、製作預覽、品質檢查與封裝。已查閱 `FS A57` 真實 18 關節估算、`A65` PixelLab 模型實測、既有 `create-game-assets`、`raster-pipeline`、`godot-gdscript-headless-testing` Skill；引擎依最新要求只使用 Godot 4.7.2，不再新開發 VX。

## 真正 API 執行與額度

| 階段 | 真實來源 / Job ID | 結果 | 用量 |
|---|---|---|---|
| 角色骨架估算 | A62 核准 F0、真實 PixelLab `estimate-skeleton` | 18 個含深度序的原生關節 | 0.1 generation |
| R1 動作 | `a16c26c5-662b-42ae-9f32-2d28baef17c7` | 10 張模型新生 64×64 RGBA Body | 3.0 generations |
| R2 增強胸肩扭轉 | `6786d5c5-d95d-48c9-b9ca-6a84627ea039` | 另外 10 張模型新生 64×64 RGBA Body | 3.0 generations |

**合計 6.1 generations**，只有 2 次明確限定的動畫 POST，另 1 次估算；Job Lock 在提交前寫入，查詢背景工作而不重複扣點。API 金鑰只使用遠端環境設定，**未保存到任何檔案**。第一幀權威 A62 角色來源 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`。每版 10 張真實 PixelLab 新影格，加上原始 F0／F11，得到完整 12 幀 256×192 Body 圖集。

## R1 vs R2 藝術結果

- R1 角色白髮、衣服身份較穩，手臂有新動作，但胸腰重心仍偏死板。
- R2 對相同 18 點骨架加強肩膀、胸腔、脖子、髖關節的反向動態，手腕和雙腳定位維持鎖定。相較原始 A62 的累計影格變化：胸肩 **153→366** 像素、骨盆/腿 **106→337** 像素。這表示動得更多，不表示藝術一定更好。
- R2 模型在 F6–F10 **擅自將銀劍畫進 Body**，不能直接與遊戲自己的武器圖層疊加。已依原 RGBA 拆出模型劍身五幀，分別 57、71、47、48、43 個可見像素（含 F6 原先分離的 15 像素），且原始 R2 RGB/A 逐像素完全重組，diff=0。
- **真正 Godot R2** 使用去除模型劍身的 R2 Body 與原本獨立的武器／FX 圖層；原生模型劍圖另存私人 Drive，未用來重疊畫雙劍。
- R2 另一風險：頭髮/臉部累計變動 **1208 vs R1 53** 像素，可能有身份或視角漂移。**ART HOLD**，不能自稱最終美術合格。

## 已實作的 Godot 工程與 QA

兩個**相互獨立、實際可運行**工程：`godot_a49`（R1）及 `godot_a49_r2`（R2）。真實 Windows Godot **4.7.2**、AMD RX6700XT GPU 原生測試均通過：全新 editor import exit0、12/12 RGBA GPU 截圖與各自目標合成圖差異0、11 個不同人物姿勢；F6 **0.55 秒命中**、本階段 local marker **(28,10)**、Hitstop **70ms**、回復 A39 呼吸待機；獨立 Godot 練習靶 HP **100→75→50**、範圍外 miss、序號防重扣、取消及 2 倍速測試均 PASS。

不要混淆：這只是獨立練習靶 **Godot DEMO**，**完整 FS Godot 移植 ATB／技能／敵方怪物戰鬥尚未實測**。

## A49 來源、原始資產與正式證據（私人僅擁有者）

- [完整 A49 雲端來源資料夾](https://drive.google.com/drive/folders/1PdjhiTcCDkrO4ppX0T292kFvVZ6leRZg)
- [R1／R2 真 Godot GPU 同步動畫 GIF](https://drive.google.com/file/d/1H4_ubyuO6LA-7cAyVmWW16_LmcT4sHl_/view)
- [R2 真 Godot 12 幀攻擊 GIF](https://drive.google.com/file/d/1gDiTGT-fCLd4QY81gptg3WKiEnIGFkbV/view)
- [R1／R2 真 Godot 3 倍逐幀比較](https://drive.google.com/file/d/14XStTUNvIcOkVrY9-_q7TYwPSKwhmQeH/view)
- [私人 Drive 原始正式 Handoff](https://drive.google.com/file/d/1ZiS3kzBS4CNBxinh5e7wjlooCig81E5D/view)

檔案保留 `provider_raw/`、`provider_raw_r2/`、`provider_art/`、`qa/`、`qa_R2/`、`native_godot_a49/`、`native_godot_a49_r2/`、兩套完整 Godot 專案及實際 provider response 和防重覆 job locks。

完整 ZIP：`FS_A49_REAL_PIXELLAB_V3_18JOINT_R1_R2_NATIVE_GODOT_PRIVATE_20261116.zip`，**3,519,028 bytes**，SHA256 **`19850a78febf5f3384dba15f8ee4238daf8505a719f581cb5c3c774ff10b68dd`**，共 732 entries，731 個來源檔 SHA 全相符、CRC PASS，已另保存在 A49 私人雲端資料夾。私人 provider artwork **不推送公開 GitHub**。未覆蓋 GitHub main、地圖分支、A42–A48、原本 VX E: 檔案。

## 下階段真正要改善的事

優先人工（1×、3×、全動態）比較 R1/R2 的人物身份、頭肩角度與 F5–F7 揮劍力量傳遞。**不再靠 GPU PASS 冒稱美術合格**；若 R2 頭像漂移過大，以 R1 保身份的骨架與 R2 的軀幹姿勢限制進行**單次明確目的實驗**，先確認成本與 QA，絕不無限制重複呼叫 PixelLab。若正式選 R2，武器圖層另有原模型劍，可比較是否比 A48 舊劍符合手腕動作，但原生 BODY 應保留無劍獨立來源。
