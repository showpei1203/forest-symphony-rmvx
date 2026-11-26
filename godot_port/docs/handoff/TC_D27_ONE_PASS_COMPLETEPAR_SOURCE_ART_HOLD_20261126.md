# Forest Symphony｜T-C D27 單次整張 CompletePAR：真來源生成、來源尺寸 FAIL、資訊圖拒收｜2026-11-26

**使用者最新權威**：一次性生成整張完整 PAR，不能以單橋、單工坊的創作/修正或多物件 Alpha 島拼裝代替。權威已寫入 [D27 一次性完整 PAR 規格](../production/T_C_D27_ONE_PASS_COMPLETE_PAR_AUTHORING_CONTRACT_20261126.md)、兩條 T-C 分支的 ART-FIRST SOP/CURRENT_HANDOFF、兩份 Drive SOP，均完成 WRITE→READBACK。

## 本輪實際出圖：來源已產生，正式美術未封版

**D27-A**：在**單一次生成**得到一張原始獨立全非地表的真透明 RGBA source（不是資訊圖、不是 Ground Master、不是分群拼裝）。原始 **1474×1067**，SHA256 `5a089071cef9e0cb2315afee9f6af9075d913963a3e769e19f3fd5f331ada27d`，Alpha=0 **1,011,280**，Alpha>32 **464,739**，可見物件 bbox `[10,11,1463,970]`。同次畫全工坊/吊車/橋/棚屋/燈/旗/岩柱等並保持整體畫風。

**源規格與地貌尺寸仍 FAIL**：正式凍結 Ground 為 D17 `1280×928 RGB` SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`。D27-A 源作者畫布 1474×1067 **不是** 1280×928；直接左上 1×裁切會去掉 **45,499** 個原始 Alpha>32 有效像素；來源橋聯通群約 **559px 寬**、主要工坊群約 **510px 寬**，沒有符合 5–6格橋/9格工坊。與真 Ground 世界對位未有 pixel-bound 錨點證明。應記 **ONE-PASS SOURCE FORMAT true RGBA PASS / SOURCE SIZE & WORLD ART FAIL**。

**整張 QA-only 合成**：只作**整個畫面一次整體縮放** 1474×1067→1280×928 和 D17 Ground 靜態 alpha composite 的**視覺診斷**，完全沒有把圖切成單件，也沒有單獨修任何部分。但整張縮放不等於合格原始 1× CompletePAR；**不納入官方候選或正式計數**。合成預覽 SHA `c95444ce6071739423cfba0b0030a4d24f1ef18b1446e3108a499e60fbd001f2`，SOURCE SIZE 仍 FAIL。

**D27-B / D27-C 兩次失敗**：模型輸出帶有自稱技術 PASS、虛構量測和假小圖的資訊圖，實際不是 PAR。D27-B RGBA 1477×1065，Alpha=0 983，SHA `c2119166e789067b22fd8193d9f03427247bdc7e0aef8d0d00d2b7cb07b3922a`，REJECT WRONG MEDIUM；D27-C RGBA 1464×1074、Alpha=0 **0**、SHA `d791372cee8953b085bdefcb0f6fae7ed76be237789f08c674fc61ee79dacbbc`，REJECT WRONG MEDIUM AND NO TRUE ALPHA。圖片上所有 PASS/1280/人工核准均**非真實證據**。**不可把這兩張資訊圖當 D27-B 成功來源**。

## 真實證據與私人權限
- [D27 **11檔完整原始 Ground／單次完整 PAR 原圖／全畫布 QA 預覽／B,C 拒收資訊圖／JSON／驗收工具／FailureLog 封包**，14,026,346 bytes，ZIP CRC PASS](https://drive.google.com/file/d/1wuzvKRIf1RGKfTH2w0cdHEA3Nh5lORSK/view)，SHA256 `4edba5a0bcc073fa6da7db5f661abed6ed209c5946221ddedc8545125462aed0`。
- [**真正一次生成的 D27-A 整張非地表透明來源**](https://drive.google.com/file/d/10WAlAHGuHZ189yS8khaAPG37qiCUSJ3m/view)，1474×1067，**尚非正式可用 1280×928 PAR**。
- [僅 QA 的 D17 Ground＋D27-A 整幅統一縮放合成預覽](https://drive.google.com/file/d/1Du36K2v9MWqNuwdek-D2rgAJMf3sV636/view)；[單張整畫布縮放源預覽](https://drive.google.com/file/d/1-w8xnpiuD5evQLsDWxh6HZZF3A5MDRP0/view)（皆不作正式 PAR）。[真相 QA JSON](https://drive.google.com/file/d/1vMEe-ZAQcGwsmkgRvJ-R7hSlXlcj3vBI/view)。
- 已 Google Drive metadata READBACK：以上全部 `shared=false`、only owner；公有 GitHub 不含任何私人 PNG。

## 工程/ART 門檻
| 階段 | 結果 |
|---|---|
| 規則修正：GitHub 2 分支＋Drive 2 SOP | WRITE→READBACK PASS |
| D27-A 單次整張非地表原圖真 Alpha | **SOURCE FORMAT PASS** |
| D27-A 原生 1280×928 世界座標／尺寸比例 | **FAIL** |
| D27-B/C 錯媒介資訊圖 | **REJECT** |
| D27-A 整幅 resample 合成 | **QA-ONLY，不等於正式 1× PAR** |
| D27 真來源 Godot 4.7.2 Native | **NOT_RUN**，原因 SOURCE 尺寸/對位未通過 |
| 人工正式地圖 ART PASS | **0／12 HOLD** |
| 原始 D17 Ground／D18–D26 素材 | 原封不動 |

## 這次真正修正的製程
**不能再把「修出比例正確的零件」當主目標。** 一張 Source 不能原生對位就換**整張生成工具的畫布/對位能力**，不是修橋、換工坊、切分物件、再拼一張。單次作者的風格一致性是 D27-A 的可用經驗；原尺寸與世界定位失敗是下一步硬阻斷。優先驗證能同時控制**整幅 1280×928、true alpha、鎖定 Ground pixel landmarks、完整物件同畫面**的 single-shot 作者路線；若做不到要如實標工具限制，不能再用提示詞生成虛假驗收資訊圖。
