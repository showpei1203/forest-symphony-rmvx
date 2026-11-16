# Forest Symphony｜唯一規則入口／導航（2026-11-08 A11）

> 本檔保留舊 URL，**不再累積 P0～P8 施工全文**。原文完整保留於 [歷史快照](history/FS_CURRENT_RULES_INDEX_LEGACY_SNAPSHOT_20261108.md)，快照與改版前 Git Blob SHA 完全一致，不能從快照恢復其「最高權威」身分。

## 新對話必讀順序
1. [跨專案 Global Hard Rule 001](https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit)＋[FS P0 雲端／封版保護](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。使用者 PC 不得作為新工程保存位置；新增原生暫存需明確授權。
2. **[FS Asset Factory 唯一現行主規範](FS_ASSET_FACTORY_ACTIVE_MASTER.md)**。同時涵蓋 Ground/PAR、Battle Sprite，統整 P1～P8 並納入 A11 Master/F0 保真轉換。
3. [CURRENT_HANDOFF](../docs/asset_factory/CURRENT_HANDOFF.md)：工程版本、SHA、真實證據、待辦與下一 Pilot。**Handoff 不是政策**。
4. 只在具體施工需要時查真正 FS 原生來源、XML、Agent Skill/Precheck、舊 SOP／QA／研究原文。

## 當前方法摘要（細節以主規範為準）
- 地圖 **M-A 優先驗證**：高品質完整 Master 凍結 → AI 識別遮擋語意，Ground/PAR 直接從原圖同世界 XY 擷取 → Authoring／Runtime 四圖、合法足點、原生 VX 203、1x Art 分開驗收。A10 獨立物件組合 M-B 為備選，不能因技術較易而犧牲美術。
- Sprite **S-A 優先驗證**：高品質 45° F0 凍結 → 共用骨架與姿勢工具（可包含 PixelLab）→ 根據 F0 保真重繪各動作 → 1x 自然度／FS 原生驗收。Actor _1/_2/_3 三關鍵影格與 PMD 各動作 AnimData.xml 真實幀數是不同契約。
- 每輪 SOURCE／PIXEL／SEMANTIC_MOTION／USER_ART／NATIVE_VX／CLOUD／COST 門檻獨立判定；不能用 synthetic CI 或零 RGB 差異冒充 Art/Engine PASS。
- 同一種錯誤重複兩次就修模板／來源策略，不無止境修同一橋欄；付費 PixelLab 需明確扣額上限。
- A11 新轉換策略尚未實測封版。A10 精靈村 ART PENDING、橋河 ART FAIL_STYLE、原生 Game.exe／203 NOT_RUN。

## Drive 鏡像與歷史規則
- [Drive 唯一現行規範](https://docs.google.com/document/d/1_-R1zP89nwy8nCGtDiGjAgnZaJLSIVXcwiPJBD2rxC8/edit)
- [Drive 精簡正式總索引](https://docs.google.com/document/d/1LyA82hvJ9OVOkVBx0xsLsFctl6VFP8K9APMqCASYGUs/edit)
- [Drive 舊 SOP／原報告／交接](https://drive.google.com/drive/folders/11WkU3X9YI0TPM3sARbsg1UXbgoFxeEJE)
- [GitHub 原 P0～P8 完整快照](history/FS_CURRENT_RULES_INDEX_LEGACY_SNAPSHOT_20261108.md)

## 禁止
不再對本索引無限追加 Axx 當次 Handoff；舊 P5 三幀、A08 模板優先、Ground-first/R17 獨立雙圖不得自行升格；不改 main／封版 source，不把合成測試當新美術或真 VX 通過。
