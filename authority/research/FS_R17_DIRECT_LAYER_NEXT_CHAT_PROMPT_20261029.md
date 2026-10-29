# 新對話接續指令｜Forest Symphony R17 Direct Ground + PAR（2026-10-29）

請接續 FS 精靈村地圖 Ground/PAR 的研究製作，不要從零開始、不要回滾已封版內容，也不要繼續做 Master-first 事後切割 PAR。

**最高優先權：使用者最新明確要求**
1. AI 直接分別生成兩張品質合格、同畫布同世界座標的來源圖：
   - GROUND.png：獨立美術製作的連續地面，包含自然草地、彎路、石板路、地面花草、貼地陰影，以及樹最底部接地一格；不能預先烘焙房屋、樹冠、欄杆、路燈等完整立體物件。
   - PAR.png：從創作開始就是獨立的真正 RGBA 透明前景，包含完整房屋、樹冠／樹枝／非接地樹幹、路燈、欄杆／扶手、立體裝飾。無地板／泥土／草地污染，細線完整。
2. 使用者會自行合成 GROUND+PAR 成新 Ground，再於 RPG Maker VX 中套用 PAR，並使用 FS 現有通行度腳本自行設定通行度。**請不要自行編譯 Collision、修改 Map.rvdata / Scripts.rvdata，或把通行度列為交付 Gate。**
3. **不用再事後裁切 PAR**，包含從完整美術 Master 逆向使用 SAM2/GrabCut 整體拆圖。若直接生成的圖層美術不佳，就改良/重生獨立原生素材及地表，而不是恢復舊流程。
4. Ground 地面必須達到參考 ground3／精靈村圖片的豐富度與精緻度；禁止只拿2種32px Tileset 重複鋪地。
5. 初期測試 544×416，成功後擴 1280×928。最終只需交 Ground.png、PAR.png；可額外提供合成 QA Preview，但不得把 Preview 當 Ground。
6. 必須以 GROUND_LAYER／PAR_LAYER／PAIR_ALIGNMENT 三個獨立硬 Gate 驗證視覺與真Alpha。人眼 Gate F 尚未通過不得稱 Formal PASS。

**先依序讀以下權威：**
A. Google Drive FS_R17_ELF_CORNER_20261029 裡的 `R17_DIRECT_GROUND_PAR_AUTHORITY.md`
B. 同資料夾 `CURRENT_HANDOFF_R17.md`（新版直接雙圖層權威）
C. 同資料夾 `R17_DIRECT_LAYER_CORRECTION_REPORT.md`
D. 同資料夾 `R17_DIRECT_PAIR_PROVENANCE_GATE.json`
E. GitHub `authority/research/FS_R17_DIRECT_GROUND_PAR_AUTHORITY_20261029.md`
F. GitHub `authority/research/FS_PAR_OCCLUSION_CURRENT_HANDOFF_R17_20261029.md`
G. Linear SHO-34 最新評論；先前R17 Stage2／R16文件僅供失敗對照，不得凌駕最新規則。

**已實做的兩組反例（不用重測作正式美術交付）**
- R14 真正有獨立 Ground+PAR：544×416、真RGBA、重組0px差，來源結構 TECH PASS，但使用221個地面圖塊只有2種素材，Art FAIL。
- R17 Stage2 生成的精美 Master + 後切11件 PAR：重組也0px差，但 Ground 早已內含全部立體物件，獨立生成來源 FAIL，且仍有兩段欄杆 seed FAIL、攤位/道路81px衝突。**重組0px不能證明分層成功。**
- `R17_USER_CORRECTION_TRUE_LAYER_VS_PREBAKED_6PANEL.png` 與 Gate JSON 已可直接觀察比較。
- 原正式 K4 Scripts505 SHA 5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa、Map003 SHA 118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4，**絕不可覆寫**。

**下一步：直接開始生成兩個獨立的新圖層候選，檢查精緻度、真正透明Alpha、完整樹／屋／欄杆與Ground接合；有失敗便記錄並重新生成來源。** 每階段同步 Drive+GitHub+Linear、更新 Handoff；直到真正兩圖美術和分層同時合格才可能 Seal。

目前交接狀態：正式規則已修正；獨立雙圖技術範例僅R14舊樣機且美術不合格；尚未有符合使用者要求的新美術雙圖成品。**NO ART PASS / NO FINAL SEAL**。