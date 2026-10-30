# FS R17 Stage12｜原始高細節材質重新創作 Ground（2026-10-30）

**Status: Ground/PAR native-container TECH PASS / ART CANDIDATE, USER HOLD / TREE-FOOT & PAR-EDITABILITY HOLD / Formal Seal NO.**

## 目標與本輪真正改變
繼 R17 Stage4~Stage11 多輪「Ground 太程序化、石路太簡陋、草叢比例不正確」後，本輪不再調整噪點／碎石數目。經遠端 Windows 原機查到本地實際來源圖 `FS_Reference_SourceCandidates_20261023/A2_VSCliff.png`（512×384 RGBA，原始手繪草地與米色石板 Atlas），搭配舊 `grass_tile.png` 原始32×32地材，開始**以來源材質 patch overlap matching 重建全新 Ground**。沒有打開舊 Ground，也沒有從 R17 完成 Master 逆切。

- A：32px來源草地拼合，景物清楚但地表太平淡。
- B：大量原始 A2 高密度草叢紋理，雖提升細節，但**看起來像大片高植被**，違反「GROUND 地表而非高草叢」；直接標示視覺 FAIL。
- C：86% 平坦原生草地來源 + 14% A2 草地微紋理，真正新的地表；米色手繪石板改以 26px 重疊邊緣配對拼合，降低重複接縫。花朵單位不超過6×6px，低植栽群沿路緣適度分布。採 C 作技術及藝術候選。
- 第一版有 **cubic Bezier 公式遺漏 `t`** 的程式錯誤，導致道路形狀不合理，重測前已主動更正，正式版本 `build_stage12_a2_quilt_v2.py` 使用正確 cubic control term。
- 共有4條曲線道路連接房屋前方街角，重新使用原始來源圖創作，並非修補 Stage11 Ground。
- PAR 沿用 Stage7 獨立生成、已修正 RGBA 的高細節透明層，兩房、大樹、欄杆、路燈、花飾密度保持；**PAR 是已組合的獨立透明來源，不是每個物件均有原生可編輯檔，且原始來源曾被最近鄰縮小**。

## 真實 Windows/Python 原機測試及雲端內容核對

| 項目 | 結果 |
|---|---|
| 原生輸出 | 544×416 RGB `GROUND.png`，544×416 RGBA `PAR.png` |
| Ground SHA256 | `1e3e97fc1ec9288f78eabd42c351b694f5aa55e8123bd1e8d7a8acf556911363` |
| PAR SHA256 | `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9` |
| 真正PNG直接合成 | RGB 0px difference |
| Source-validator | exit0: TECH_CANDIDATE_ONLY_NO_ART_PASS |
| Strict alpha/canvas/manifest gate | exit0: TECH_CANDIDATE_ONLY_ART_HOLD |
| PAR外框 | 所有 4 邊 Alpha=0 |
| 源碼+3原始PNG 冷重建 | 7 張原圖／QA SHA全部一致 |
| 故意截斷PAR1px | exit2 FAIL-CLOSED |
| 故意外框加Alpha1px | exit2 FAIL-CLOSED |
| 偽造來源SHA | exit2 FAIL-CLOSED |
| Drive和原機 Ground/PAR/ZIP | 雲端下載後 SHA256 與原機相同，ZIP CRC PASS |
| 私人 ZIP | 5,685,497 bytes／21 entries，SHA256 `9f8cb4d5eda0814015dacef9861a353568ae9212934524d8f0d5821e4210e93e` |

## 實際人眼美術判定
- **GROUND ART：有實質改善，仍為 HUMAN HOLD，不封版。** 道路不再是孤立石頭／程序泥帶，且已改為來源手繪米色石板，比例自然。地表花草目前還不夠密、不夠有層次，離 `ground3` 原稿的豐富程度仍有差距。
- **B 版 FAIL**：高密度綠草紋理看起來立體草叢，比房屋和行走尺度更搶戲。這是本輪具體負例。
- **C 版比例：候選**：以 6×6px 低花為單位，Ground不含房子、樹幹、巨大灌木；房子與大樹視覺主體感保持。
- **PAR逐物件來源：HOLD**；雖透明、獨立，原圖不是全部逐物件可編輯原生1×素材。
- **樹幹接地語義：HOLD**；為避免使用者曾指出孤立樹幹，Ground維持無樹幹，完整樹在PAR，尚未與早期「最底32×32樹幹歸Ground」規則達成一致。
- **來源自述Manifest／冷重建／合成0px都不能證明人工美術正式PASS。Formal Seal NO。**
- 原封版 FS/K4 Map.rvdata、Scripts.rvdata、Collision／Passability 全部未改。

## 真實交付檔案
- [Drive Stage12 原圖、3候選、所有原始來源、QA及ZIP](https://drive.google.com/drive/folders/1c6w2ffUrA_jA349VlUXpYZkXm13twx4g)
- [GROUND.png](https://drive.google.com/file/d/1Vs0sH90p_NnIdD9s_jdjxeIH5t7ujqr7/view)
- [PAR.png](https://drive.google.com/file/d/1QzNDTueVR85TlkVNcybeeYY7ArXZ2Zp7/view)
- [真正PNG合成QA](https://drive.google.com/file/d/1FpCD5iH_6Mgdw8UgV-iKHnVU75_23N_g/view)
- [Stage11/10與Stage12真實QA對比](https://drive.google.com/file/d/11z_ojjTz539ruZUlR0Wx1FE21SdTO-X0/view)
- [完整可重建ZIP](https://drive.google.com/file/d/10J2vLgu5oSXGycpx5gAqifMdtkGlP4hr/view)
- [正式製作程式](../../tools/r17_direct_stage12/build_stage12_a2_quilt_v2.py)
- [驗證/冷重建/封包程式](../../tools/r17_direct_stage12/validate_and_package_stage12.py)

**Next:** 繼續原始地面美術來源品質，改善自然的花草分群及局部光影；先人工檢視C版原生1×美術，不要自動放行至1280×928或編輯正式FS Map及腳本。保留 B 密草反例、第一版 Bezier 錯誤與歷史 Stage4~11 技術/藝術 FAIL。
