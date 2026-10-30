# FS R17 Stage13 | 共同來源場景測試、正式 ART FAIL | 2026-10-30

狀態：TECH CANDIDATE；GROUND_ART=FAIL；PAR_ART=FAIL；PAIR_ART=FAIL；FINAL_SEAL=NO。

Stage12 使用者明確否決 Ground 本身的美術及 Ground/PAR 的配合。本階段取消『拿既有完整 PAR 硬配新 Ground』，改採先建立同一份世界來源藍圖、再各自編譯 Ground 和 PAR。

來源：新 Ground 使用原始 grass_tile 與 A2_VSCliff 地表材質、共同道路和接地位置，不使用舊 Ground 或完整 Master。PAR 使用獨立原始藍屋 153x130、黃屋 149x105、神聖樹 213x224 加 19 個獨立裝飾來源，而非 Stage7 完整 PAR。所有 22 個來源物件都記錄在 JOINT_SCENE_BLUEPRINT.json。

Stage13 V1 房門／道路對位不正確，在 V2 已調整：藍屋門檻 (350,284)、黃屋門檻 (443,124)、神聖樹根 (119,279)。使用原始素材的局部接地點校驗；將藍屋物件水平移 16px 而不改錨點的負向測試被成功檢出。

原始 V2 PNG：Ground RGB 544x416 SHA256 d732ef75a6086fb60856de470f96a5b02f05b88c80f3fe2557b250354c996a89；PAR RGBA 544x416 SHA256 ce4ff94433f24d234f65edbfb05efb0a5e03a5d070c569f499772a2bf3b86c82。
PAR alpha0=162544, alpha255=63760, partial=0, border leakage=0。正式 Ground+PAR 合成 PNG 0 像素差，但此數字不代表 ART PASS。
獨立來源冷重建：GROUND/PAR/CORE PAR/兩份 QA/Blueprint/Manifest 七份 SHA256 都一致。
完整可重現 ZIP 2,837,194 bytes, 48 files, CRC PASS，SHA256 71c068fe2ea245ced592df7845b3ae32f0609db0117168c236d5e24ac2fce9af。ZIP 在對話可下載；目前未驗證 Drive 二進位上傳。

人眼判退：Ground 仍缺高精細草皮與石板路美術；高精細原生房屋／樹木與低精度手繪的路燈、柵欄、花盆、攤位顯著不搭。Core-only 畫面太空，增至 22 物件卻降低風格一致性。世界比例、接地陰影和色盤沒有達到參考圖。樹底 32px 歷史規則與不允許孤立樹幹仍有語意衝突，明確 HOLD。

本輪影像工具另生成印有 PASS 的展示板，但沒有用於任何 Ground/PAR 原圖或技術驗證，列為無效負例。
未改動已封版 FS/K4 Map.rvdata、Scripts.rvdata、Collision 或使用者通行度。

下一階段先創作／取得藝術品質一致且可編輯的高細節 Ground 和獨立 PAR Source Kit，而不是再以程序草紋、低品質裝飾或技術統計冒充美術進度。

Drive Handoff: https://docs.google.com/document/d/1hqB4Y4U5FKhLftgPUl1gQV7w9FFeR59AHbjnZd6FALA/edit
Drive Stage13 folder: https://drive.google.com/drive/folders/15Nfq3AFIOw25o1DCN-f1r2b84vuOEgMw


## STAGE13 V2 CLOUD IMAGE READBACK (2026-10-30)

The new GROUND, PAR, composite QA and CORE-vs-RICH QA PNG files were uploaded and read back in Drive Stage13 folder. Image references: [GROUND](https://drive.google.com/file/d/1hb8GTrxYGAaO23DFOeObUQaKqoBOK2G1/view), [PAR](https://drive.google.com/file/d/1sKDM0zX2FVADpXJHDf520onLvvPVdqnf/view), [Composite](https://drive.google.com/file/d/1rrJxkJU3pAUSI3I9q7Q5Fo-K0cEY9CPZ/view), [Core vs Rich](https://drive.google.com/file/d/1BZcuzSbl4HzbwO2EHD0Xs5axkuR71rz8/view). This is a file-presence readback; original-byte cloud redownload SHA not separately rerun. Full ZIP remains only in chat and is NOT claimed Drive-synced. Ground Art FAIL / PAR Art FAIL / Integration FAIL / Final Seal NO.
