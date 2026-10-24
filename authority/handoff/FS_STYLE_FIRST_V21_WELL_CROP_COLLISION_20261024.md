# Forest Symphony｜Style-first v2.1 水井完整裁切／碰撞修正｜2026-10-24

**驗證狀態：ISOLATED NATIVE VX CROP/COLLISION TECH PASS；User Human Gate F NOT RUN；正式 FS SEALED Runtime NOT TESTED；完整精靈村 Visual Benchmark NOT PASS。**

## 問題與失敗證據
使用者從真正的 Windows VX v2 ZIP 提供畫面，指出水井左邊被裁切、通行設置不對。原 v2 報告的「合成 Master 與 VX 0px mismatch」只表示引擎準確重現已裁壞的圖片，不能證明 Source 完整或碰撞合理。已在 v2 GitHub Handoff 更正為 **WELL CROP/COLLISION USER FAIL / SUPERSEDED**，保留原 v2 私人包及 source。

## 原因：錯誤 AI Source Crop + 背景鄰物污染
原 Forest PAR Sheet 水井的**完整物件**位於 Source bbox (1033,819)–(1182,994)，Threshold64 主元件含 18,193 像素。v2 誤以 (1085,822)–(1252,981) 裁切，左側切到屋頂、支柱和石圈，右側包進鄰近苔石；取錯誤 tight bbox 再只保留最大的連通元件，因此 78×72 舊水井有一邊空白，且僅 2,605 個可見像素。

v2.1 使用已核對的 Source ROI (1030,816)–(1185,997)、保留 18,193px 完整井體元件並排除旁石，以 3px padding、Nearest 0.47 缩放產生完整 73×85 新水井，**4,016 個可見像素**。新舊 Source SHA、ROI、透明度、來源照片均保存在私有 ZIP 的 Ledger/Manifest；其他八個物件與 544×416 草地土路 Ground 完全不變。

## 複合物件安全規則
任何水井、柵欄、告示牌、樹屋、帶配件道具禁止直接以盲目的 largest connected component/單一 tight bbox 作正式交付。優先物件級 ROI 與完整組件判定、明確排除相鄰背景物、保留完整合法島／附件、來源透明度及 3px safety margin；若來源不完整，Gate 必須 fail-closed。
石井的 source semantic Collision 拆成 **stone_ring [11,50,53,84]** 和 **water_bucket [53,54,70,83]**；屋頂／繩索保留 alpha/occlusion 但不能全圖當碰撞。Native blocked tile 協調 pixel collision 與角色腳底 16×12 sample。此修正全圖 23 格 blocked／198 格可從 spawn 達到，井圈六格 (x=5/6/7,y=7/8) 不可穿透。

## 來源與 Windows VX 真正 Gate
- Source Manifest 重組 Ground+PAR、PixelOwner 嚴格一致；Ground、其他八件 Source PNG 和世界位置不改，且全部變動像素僅在舊/新水井 Source 幾何包圍框內。
- **19 張**原生 Game.exe 截圖，含 v2 回歸 11 張＋水井環繞 8 張，非角色背景 0 mismatch，錯誤 foreground Owner 0 mismatch。
- 從 spawn 真正走路 38 步的內部測試路徑，驗證八個方向 N(6,6)、NE(8,6)、E(8,8)、SE(8,9)、S(6,9)、SW(4,9)、W(4,8)、NW(4,6)；不是瞬移到終點假稱可達。
- 另外自西/東/北/南合法位置實際嘗試跨入井圈/桶子，**四項阻擋 Gate PASS**。
- Fail-closed 負向：恢復舊錯誤 ROI 不能通過原圖完整性；移除水桶 collision 會非法開啟 tile (7,8)；將水井 source x+1px 使 PAR 出現 **4,122px** 差異。
- 封包 cold extract 到全新路徑，驗證 **255 檔 SHA**，重新 Source build、Native Game.exe build、19張畫面/12原生步行和非法侵入 Gate、semantic Source 審查四階段全部 PASS。最終 ZIP 加上獨立稽核報告，CRC 及逐檔 SHA 再核對。

## 正式可試玩檔與持久交接
[Google Drive 私人可玩 v2.1 ZIP](https://drive.google.com/file/d/1iYUM7Ct3S6Ddee6ewUWc6C1oo_a2qIG_/view)：36,155,352 bytes，257 entries，SHA256 `27f58a7348725e6f1e0fe6afac17efdfc8238571ce5acd3512a832801d02c129`。解壓後雙擊 `START_STYLE_V21_GAME.cmd`，不須 Python；開發者 `RUN_V21_ALL_CHECKS.cmd` 包含全部檢查（需 Python/Pillow/rubymarshal/Windows 圖形桌面）。

[Google Drive 完整 CURRENT_HANDOFF](https://docs.google.com/document/d/12bXpvOudvXauguHTZzOgSJUcqarMhZTdK0l9-Wp4yWU/edit) 已放回 FS Handoff 目錄。公開 GitHub 只保存 Authority 與程式，圖片／Game.exe 僅於用戶私人 Drive。

**不可宣稱：** 使用者尚未重新人眼驗 v2.1 版本；新 Ground 仍未整合舊 v8 樹屋 Level1／橋下 Level0／橋上 Level2；完整精靈村參考級美術與正式 SEALED FS Runtime 均未通過。

## Cloud-verified local cleanup (2026-10-24)
After Google Drive cloud file metadata, local/mounted SHA256, CRC and independent extracted native VX test were all verified, only the redundant `FS_STYLE_FIRST_V21_RELEASE_COLD_EXTRACT_20261024` cold-test duplicate was removed (257 files, **35.37 MiB** freed). Cleanup audit: `E:\GameAssetToolLab_20261023\logs\STYLE_V21_SAFE_CLEANUP_20261024.json`. Preserved V2.1 source, latest runnable Game.exe, latest private ZIP, original failed V2 artifact, accepted V1 art baseline, SEALED FS runtime and Forest FINAL.
