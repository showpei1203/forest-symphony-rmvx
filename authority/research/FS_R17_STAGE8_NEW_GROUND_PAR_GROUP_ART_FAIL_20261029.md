# FS R17 Stage8｜全新原生 Ground + 高細節獨立 PAR 美術來源測試（2026-10-29）

**狀態：SOURCE-FIRST TECH CANDIDATE / GROUND ART FAIL / PAR PER-OBJECT EDITABILITY HOLD / FINAL SEAL NO**

## 這輪實際做了什麼
- 在隔離 Python 環境從零建立全新 544×416 RGB `GROUND.png`，不讀取、裁切或修改任何 Stage4–7 的 Ground 圖片。使用新種子、四條曲線道路、雜訊地形色階、不規則石頭、微型草葉與花，並保留房前及樹腳的貼地陰影。
- `PAR.png` 是既有 Stage7 的**獨立透明 PAR 檔**（不是從完成 Master 拆下來），保持 544×416 RGBA。Stage7 原始 PAR 先前由 Stage5 高解析獨立 PAR 進行 Alpha 修復與等比例最近鄰縮放，**不是原生逐物件可編輯 1× kit**。
- 將正式 RGB Ground 與 RGBA PAR 真正合成出 `COMPOSITE_QA_ONLY.png`，並跑重建與雜湊比對。
- 對 PAR 真透明背景做 8-neighbor Connected Components 分組，**真正輸出四組可重新組合的 RGBA 來源島（左大樹+護欄、右雙屋+花飾、兩組路燈）**；四組重組逐 RGBA byte 與原 PAR 完全一致。這只提升**群組級**分離，不代表每棟房、每片欄杆已是獨立原生來源。

## 技術驗證（已實際運行）
| 項目 | 實測 |
|---|---|
| Ground | 544×416 RGB；SHA256 `7d3b6c3b96034043f33a70ca7c8970f9f9ecde1645af1045a41fcfaf3c4c8b1e` |
| PAR | 544×416 RGBA；SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9` |
| PAR Alpha | 112,766 全透明 / 108,885 完全不透明 / 4,653 半透明；四邊 Alpha 洩漏0 |
| Ground + PAR Composite | 經修正後，從正式 PNG 重新組合與 QA **逐 RGB byte 一致** |
| 隔離冷重建 | 原始 PAR + Ground 新腳本重新建立 Ground/QA，SHA 一致 |
| 負向測試 | 故意裁短 PAR 1px、邊界製造 1px Alpha 漏像素、偽造來源 SHA，均正確拒絕（3/3） |
| Windows 原機 Gate | `DESKTOP-90VT437` 對實際同步 Ground/PAR 檔案的 Strict Gate **Exit 0**，`TECH_CANDIDATE_ONLY_ART_HOLD` |
| Stage8 PAR Source Groups | 4 個連通島，重組原 PAR 零像素差 |
| Formal Seal | **NO** |

### 本輪確實發現並修復一個錯誤
初次 QA 合成用繪製過程的 RGBA 暫存 Ground，與正式匯出的 RGB Ground 的像素不同，**檢驗器首次 FAIL**；修成只使用正式 Ground.png + PAR.png 合成，再跑逐像素、冷重建及負向驗證。保留於 Failure Ledger，不得當作一開始就 PASS。

## 美術 FAIL／保留事項
- **GROUND ART FAIL**：雖然重新繪製地面、低花草不再過大、且沒有孤立樹幹，但草地及道路材質仍未達 user 指定的 ground3／精靈村高精細參考，單靠多畫草點和石塊不能解決。
- **PAR ART density = 進步，但需視覺驗收**：兩棟房屋、大樹、花飾、燈具、欄杆等較接近參考密度。透明邊緣有4,653個半透明像素，且部分貼地花草跟物件黏合。
- **PAR SOURCE EDITABILITY HOLD**：群組級4件可分離，右側仍為雙屋+大量環境裝飾連成一組；不可聲稱完成逐物件可編輯。
- **TREE CONTACT HOLD**：單獨 Ground 沒有可見樹幹；目前大樹留 PAR、Ground 保留陰影，與歷史 lowest32×32 trunk-on-Ground 規則有衝突，不能冒稱符合全部 Authority。
- **PAIR VISUAL HOLD**：尺寸/Alpha PASS ≠ 房門道路與腳點 ART PASS；美術尚未過 user 審核。
- 本輪 ImageGen 再次只生成一張帶有字樣的多格 QA 展示板，**沒有獨立雙圖**。明確視為無效來源/無效 PASS，不作任何素材輸入。
- FS/K4 sealed、Map.rvdata、Scripts.rvdata、Collision、通行度未更動。

## 交付狀態
- [Stage8 Google Drive 資料夾，原始雙圖與 Windows Gate JSON](https://drive.google.com/drive/folders/1rCE0mZi3wm_eFgs77VT3a-m2ZD8yV9JX)
- [GROUND.png](https://drive.google.com/file/d/1OUAwehr3eIJyPDs9ulH5-KMwaQ_DVKBe/view)
- [PAR.png](https://drive.google.com/file/d/13V2WS1J7-6THVA0uXE80dZVWSN4zgl5y/view)
- 完整可重現原始產生程式、四組 PAR 源、QA 與 ZIP 目前以本 ChatGPT 對話本地 sandbox 附件交付。**尚未宣稱 ZIP/腳本已同步 Drive/GitHub**，避免無依據的同步 PASS。

## 下一步
不再重做已通過的 Alpha 與尺寸測試；**製作與 Stage7 高豐富度 PAR 同藝術水準的原生可編輯材質來源**。優先利用可授權原始 Tileset/花草/石路素材重新建 Ground（不是直接修舊 Ground），同步推進 PAR 雙屋+花飾群組更細的語義拆分與接地驗收。每階段維持 `FINAL_SEAL=NO` 直到使用者視覺確認。
