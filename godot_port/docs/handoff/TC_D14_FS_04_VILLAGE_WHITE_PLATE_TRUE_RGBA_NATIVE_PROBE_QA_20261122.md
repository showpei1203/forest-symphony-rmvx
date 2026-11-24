# Forest Symphony｜T-C D14｜灰鑄工坊城第二張獨立 PAR + Godot 4.7.2 工程核驗

日期：2026-11-22（Asia/Taipei）
分支：`feat/fs-tc-d12-chroma-par-20261122`
場景：`FS_04_VILLAGE` 灰鑄工坊城（赤焰火山）
正式美術：**ART HOLD；12 圖 ART PASS 仍 0/12**

## 真正完成的三個施工單位

### A. 校正 D13 來源 SHA 錯誤
實際重新對原私有 D13 ZIP 內檔案計算 SHA256，發現 GitHub D13 Handoff 與十二圖台帳的兩筆技術候選 SHA 曾寫錯，現已校正，不修改實際 PNG 或原 D11 Ground。

| 實際檔案 | 修正後真 SHA256 |
|---|---|
| D11 Ground 1280×928 鎖源 | `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d` |
| D13 獨立原始透明 PAR 1474×1067 | `b6d529b66d9ec71c87991e7e63abeb85f9d145e056e7bf675cd8ac0de3678f72` |
| D13 1x 裁切 PAR 1280×928 | `5ba2083578b9acdc3c4e2c58208420c4900de4258420a9f47c177ef3e7db6d4f` |
| D13 整張 LANCZOS 縮放技術候選 1280×928 | `0bc33afa55684df60c0301391e945f182a30776cb2b7fae4db7f1f99081a4aff` |

D13 原始 alpha>224 高不透明像素 664263 個，1x 中央裁切只剩 581787 個，**損失 82476／12.416%**。原來源 Alpha>224 內容最小包圍盒約 1464×1055，明顯超過 1280×928，因此不能以一般裁切不失真。

### B. 第二張獨立整城非地表美術（D14 白底來源轉真 Alpha）
另一輪生成已實際產出一張**1474×1067 RGB 白底、僅有非地表全城物件**的獨立美術來源。這不是 Ground＋物件的合成 Master，故可以依早期 FS SOP 的白底 fallback 進行明確背景轉透明，**沒有從含 Ground 的 Master 逆向切取**。

涵蓋完整工坊群、熔爐、煙囪、錘鐵設備、吊車、礦車、橋梁、房舍、貨箱、旗幟、路燈、岩柱與右側工業區。新來源白底不合直接 PAR 交付，已另行保存 RGB 原圖，並用 deterministic connected-near-white matte 處理白底，建立獨立 RGBA 原尺寸 PAR。背景清除只針對與畫布四邊連通的接近白色像素，保護內部白色裝飾；RGB 原圖沒有改動。

| D14 實際證據 | 觀測結果 |
|---|---|
| RGB 原始白底 plate 1474×1067 | SHA `26aed5dc5bb03004961ac54f13cfb41f9d825396808d6eb12517e04b50171adb` |
| 新真透明 PAR 1474×1067 | SHA `85b8f750e584d74492bea4c409a76e0b26bbe41edfca303241b26db40a9a0760` |
| 真 PAR Alpha=0 | **734965 像素** |
| 真 PAR Alpha=255 | **830440 像素** |
| Alpha 9–239（邊界） | 7353 像素 |
| 原圖 1x 中央裁切會損失 alpha>224 物件像素 | **106197／12.785%** |
| 完整縮放 1280×928 PAR 的 SHA | `f69b80119e8aa15c1d119a6b0faca98b7ce6880efaf3e9ac1ff324935606dccb` |
| 完整縮放 1280×928 Ground+PAR QA 合成 SHA | `b84dfd9ed0bce13206e783f976f743345edb655fc0350edfac530e09eed5687b` |
| 1x 原生尺寸 PAR source | **未達成**（1474×1067） |
| 已鎖 Ground 1280×928 | **原封不動** |

D14 靜態視覺對照完整生成成功，中央原 Ground 圓形廣場保持通行空間，整體建築更清晰；但橋與道路世界座標仍只做初步視覺比對，沒有人工美術簽核。保留 D13 真透明原始圖和 D14 新白底→透明原始圖，**不互相覆蓋**。

### C. 不重新造系統，沿用既有 Godot 4.7.2 雙圖擷取架構
新增 `godot_port/tc_factory/native_complete_par_probe.gd`，接受使用者在私人本地工作區／授權執行環境中 supplied **兩張實際獨立來源 PNG** 路徑，要求相同 1280×928、鎖 Ground SHA、兩個 Sprite2D 位於原點、NEAREST、真 GPU framebuffer，輸出 Native screenshot 和 QA JSON。沒有 PAR 遮人抽選、碰撞、傳送或讀存檔。

**已真正在 GitHub Actions 驗證 Godot 4.7.2 原生程式：**
- [CI #44997754667](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44997754667) **SUCCESS**：安裝官方 Godot 4.7.2，cold import `godot_port`，雙圖 1280×928 **合成測試素材**進行原生渲染及圖片 readback，錯誤 PAR 尺寸預期拒收。
- **重要限制：上述 CI 只用了 synthetic PNG，不是 Drive 上 D13/D14 私有美術**，所以不代表 D13/D14 已做原生 Godot 截圖驗收。
- [白底 fallback synthetic CI #44998273527](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44998273527) SUCCESS：對獨立白底素材做真透明轉換、保護封閉白色物件、拒收不透明 Master、空白白底、錯角落、Ground SHA 篡改，且永遠 ART HOLD。

## 私人 Drive 完整來源與 Readback

- [**D14 7 檔私有 ZIP**](https://drive.google.com/file/d/1oZU9YY02lZTK5Vd3vlP60e_j6252tf_v/view)：**11706995 bytes**／ZIP CRC PASS／SHA `88c53f99b77ba2f272b21513260ab3274bed84e2e943ac97c3bf825b6d21ba78`。
- [D14 新原始 RGB 白底全物件來源](https://drive.google.com/file/d/16dnEC5xXPlPZOJ7dY5J4LCQ8blXI80Pu/view)。
- [D14 真透明全物件 PAR 1474×1067](https://drive.google.com/file/d/1z4jFTtpQ5MGOmMeAI7k-qtWmku_XtMF9/view)。
- [D14 1280×928 靜態合成（技術候選）](https://drive.google.com/file/d/12MCDzxl3NcOPrV8mAK6aLdgTG-bWrqrO/view)。
- [D13 vs D14 四圖視覺對照](https://drive.google.com/file/d/14cM9AwYzHiC7G5GImBQA3mx4yBmUMah6/view)。
- [D14 完整 RGB/Alpha/尺寸/裁切 QA JSON](https://drive.google.com/file/d/1Xslbm-BKtpwMn0Id9I8BVLAahQYxu3FT/view)。

上述所有新 Drive 檔案 metadata readback 已確認 `shared=false`，只有 `owner`，**沒有把任何私人圖片放入公開 GitHub**。GitHub 放程式、synthetic test、workflow、SOP、Handoff、12 圖 metadata。

## 正式驗收表

| Gate | D14 |
|---|---|
| D11 原 Ground 不變／SHA | PASS |
| D13 source QA 交接錯 SHA 修正 | PASS |
| 第二張整城獨立非地表來源 | PASS：RGB 白底 |
| 白底來源 → 真透明完整 PAR | PASS：技術候選 |
| 真透明素材原圖無背景 | PASS：alpha0 734965 |
| 原生 1280×928 源圖且不裁物件 | **FAIL：1474×1067** |
| 1280×928 靜態 Ground+PAR 畫面 | PASS：**縮放 preview only** |
| D14 真來源 Godot 4.7.2 native | **NOT_RUN** |
| Godot engine renderer 程式 synthetic CI | PASS |
| 正式 ART | **HOLD，0/12** |

**下一個完整施工單位：**不要改 D11 Ground，也不做個別樹冠、遮擋判斷、劇情事件。以 D14 清晰的工坊全景與原 Ground 位置為參考，真正生成原生 1280×928 的一次性透明 CompletePAR（整體物件不切邊、不擅改世界座標）。新來源須先有真正 1x 原始像素，接著可透過 D14 `native_complete_par_probe.gd` 跑私有美術 Godot 原生截圖，最後人工 ART Gate。若再返回 1474×1067 RGB 全圖，只保留獨立來源、不冒充尺寸 PASS。
