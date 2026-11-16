# Forest Symphony A50｜雲端交付驗證紀錄｜2026-11-16

## 實際交付與版本
- 全部 Godot 4.7.2 工程、獨立可執行測試場景、真實 PixelLab 原始影格和 Job Lock：**[私人 ZIP](https://drive.google.com/file/d/13Ut5Z3TbOwShjz3_TstwECtCnJou5S6I/view)**
- [私人 A50 工程資料夾](https://drive.google.com/drive/folders/1l6KX4HgykoUybWX3HECArhC3NNETBg30)，Drive 已讀回 `shared=false`，權限 `user:owner`。
- [R3 與 R4 真 Godot 12 幀同步播放 GIF](https://drive.google.com/file/d/128jjfT6JEzgDGnTasvmRORN7NKZvzg6d/view)
- [R4 真 Godot 揮劍 GIF](https://drive.google.com/file/d/1-enhfx5TG2aBZvqNn3GHRYFmdsexUBZD/view)
- [真 GPU 12 幀放大比較](https://drive.google.com/file/d/13uGdXzwpFZfDk_4UxnZarW7bly9oZJ26/view)
- [真 Godot 練習靶攻擊截圖](https://drive.google.com/file/d/1ueViJazEW0NjSgc8KDxrlgBeCx2lzH_W/view)
- [Drive 正式 Handoff](https://drive.google.com/file/d/1CfshMeUTdy0JCjciuHx_0Xb7e_G7Sm9F/view)

## 原始素材、完整性與執行成果
完整 ZIP 檔名 `FS_A50_R3_R4_REAL_PIXELLAB_GODOT_NATIVE_QA_PRIVATE_20261116.zip`，**3,616,718 bytes**，SHA256 `07457a6747c54f45313ce9592ee7a7e923c60f77a045f7c9825f6c925bc9debe`。ZIP **731 entries**，730 個 source SHA256 全數相符、ZIP CRC PASS；已在 owner-only Drive 載入確認同一大小，遠端檔案當次重新計算 SHA 一致。

本次使用真正 PixelLab Skeleton V3 生成 **10 張全新 R4 角色影格**，Job ID `1c671687-681a-4667-a4e7-956b15fc7eae`，**3.0 generations**，加上 A49 的 6.1，累計 9.1。人形 R4 透過 R1 的 6 個頭部關節保形與 R2 的肩腰動作生成，**不做 Pillow 肢體拼貼**；頭部對齊後差異像素 293→141，胸肩動作變化 366→401。新 Body 原始 RGBA 10 幀直接導入 Godot、F0/F11 核准原始姿勢，武器獨立且只在 F9/F10 平移 1／2 px。

A50 R3、R4 **兩套真正 Godot 4.7.2 原生**的 editor import、12／12 GPU RGBA、F7 t=0.63s 命中、舊 0.55s 不提前打中、70ms Hitstop、靶 HP100→75→50、取消／範圍外／防重扣／2× 速度全部 PASS。兩套 native test 所需的 C: 暫存工具／工程**均確認已清理**。未覆寫既有 FS/A49、GitHub main、地圖／移植分支、原始 E: RMVX。

技術程式、manifest、原生測試與 QA 附在 GitHub 的 `tools/asset_factory/godot_a50_r4/`，私人畫格不推公開 GitHub；要直接打開**完整 Godot 工程請以私人 ZIP 為準**。

**Final Gate：ENGINE PASS／PixelLab Source PASS／ART HOLD（使用者視覺驗收未完成）／完整 FS Godot ATB NOT RUN。**

詳細交接：[A50 Handoff](A50_REAL_PIXELLAB_R3_R4_NATIVE_HANDOFF_20261116.md)、[A50 Failure Log](A50_FAILURE_LOG_20261116.md)。
