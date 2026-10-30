# Forest Symphony｜Ground-only v2 Stage0 實測與失敗交接｜2026-10-30

CURRENT STATE: ENGINEERING_PROTOTYPE_READY / 8_MASKS_READY / 13_SOURCE_BANK_ENTRIES / G1-G4_EXPORTED / STRUCTURAL_13_OF_13_PASS / INDEPENDENT_22_OF_22_PASS / OFFLINE_COLD_REBUILD_4_OF_4_HASH_PASS / GROUND_ART_FAIL / PAR_NOT_STARTED / FORMAL_SEAL_NO.

## 1. 實際產出
- 8 張 544×416 8-bit 灰階 Mask：ROAD、ROAD_EDGE、SOIL、GRASS、FLORA、RESERVED_OBJECT、ROOT_CONTACT、FORBIDDEN_STANDING。
- 13 個 source-bank 項目：4 草地、3 石板、3 土壤、3 程式生成花草。真實素材來源中 10 件是既有生成/歷史裁切紋理；3 件花草只是測試 stub，不是通過美術驗收的 AI 花草。
- 4 張 544×416 RGB Ground：G1/G2/G3/G4；各自有 PIXEL_OWNER.png、裁切原點、素材來源清單及 SHA-256。
- 兩個執行程式：build_ground_v2.py、verify_independent_v2.py。獨立驗證器不信任生成器報告，從來源像素和 owner 對照重建，並故意插入 1px RGB／16px source-offset 異常。

## 2. 工程 QA 成果
- 13/13 生成流程的狹義技術檢查 PASS：所有輸出尺寸、Mask、道路連通、門口與西東南出入口、樹根地面保留、來源 Hash、原始資產隔離等。
- 22/22 獨立 QA PASS：13 banks、Mask、Ground 原始像素重建、各版本 PNG Hash，1px 損毀與 16px 錯源負測等。
- 完整 ZIP 被解壓到另一個隔離目錄，且刻意停用外部來源路徑；4 張 Ground 由內附素材重建後 SHA 完全相同。
- 原 K4／FS 封版的 Map.rvdata、Scripts.rvdata、Collision、Passability 沒有修改。

Ground PNG SHA-256:
G1 29e628fb39e17b99e59f47f0c46920f0d3ec61cce65d93a1125d9a13ce23e34d
G2 f680f851b196dde6f3d51e74ed061284c376303cb4dc9f01e715af949eb34598
G3 1a442d0955625de5c8c0a24f976463a04f3855c989449371c025429bc088cea4
G4 0fdab8481b43efd95870688bdd358abbdeffc9c9dcb25298d8c7e8fd7f381406

Private ZIP: FS_GROUND_ONLY_V2_STAGE0_ART_FAIL_20261030.zip; 37,694,790 bytes; SHA256 78e2efdc53266ad6833fb3e3a01847ba572e7c4c4953212fca780fc3140a959f; 49 files; ZIP CRC PASS. **ZIP 只在目前對話附檔，未驗證上傳 Google Drive，GitHub 也未同步二進位素材。**

## 3. Ground Art FAIL 的具體原因
1. 地面基底素材不是原始 FS ground3 / SCENE21 的真像素美術批准來源，仍存在光向、飽和度、草土細節密度的差異。
2. 主要石板來源是舊 R2 擷取的 220×70 段，重複使用使道路明顯重複，中央直線感重，草土邊界仍如貼片。
3. 花草是三種程式畫出的透明 stub，尚無足夠的風格與物件密度，不能冒充正式 Asset Bank。
4. FORBIDDEN_STANDING_MASK 是一張畫布全禁物件的語義旗標，並非自動化圖像分類器，沒有完成逐像素「禁止立體物件」語義驗證。
5. 尚未逐像素讀取並核對原始 FS ground3/SCENE21，也未做正式 VX／Godot 角色遮擋畫面。

## 4. 止損決策
GROUND ART FAIL，PAR NOT_STARTED，FORMAL SEAL NO。
下一輪禁止再次從頭寫 mask/road/Hash 引擎；只補 FS 原版真正風格一致的連續石板道路／草土過渡來源及高品質低花素材，保持已有 Blueprint、路徑、來源重建與 negative QA，重新出 G1-G4 作品，待使用者 Art PASS 再製作 House A、House B、Sacred Tree PAR。

## 5. 本輪實際原始程式與圖像位置
完整 ZIP 附在本 ChatGPT 對話；含 00_contract、01_masks、02_source_banks、03_scripts、04_candidates、05_review、06_release（空）、SHA256SUMS.json。
