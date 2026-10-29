# FS R17 Direct Stage4 V1｜高精細來源先行 Ground/PAR 候選（2026-10-29）

**STATE: SOURCE-FIRST TECH PASS CANDIDATE / ART VISUAL CANDIDATE, USER PENDING / FORMAL SEAL NO.**

## 實際製作與改善
這一輪直接在 Windows 原機 Python3.11 + Pillow 執行，將之前 Stage3 V2 已知 ART FAIL 的程序噪點地面完全停用，改用真正獨立的歷史美術來源。

- Ground baseline：FS V6 P2 的 `GROUND_B.png`，已存在於早期 Source-first 場景的完整自然草、土路、石路、高密度花草單獨地面來源。原生 544×416、無升高房屋/整棵樹。注意：此歷史 Ground B 曾被同意繼續測試，**不等於這次 R17 佈景已經人工 ART PASS**。
- Blue cottage：FS V23 獨立的 `elf_blue_cottage.png` 透明 153×130 原件，避免 V29/V30 發現有外接方形草地的 moss cottage 污染。
- Sacred tree：FS V6 `SACRED_TREE.png` 獨立透明 213×224 原件。編圖之前直接在原始樹 sprite 先分配中心最底部 32×32 到 GROUND，其餘樹幹/樹冠到 PAR；**未從完成 Master 或已生成 PAR 逆切任何物件**。
- World origin [0,0], 1× 不縮放。藍房 (329,126)；神聖樹 (19,135)。兩份圖皆採同一來源場景宣告但各自從源資產編成。
- 使用者只需要 `GROUND.png` + `PAR.png`；合成圖只作 QA，不能當 Ground 運作圖。

## 三個 Gate 與實際驗證

| Gate | 實測 | 判定 |
|---|---|---|
| Ground 容器 | 544×416 RGB, 542,468 bytes | TECH PASS |
| Ground SHA256 | `41911e461f4f74b95d382ce7fa0a3b880a34ba63958c1028310b035231d64c8e` | 原機 E:/G:/雲端下載一致 |
| Ground 來源純度 | 除樹接地外逐像素與 V6 GROUND_B 相同 | CHECK PASS |
| 接地樹幹影響 BBox | [109,327,141,357]，位於來源規劃的 [109,327,141,359] 32px 區塊內 | CHECK PASS |
| PAR 容器 | 544×416 RGBA, 117,807 bytes | TECH PASS |
| PAR SHA256 | `99215dbb6ea68fab27aaf18d2b5188426e0d748cf5451bd1a2e5a01460605271` | 原機 E:/G:/雲端下載一致 |
| PAR alpha=0 | 185,503 px; alpha>0=40,801; partial alpha=0 | TECH PASS |
| 神聖樹獨立兩來源重組 | 逐 RGBA byte 完全等於原樹 sprite | CHECK PASS |
| Official source validator | Exit 0、TECH_CANDIDATE_ONLY_NO_ART_PASS | TECH PASS |
| Cold unpack rebuild | 來源+腳本獨立重跑，Ground/PAR/QA 三張 SHA 全相同 | PASS |
| ZIP | 2,801,358 bytes, 18 entries, CRC PASS, SHA256 `e5219f29963b51c2815e7fdd671ecada48b4d11436c809f816bd136c9c0ce7e7` | 原機 E:/G:/雲端下載一致 |
| GROUND_LAYER 視覺 | 自然地面品質大幅優於 Stage3；正式新場景未用戶核准 | HUMAN HOLD |
| PAR_LAYER 視覺 | 完整藍屋和樹冠、無 Stage3 方形樹底；門檻/樹接點 1x 仍待核准 | HUMAN HOLD |
| PAIR_ALIGNMENT | 技術對位 PASS；新畫面視覺核准未完成 | VISUAL HOLD |
| Formal Seal | **NO** | 不能宣稱正式藝術通過 |

## 交付與安全
- [Google Drive Stage4 私有來源及作品資料夾](https://drive.google.com/drive/folders/1tx5JIwoVZm-1Hmx9LudYq0kuOE-DAm5X)
- [GROUND.png](https://drive.google.com/file/d/1B6FLLuZmA2AaJITb15g3ebrZKZ8fYvnf/view)
- [PAR.png](https://drive.google.com/file/d/1TQwjj4p_etVewWB2U71c8PG-7YJ06rbe/view)
- [QA Composite（僅檢查，不得當 Ground）](https://drive.google.com/file/d/18C9nZhb89PeeUIoyomrfnmtMidM_5qwz/view)
- [完整可重現私人 ZIP](https://drive.google.com/file/d/1yaqN1rZID6AHwUjLhoCX91fVtgjWg2Iy/view)
- [Official source validator JSON](https://drive.google.com/file/d/1XWie7S0KD-cI9iVQqBg8R2Edg_hd9i4g/view)
- [source registry](https://drive.google.com/file/d/1PifZMhyjGHCUkSs_bSQRySIwy7bNnkfy/view)
- [可重現 Stage4 生成程式](../../tools/r17_direct_stage4/build_stage4_v1.py)

所有原始圖檔/衍生PNG保留私人 Drive，不把可能有授權/權利風險的源圖放公開 GitHub；GitHub 只收工具與紀錄。已在雲端 Drive 重新下載雙圖與 ZIP，與 Windows E: 及 G: 各自的 SHA256 比對完全相同。

No changes to sealed FS/K4, Scripts.rvdata, Map.rvdata, collision or passability. User keeps ownership of later merging `GROUND+PAR` into `NEW_GROUND` and mapping passability.

## 下一步止損與驗收
1. 先讓這組原圖在 100% 下接受 Ground/PAR/接地與混合畫面視覺驗收。不要僅以 alpha/重組 SHAs 宣稱美術成功。
2. 若此風格可接受，再用獨立透明來源增加場景物件與藝術密度，避免簡單素材拼貼造成 R14/V2 退步。
3. 最終只在 544×416 的三 Gate 充分成熟後，延伸到 ground3 級 1280×928 原生世界，不縮世界尺寸湊 17×13。

**Negative cases preserved**：R17 Stage2 烘焙 Master+PAR 逆切 FAIL；Stage3 V2 程序地面美術 FAIL；V29/30 moss cottage turf 邊緣污染 FAIL。保留既有 Authority 的三 Gate 與 Failure Ledger，沒有覆寫舊封版。
