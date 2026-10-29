# CURRENT_HANDOFF_R17｜USER DIRECT-LAYER CORRECTION｜2026-10-29

**最高優先級：使用者取消助手「從完整Master再切PAR」的工作流程。現在正式要求只生成並檢查兩張原生分層圖：GROUND.png（只含精緻地表，不烘焙完整立體物件）及PAR.png（只含真正RGBA透明立體物件，無地板）。使用者自己先疊兩圖成完整Ground，再於FS上放PAR，最後使用FS原有通行度腳本自行設置；助手不要代做Collision、Map.rvdata或通行度。**

## 首讀順序（高優先）
1. `R17_DIRECT_GROUND_PAR_AUTHORITY.md` (**NEW, overrides conflicting Stage1/2**)
2. `R17_DIRECT_PAIR_PROVENANCE_GATE.json`（真的成雙源R14結構TECH PASS但ART FAIL；R17 Stage2美術更好但GROUND已烘焙前景、DIRECT_PAIR_PROVENANCE FAIL）
3. `R17_DIRECT_LAYER_CORRECTION_REPORT.md`（本次修正報告與下一個正規實作）
4. `R17_USER_CORRECTION_TRUE_LAYER_VS_PREBAKED_6PANEL.png`（來源前景、地面、預覽比較）
5. 舊`R17_STAGE2_NEW_ART_20261029/CURRENT_HANDOFF_R17.md`只作歷史實驗，**舊的Stage3「再切PAR、編譯碰撞、原生VX每版跑」已被新規則取代，請勿當指示。**

## 確認場景/輸出定義
- `GROUND.png`：544×416 benchmark（日後1280×928），精緻連續草路/石板路/地面花草/貼地陰影，樹幹接地最底一格32×32例外歸GROUND。**Ground不得預先含完整房屋、樹冠、燈柱或欄杆**。
- `PAR.png`：原生RGBA Alpha0背景，同尺寸同坐標，完整房屋/樹冠/非接地樹幹/路燈/欄杆/橋扶手/招牌等，**不能混地板**。同一Style Lock/場景規格直接生成，若失敗重做元件/來源，不再從Master逆切/把PAR再裁剪。
- 用戶自行 `NEW_GROUND=alpha_composite(GROUND,PAR)`；再在FS套`PAR`並用自有通行度腳本。助手可生成`COMPOSITE_PREVIEW.png`自檢但不能把它當Ground或主要交付。
- 驗收僅兩個原生PNG美術/Alpha/物件完整度、合成位置與接地融合。角色前後／Godot/X原生VX／Collision都非本輪必要驗收（除非用戶另要求）。

## 本次實際QA回歸（不是新藝術成品）
檔案`R17_DIRECT_DUAL_OUTPUT_CORRECTION_20261029`。
- R14 source-first Ground BASE vs真Alpha PAR：544×416；PAR有透明173,519像素；Composite 0像素diff；五個純地面格PAR alpha0。**source separation TECH PASS／Art FAIL**：221地面tiles只2種紋理、清晰細線。
- R17 Stage2 Master baked already + PAR：544×416；Composite 0像素diff，PAR有透明140,774px，但Ground來源內含所有屋/樹/物件，**源雙生成根本不成立，DIRECT_PAIR_PROVENANCE FAIL**。R17先前11物件候選仍有81px道路衝突+兩欄杆FAIL。不可當成Direct-layer的成功案例。
- 技術門檻獨立與視覺QA都需要，現階段沒有GROUND+PAR雙層藝術正式PASS。
- 舊的本機最新：`R17_STAGE2_NEW_ART_20261029`、原K4 Scripts SHA5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa、Map003 SHA118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4未改。

## 下一輪工作指令
**R18（可稱R17 Direct Layer Stage3）：一開始就分開生成GROUND與PAR兩張，兩者同構圖高細節、全房屋+3完整樹+燈/欄杆全部在畫框內。不可先生成MASTER再切PAR。** 用Godot/Tiled作來源層編輯與驗證可以，但不能用R14兩塊地磚拼滿充數；Ground Art 與PAR Art及Alignment三個Gate需全部人眼接受。不執行碰撞設置，僅交兩張正確PNG。每階段同步Drive/GitHub/Linear。
Formal Seal=NO（尚未有合格的真分層雙圖藝術產物）。

## 2026-10-29｜Source validator / budget rebaseline sync audit
- Direct-layer source validator (new, fail-closed): [tools/r17_direct_ground_par_source_validator.py](../../tools/r17_direct_ground_par_source_validator.py). It checks PNG/size/alpha/hash/declared source lineage, never grants artistic or formal PASS.
- Manifest template: [FS_R17_DIRECT_PAIR_SOURCE_MANIFEST_TEMPLATE_20261029.json](FS_R17_DIRECT_PAIR_SOURCE_MANIFEST_TEMPLATE_20261029.json).
- Sync and research budget reset audit: [FS_R17_GITHUB_SYNC_BUDGET_RESET_AUDIT_20261029.md](FS_R17_GITHUB_SYNC_BUDGET_RESET_AUDIT_20261029.md).
- The new R17 Direct Stage3 research ledger starts at zero *stage-local tracked spend*, with spend cap unspecified. GitHub/AI provider quota or billing reset is NOT VERIFIED / NOT PERFORMED.
- Existing Authority, handoff, and provenance JSON paths were read back from GitHub main. Previous 404 could not be reproduced on those exact paths; no blanket promise about other URLs.
- Gate state unchanged: `GROUND_LAYER=HOLD`, `PAR_LAYER=HOLD`, `PAIR_ALIGNMENT=HOLD`, `FORMAL_SEAL=NO`. No new approved PNG pair; sealed K4/VX untouched.


## R17 Direct Stage3 V2｜實際雙來源候選，2026-10-29

**最新狀態：來源直接雙圖已實際生成且技術 Gate 通過，但美術初審 FAIL；Final Seal = NO。** 不是只有文件同步了。使用者要求的正式 Ground/PAR 純美術標準未達成。

- 真正產出：544x416 `GROUND.png`（獨立地面，未使用已烘焙 Master）及 `PAR.png`（原生 RGBA 透明立體物件），每份都有 SHA-256 和來源生成腳本。
- V1 過度碎紋、樹底方形塊與攤位風格混亂，修成 V2：較少噪點、三種樹從創作階段拆為 Ground 接地／PAR 樹冠，取消攤位；原生 1x 同座標。
- V2 SHA-256 Ground `afe788742140344bcefe3c3f03dd28d7c9e80d86465ea31799846a259314b875`；PAR `e9b48d895bfffc6b9818a30dbf20b3a4a103528dd415db105325e2a52b74ee8b`；PAR 真透明 Alpha0 = 194111px。
- `r17_direct_ground_par_source_validator.py` 確認 544x416、Alpha、來源宣告、SHA 正確並退出碼 0；只代表 TECH CANDIDATE，**不代表 Ground3 等級 ART**。
- 視覺判斷：目前 Ground 石路/草仍顯人工程序痕跡，房屋和新樹的美術風格／細節落差仍大；兩個藝術 Gate 明確 FAIL，不能進 Formal Seal。
- GitHub [完整研究報告](FS_R17_DIRECT_STAGE3_V2_SOURCE_FIRST_ART_FAIL_20261029.md)、[來源生成腳本](../../tools/r17_direct_stage3/build_r17_stage3_source_first_v2.py)
- [Google Drive V2 研究包及雙圖](https://drive.google.com/drive/folders/1DDs8NPle60OAYFTUs-kgRwZdBOUrMTNJ)；[GROUND.png](https://drive.google.com/file/d/1aCbJVpmx_gQO2e9cm3qO75arzX8MO2mp/view)、[PAR.png](https://drive.google.com/file/d/13LafoTIDMdLB6X6idFvF_qAoVG_7Co72/view)、[私人可重現 ZIP](https://drive.google.com/file/d/1TzoHecVGEj6iKeb2hRvFJ3DhV0FcNPM4/view)。
- E:/G: 來源雙圖與 ZIP SHA 相同；Drive 雲端 Ground/PAR/ZIP 已另外重新下載至工作容器並做 SHA256 比對：三者與 E:/G: 完全相同；ZIP 22 項 CRC 正常。**雲端內容完整性已驗證，但美術仍 FAIL，Final Seal 仍 NO。**
- 接續方向：**提高原生獨立地面和前景素材的藝術完成度**，以 R17 Stage2 優秀完整圖當視覺品質參照但絕不可把其 Master 當新的 Ground 或反切 PAR。不得覆寫 K4 Scripts、Map003 或替使用者設定 Collision。
- 狀態：`GROUND_LAYER=ART_FAIL`；`PAR_LAYER=ART_FAIL`；`PAIR_ALIGNMENT=TECH_CANDIDATE_VISUAL_HOLD`；`FINAL_SEAL=NO`。


## R17 Direct Stage4 V1｜高品質原生雙來源（2026-10-29）

**Latest authority handoff: SOURCE-FIRST TECH PASS CANDIDATE / VISUAL HOLD / FINAL SEAL NO.** Stage4 已實際從 V6 原生完整 Ground B（自然草路與花草）及 V23 透明藍屋、V6 神聖樹原始 Sprite，在來源作者階段直接組合出兩份獨立 PNG，不是 Stage2 已烘焙 MASTER 逆切 PAR。

- 正式兩圖：`GROUND.png` 544x416 RGB，SHA256 `41911e461f4f74b95d382ce7fa0a3b880a34ba63958c1028310b035231d64c8e`；`PAR.png` 544x416 RGBA，SHA256 `99215dbb6ea68fab27aaf18d2b5188426e0d748cf5451bd1a2e5a01460605271`。
- 場景：藍房 XY(329,126)，神聖樹 XY(19,135)，1x 原生不縮放。樹作者階段「最低中央32x32」接地點歸Ground，其他樹枝/樹冠與整間房歸PAR。GROUND 僅這個32x32區域不同於原本 V6 Ground B，像素差BBox [109,327,141,357]。
- PAR Alpha=0 有185,503px、可見40,801px；預先獨立樹來源二分重組回原始 Sprite 逐位一致。Official validator exit0；冷解壓後自帶原始圖與生成程式重跑，Ground、PAR、QA 3張 SHA 完全一致。
- 私人ZIP 2,801,358bytes／18 entries／CRC PASS；SHA `e5219f29963b51c2815e7fdd671ecada48b4d11436c809f816bd136c9c0ce7e7`；E/G 掛載與雲端重新下載 SHA 3方一致。
- [Google Drive Stage4 V1 私人交付](https://drive.google.com/drive/folders/1tx5JIwoVZm-1Hmx9LudYq0kuOE-DAm5X)：雙PNG、QA、sources、manifest、validator、zip。 [GitHub完整紀錄](FS_R17_DIRECT_STAGE4_V1_SOURCE_FIRST_VISUAL_CANDIDATE_20261029.md)／[可重現程式](../../tools/r17_direct_stage4/build_stage4_v1.py)。
- **實際美術改進：**不再使用 Stage3 的程序地面，原生 Ground B 道路、植栽、藍屋、神聖樹的質感更接近指定風格。但場景美術密度仍低於 R17 Stage2、Ground B 的歷史續測不代表新場景獲使用者批准，**GROUND_LAYER=HUMAN_HOLD／PAR_LAYER=HUMAN_HOLD／PAIR_ALIGNMENT=TECH_PASS_VISUAL_HOLD／Formal Seal NO**。
- 完整保留 R17 Stage2 baked master、Stage3 V2 地面噪點、V29/30 moss cottage turf 失敗負例。K4、Scripts、Map、通行度不動。
- 下一步：以 1x 原圖及合成 QA 視覺審核配對（尤其屋前接地、樹根下方），再擴充高品質獨立素材，不從完整 Master 逆切，暫不推進大世界與 Collision。


## R17 Stage5 Latest Generated Pair｜2026-10-29 FAIL-CLOSED

**New model-generated original images have actually been audited; DO NOT classify them as source-first production.** User's latest Ground `像素風草原岔路地景.png` is 1434x1097 RGB; latest PAR `精緻像素風精靈村落角落.png` is 1448x1086 RGBA. Width mismatch +14px; height mismatch -11px. Neither is native 544x416 or 1280x928 nor divisible by 32 on both sides. Ground SHA256 `1b03b0907e0c0e45534e5d7b8fcbc1f038a19a76a2fafb57733515dd5fc85ae3`; PAR SHA256 `f44b7c11c7b5bbf345f4c5b8a7821d297fc8dd6c52166cb160bf6cc83ae7eb2d`.

PAR native alpha0=597822, alpha1..254=974430, alpha255=276. Border alpha leakage top29/bottom114/left118/right69. Ground content rich, PAR contains two houses, large tree, fence, lamps and other structures and offers better **concept-level** density, but no shared origin/scene manifest, ground tree-contact source, or formal native image alignment. No independent original layer pair has been validated. Do NOT crop to match, resample to 544x416, or reverse-cut completed Master. 

**Real Windows G: cloud-synced image gate run** on `DESKTOP-90VT437`: latest returns exit2 `FAIL_CLOSED_TECH`; historical 544x416 Stage4 V1 technical positive control returns exit0 `TECH_CANDIDATE_ONLY_ART_HOLD`; cropping 1px off the historical PAR returns exit2. New `tools/r17_pair_alpha_canvas_gate_v2.py` is published and reproducible. Added actual PAR checker and invalid top-left diagnostic overlay **explicitly QA ONLY**.

- [Google Drive Stage5 originals, strict gate JSON and diagnostic images](https://drive.google.com/drive/folders/1IAX5lVbQdu3sejy_pqpH-nEptEDrmnSM)
- [GitHub detailed measured report](FS_R17_STAGE5_LATEST_IMAGEGEN_PAIR_FAIL_CLOSED_AUDIT_20261029.md)
- [Native alpha/canvas fail-closed gate](../../tools/r17_pair_alpha_canvas_gate_v2.py)

Statuses: `GROUND_LAYER=FAIL_SIZE`, `PAR_LAYER=FAIL_SIZE_ALPHA_CLEANLINESS`, `PAIR_ALIGNMENT=FAIL`, `SOURCE_PROVENANCE=NOT_VERIFIED`, `VISUAL_DENSITY=PROMISING_NOT_APPROVED`, `FORMAL_SEAL=NO`. Preserve all sealed FS/K4 binaries and user's personal collision setup. Next: build a common **544x416 world blueprint** and regenerate actual native pixel-crisp **source-first** matching Ground+PAR at identical origins. GROUND trees' foot contact from original source stage, not detached trunk stump.


## Stage6 2026-10-29 handoff

Actual independent 544x416 RGB Ground and RGBA PAR were generated from scratch terrain and standalone sprite objects, using one shared blueprint. This is a technical candidate, **ART FAIL / FINAL SEAL NO**. Ground SHA256 a7b8a40fd5b08ea270374c8c14aebbd9b3948ecb107ceb624e51f048d374bf26; PAR SHA256 353856053490e77a84073451e75c6e6708491d798b77469b3729f2131723bfee. PAR transparent pixels 158330; opaque pixels 67974; edge leak 0. Both official native gates exit 0. Cold re-run yields byte identical Ground/PAR/QA. Negative 1px width, 1px alpha border, and forged SHA exit 2 each. Visual quality does not meet ground3 reference: Ground is too procedural and PAR details insufficient. Tree foot semantic HOLD: isolated Ground stump was removed by keeping complete tree PAR; historic low-32px bark rule not met. No changes to sealed scripts/maps/collision. Quarantine any generated QA illustration with printed PASS as non-evidence. See [Stage6 research report](FS_R17_STAGE6_NATIVE_PAIR_TECH_PASS_ART_FAIL_20261029.md), [private Drive artifacts](https://drive.google.com/drive/folders/1Dbq20qw79F4VFF3ScnWTEWf67Ywxmv1v) and [V2 reproducible generator](../../tools/r17_direct_stage6/build_stage6_native_pair_v2.py).


## R17 Stage7｜2026-10-29 High Richness PAR Recovery

**Latest: new source-authored Ground + independent Stage5 PAR-source Alpha repaired and uniformly nearest downsized; tech candidate, Ground Art FAIL, PAR artistic/semantic HOLD, Formal Seal NO.** An actual Windows 544×416 Ground was recreated from procedural source code with a new seed and new pathways (no old Ground picture read). Existing Stage5 original **standalone transparent PAR image** was processed with alpha70..215 remap and uniform nearest resize 1448×1086→521×391, then placed at (11,12) on native 544×416 RGBA canvas. This was NOT master-first scene splitting, but original PAR is still one precomposed transparent image, not independently editable component sprites. Do not claim native full-detail 1× sprite source.

- Ground SHA256 62e1ed6ed604568096172511787cf4aeacde604dea7ed56d4e21c2f8e38db2eb; PAR SHA256 e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9; PAR alpha0 112766, full alpha255 108885, partial 4653 (review); alpha border leak 0.
- Both official R17 and strict native gate Exit 0, only TECH CANDIDATE. Cold reproducible source rebuild of Ground, PAR, Composite QA, Checker QA and Manifest all hashes match. 1px width, dirty alpha border and forged hash negative mutation exit2 each.
- Stage7 private 15-entry 4224399-byte ZIP CRC PASS SHA256 cf61454d94f4ea6ace558cb7a4da61091cd969a67e35fff5eb7592166659c1c9; Windows E:, mounted G:, and Drive downloaded bytes verified Ground/PAR/ZIP all match.
- **Art:** PAR visually much richer and closer to the user-supplied concept, containing two houses, big tree, fence, lanterns, signs and small floral props; Ground still algorithmically simplistic (FAIL), PAR per-object provenance/editability (HOLD), floor-flora and tree-foot semantics (HOLD), whole scene user Art (NOT APPROVED). No sealed game binary or collision work touched.
- [Drive Stage7](https://drive.google.com/drive/folders/1tFys5Al3zV0NxAYf7tpWJEM-eySC1Gji), [Stage7 research report](FS_R17_STAGE7_RICH_PAR_RECOVERY_SOURCE_FIRST_AUDIT_20261029.md), [reproducible script](../../tools/r17_direct_stage7/build_stage7_source_first_ground_clean_par.py).
- Next concentrate on a native high-detail Ground source and individual editable art source kit with same world scale. Avoid generated faux PASS infographics or reverse Master segmentation.


## R17 Stage8｜2026-10-29 Fresh Native Ground and PAR Group Separation

**Current formal status: TECH CANDIDATE / Ground ART FAIL / PAR per-object editability HOLD / FINAL SEAL NO.** Generated a new 544x416 RGB Ground raster directly from fresh original terrain-painting source code (never opened or patched any historical Ground image), alongside Stage7's 544x416 rich independent RGBA PAR. Current Ground SHA256 `7d3b6c3b96034043f33a70ca7c8970f9f9ecde1645af1045a41fcfaf3c4c8b1e`; PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. The Windows native Gate Exit 0 on actual Google Drive-synced images, with transparent PAR borders clean (partial alpha=4653). No art PASS or scene signoff.

A real initial QA bug was detected: recompositing from an in-memory partial-alpha Ground differed from the exported RGB Ground. Fixed by recomposing only the exported RGB Ground and unchanged RGBA PAR, then cold rebuild + byte-identical pixel check. A source-only independent PNG PAR was alpha-segmented into **four native movable alpha islands** (left big tree/fence, connected right houses/gardens, two lamp groups), and four groups recompose to source PAR with zero RGBA byte difference. **Not the original per-object editable source sprite kit**. Do not claim full original art provenance or ground3 visual match.

Original `GROUND.png` and `PAR.png` synced to [Drive Stage8](https://drive.google.com/drive/folders/1rCE0mZi3wm_eFgs77VT3a-m2ZD8yV9JX). [Full current visual/technical report](FS_R17_STAGE8_NEW_GROUND_PAR_GROUP_ART_FAIL_20261029.md). The current conversation retains a **local sandbox** full reproducibility ZIP (new Ground source, PAR native image, semantic alpha groups, composite QA, audits); **do not assert that ZIP/source script was uploaded to Drive or GitHub**. No Map.rvdata/Scripts.rvdata/collision/K4 sealed changes. For the next phase, work on high-fidelity 1x source terrain materials and semantic per-object PAR kit without reverting to Master-first cutouts, while preserving strict art fail-closed acceptance.
