# R17 Stage 2｜連續地面來源試作 P01/P02｜2026-10-29

狀態：已執行兩次全新 imagegen 地面來源生成及原生像素審查；兩個來源均未獲准進入場景製作。Stage 2 未完成。Art = FAIL（本輪來源初審）；使用者美術驗收 = HOLD；PAR = HOLD；Godot/VX 本輪均 NOT_RUN；Final Seal = NO。

## 本輪實際執行

讀取 GitHub R17 Authority、Stage1 report、CURRENT_HANDOFF、AGENTS、Asset Precheck、Background Authority，以及 Drive Shared Authority、FS v3.2 Precheck、Production、Prompt Workflow、Validation、Source Registry、Elf Village Style DNA 與 GitHub V6 Style DNA。檢視 Windows 的 R17 原生參考裁片。沒有把舊 R12 藝術複製成新候選。

使用 OpenAI 內建 imagegen 真正生成兩張連續地面來源；沒有傳入舊美術圖片，沒有編輯既有 FS 工程。完整提示詞在 PROMPTS.json。來源 PNG 保留原始位元組。

| 項目 | P01 | P02 |
|---|---:|---:|
| 真實尺寸 | 1434×1097 | 1536×1024 |
| 唯一 RGB 色值 | 483,970 | 211,518 |
| 若整張等比縮入 544×416 的比例（未執行） | 0.379216 | 0.354167 |
| 1×診斷裁片 [x,y,w,h] | [400,210,544,416] | [496,290,544,416] |
| 裁片與來源該區 RGB 差異 | 0 | 0 |
| 生成透明物件／完整場景／PAR | NOT_RUN | NOT_RUN |
| 來源美術初審 | FAIL | FAIL |

P01 提示明確要求 544×416，但實際尺寸未遵守。P02 改以連續 SOURCE TEXTURE 為目標，強調草葉2–4原生像素、石板5–9原生像素及16色；實際石板與可見像素團仍偏大，且未遵守16色色盤。

尺寸不同本身不代表 SOURCE ASSET 無效；來源可以大於最終畫布。但不能將整張大圖縮小、或將任意544×416裁片，直接宣稱符合原場景的道路、入口、密度與完整地面規格。上述縮放比例只有診斷意義，實際沒有套用。

色值總數只驗證本次16色提示約束是否生效，**不是全專案通用藝術好壞門檻**。P01/P02均經原生1×裁片目視：P01草葉高頻細節偏密、邊緣偏軟；P02局部更方塊化，但石板、草叢尺度與精緻參考仍不一致。這是本輪來源拒絕理由；不能說已證明所有imagegen或C流程都不可行。

## 故障分類與防止重犯

| ID | 層級 | 發現 | 處置 |
|---|---|---|---|
| S2-01 | SOURCE_ART / DIMENSION | 提示像素尺寸不等於真實輸出尺寸 | 生成後先解碼量測，模型不作座標或尺寸權威 |
| S2-02 | SOURCE_ART / PIXEL_DENSITY | 看起來方塊化，仍不等於原生1px細節 | 交付前必看1×，3×nearest只作局部診斷 |
| S2-03 | SOURCE_ART / PALETTE | P02要求16色，實際211,518色 | 記錄不遵守提示；不偷偷量化後宣稱原生16色 |
| S2-04 | NORMALIZATION | 整張縮入需求約0.35–0.38，超出既有0.75–1.25預設來源比例範圍 | 沒有套用縮放；也不以自動去雜訊、銳化或平滑掩飾 |
| S2-05 | SCOPE / CLAIM | 544×416裁片可形式滿足尺寸，卻不保證完整道路和物件空間 | 裁片只命名DIAGNOSTIC / NATIVE_QA，沒有生成正式GROUND_FULL |
| S2-06 | TERMINOLOGY | 舊Ground-only與R17 GROUND_FULL名稱意義不同 | 保留分層名稱契約；不改寫Stage1規則 |

依 V6 Style DNA「先 Ground-only Art Gate；失敗禁止拉房屋/水域修飾」，本輪沒有在未過關地面上追加房屋、樹或引擎驗證。未製作透明來源物件，A依然NOT_RUN；不可因地面生成成功就說C流程完成。

## 後續命名契約（設計，未產生這些圖）

- TERRAIN_PLATE：沒有烘焙立體物件的連續地面來源／衍生底圖。
- OBJECTS_COMPLETE：完整物件作者層，保留全部源物件，不先裁掉樹根。
- GROUND_FULL：R17 runtime要求的完整美術畫面；必須由同一來源與manifest確定性合成。
- PAR_TRANSPARENT：依R17規則衍生的角色遮擋層；樹最底接地一格排除，與作者完整物件層分開。
- SHADOW/LIGHT：需要時獨立保存；本輪沒生成。

此契約只是避免誤稱，沒有修改舊authority，也沒有建立可執行場景。

## 可重現證據

執行 `python audit_sources.py`（Pillow、numpy）。
程式只讀來源、驗證SHA、產生1×裁片及3×nearest局部比較、RGB統計和JSON；不生成美術、不修改來源、不依賴前景視窗。
輸出 SOURCE_REGISTER.json、reports/SOURCE_AUDIT.json、qa/R17_STAGE2_NATIVE_QA.png。
原始PNG、提示詞、診斷圖、報告與程式均包含在研究ZIP。

P01 SHA256:
`fbe099596a9648bc13e2560190a5fff2aaefc333d7a0ed4ad81d35148edff3e4`

P02 SHA256:
`13e040f293e6e132fd4e79c38cf763a661155be305efcbf2af2a5689af4625a6`

[Drive Stage2資料夾](https://drive.google.com/drive/folders/1TUYoNuuEUiqqZ4vR0KPdu7RaGFt3Q1bH)
[P01原始來源](https://drive.google.com/file/d/1VoRGhwvqwnNjEwyCGYyEC3oCzblnUprN/view)
[P02原始來源](https://drive.google.com/file/d/12ykf-WzFp56x1IZj_JPg05yshY_V6Ybs/view)

## NEXT_COMMAND

接續 R17 Stage2 地面來源關口；先讀本報告與CURRENT_HANDOFF。
不重複只改「544×416、no AA、16色」的提示詞試驗，不強縮這兩張PNG，不將診斷裁片升級為地面。
下一次應改變可驗證的來源製作能力：以原生尺寸像素編修／能控制原生像素密度的製作方式建立完整544×416連續地面，逐像素來源可追溯；先看1×草地、5–9px石板與32px角色尺度，再建立物件anchors。不能只拼兩種tile，也不能事後從含房屋的Master補地。
通過地面初審後才依序生成完整主屋、三種完整樹、窄路燈與欄杆的獨立透明來源；每件逐項檢查。人眼最終美術與PAR驗收仍不能自封通過。

## 保護與限制

Stage1比較和原始證據保留。本輪未執行Godot/VX，未修改任何已封版Scripts.rvdata、Map003或其他藝術來源。本輪沒有重新量測正式二進位SHA，不把歷史守衛值宣稱成本輪重驗結果。
FS_MAP_COMPILER_AUTHORITY_V1在本次所查main樹與精確Drive名稱中未找到；本輪沒有設計／變更正式compiler，只加入獨立來源審查程式。實作正式compiler前仍應定位該文件。
Linear get_agent_context回覆工具不存在；已讀SHO-34現有描述，沒有據此推測額外授權或技術結論。

Final Seal = NO。
