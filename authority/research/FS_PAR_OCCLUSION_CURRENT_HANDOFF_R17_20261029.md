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


## R17 Stage8 Remote Ground/PAR Group QA closure

Actual latest: **new 544×416 RGB Ground generated from new code, original rich Stage7 transparent RGBA PAR at matching 544×416**, Ground SHA256 `7d3b6c3b96034043f33a70ca7c8970f9f9ecde1645af1045a41fcfaf3c4c8b1e`; PAR `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. Windows desktop native Gate exit0, but **Ground ART FAIL, PAR source editability HOLD, PAIR visual HOLD, FINAL SEAL NO**. 4 independently movable connected-alpha PAR GROUPS created on Windows and reassembled to original PAR with byte-exact RGBA equality. These are not individual artist-created sprites. [Drive Stage8](https://drive.google.com/drive/folders/1rCE0mZi3wm_eFgs77VT3a-m2ZD8yV9JX), [Drive Windows tech delivery ZIP](https://drive.google.com/file/d/1L1GIuS_5JAXbmJWxOmyiqbmdHMr9tHdr/view), [Stage8 GitHub report](FS_R17_STAGE8_NEW_GROUND_PAR_GROUP_ART_FAIL_20261029.md). Original procedural generator/full cold reproduction ZIP only in current conversation sandbox, not fully cloud-synced. One real QA issue: in-memory partially transparent Ground vs exported RGB Ground mismatch resolved by recomposing from actual file; cross-platform PNG encoder SHA mismatch resolved using raw RGB pixel SHA `df667b4fabcbda6a78e8e6f3ad771a77574f7753e871c37a86530a2a5719f704`. K4/Map/Scripts/Collision remain untouched. Next: high-fidelity original Ground materials and finer artist-authored PAR source assets before art seal.


## R17 Stage9｜2026-10-29 New Original Tileset Ground Art Gate

Latest native-source material experiment: **TECH CANDIDATE / GROUND ART FAIL / PAR SOURCE HOLD / FORMAL SEAL NO**. Windows original 32x32 `grass_tile.png`, `path_tile.png`, `legacy_tileD.png` assets were used to compose TWO brand-new 544x416 Ground A/B images directly from source tiles; no old Ground bitmap or completed Master was read. Initial sprite extraction accidentally included small dark boxes, caught by visual inspection, then excluded by stricter green/dark/brown filtering. Final B has 68 micro-flora source placements, nominal max 16x13px, and 96 irregular paver shapes. Ground contains no cut-off tree trunk, whole PAR rich art retained from Stage7/8.

- GROUND_B SHA256 `60574419ce812dbc7a009b8b5b4dcbe2c0c3419c1d260b5dfeaed02df276924c`; unchanged PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. Valid native 544x416 RGB Ground + RGBA PAR; actual QA composite from final rasters RGB 0px diff.
- Official source and strict image Gate both exit0 (technical only); isolated cold rebuild of Ground/Par/composite/B exact SHA pass; 3 negative mutations (off-by-one width, dirty alpha border, forged source manifest SHA) exit2 each.
- Private ZIP 3,919,487 bytes, 19 files CRC PASS SHA256 `646066a3cb2f023583e338bd8f4f4a1c33d645d41c681e331ba6b6430b7408f2`. Windows E:/mounted G: hashes match for Ground/Par/ZIP; Drive ZIP downloaded and CRC checked.
- **Art FAIL persists**: tile-based grass and paving repetitive and low-detail against high-fidelity precomposed PAR reference; flora still too uniformly distributed. 16x13 size limit does not make a natural village. PAR editability, floor-flora semantics, historic tree-base tile ownership still HOLD. No art seal, no sealed scripts/Map/collision changes.
- [Stage9 private full delivery](https://drive.google.com/drive/folders/1ypX94pDQh4CmDJ5pkAhuGQHziGVXIOl7); [Stage9 research report](FS_R17_STAGE9_SOURCE_TILES_GROUND_ART_FAIL_20261029.md); [V2 generator](../../tools/r17_direct_stage9/build_stage9_source_material_ground_v2.py); [cold testing](../../tools/r17_direct_stage9/package_and_validate_stage9.py).
- Next phase should stop wasting cycles tuning procedural grass/pebble counts. Obtain/create a coherent ORIGINAL high-fidelity artist-grade Ground material family with independently authored rich PAR sprites before new production gate.


## R17 Stage10 | 2026-10-30 Ground Material Source Art V2

**Actual new source-first Ground / retained rich independent PAR / machine TECH CANDIDATE / art & semantics HOLD / FORMAL SEAL NO.** Stage10 stopped augmenting Stage9 Ground, instead created **two entire new 544×416 Ground** from original grass/path Tile textures plus native Voronoi graded stone paving and hand-authored small flora, maximum 16×12px; no old Ground image or pre-baked Master read. Stage10 B has 114 small floral clusters vs A 68. Clean native RGB Ground includes NO stray tree stump, houses, raised shrubs, fence or roof. Existing Stage7 rich transparent PAR unchanged (two houses/tree/lanterns/fences); independent from original baked Master but historically resized and precomposed, **not complete per-object editable 1x source**.

- Source Ground SHA256 `87dcaf0f5adcc8e3989e68936af58bec0721c0f66caf9b5fda499f1fb8edd90d`; existing PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. PAR Alpha0 112766 / fully opaque 108885 / partial 4653; all border alpha nonzero 0. Pixel-perfect native 544x416 canvas, 0 pixel composite mismatch.
- Native Stage5 strict Gate exit0; cold source-only rebuild all 8 source-derived output SHAs equal. Off-by-one canvas, bad 1px alpha border and forged source hash negative checks each exit2. Actual Windows connected DESKTOP-90VT437 independently unzipped cloud artifact and reran strict Gate exit0; Ground/Par SHA same as sandbox reference. Note that full cold material source rebuild was performed in local container (cv2/scipy), **not** Windows.
- Private final ZIP 4,479,886 bytes / 18 entries / CRC PASS / SHA256 `71c66cba9153417cf02577e83d1cf453be982f06f9075502ac6a1d406de22cb2`; [Drive folder](https://drive.google.com/drive/folders/1K2Uhq9PvVwsPnjsxeDezaXfYtIkMMad0), [Drive FINAL ZIP](https://drive.google.com/file/d/1snWFqTrRGEw3vU_U-N9B5G_PR4HUeht-/view), [Stage10 report](FS_R17_STAGE10_ORIGINAL_COBBLE_GROUND_SOURCE_ART_HOLD_20261030.md), [generator](../../tools/r17_direct_stage10/build_stage10_ground_v2.py), [audit](../../tools/r17_direct_stage10/validate_package_stage10.py).
- Human visual: Ground road has more credible individually shaded pavers, but grass and landscaping still do not meet ground3 reference art; hold Ground ART, Pair Art, PAR original per-object source, root ground-bark 32px semantics and attached ground flora semantics. **Never promote to final seal without art.** A model-generated fake PASS gallery was again discarded and never used as source or evidence.
- No K4, Map.rvdata, Scripts.rvdata, collision or user passability edits. Next: artist-grade Ground original source family that matches rich PAR detail, plus original editable PAR object source kit; avoid repetitive formulaic pebble/grass variation loops.


## R17 Stage11｜2026-10-30 Actual New Ground Variants C/D/E

- Latest work **TECH CANDIDATE / GROUND ART FAIL / PAR SOURCE HOLD / PAIR VISUAL FAIL / FORMAL SEAL NO**. Three completely new original 544×416 Ground images (C warm, D moss, E olive) generated from code-authored palette/material/stones/flat flowers. Old Ground images NOT used as inputs; Ground contains no elevated artwork or isolated tree trunk.
- Preferred technical test E Ground SHA256 `5e236976f718f2aec065ad11b12ed4de20b66d0120f44c2a21f0450ad3edceec`; unchanged high-fidelity standalone precomposed PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. Both native 544×416, RGB Ground + true-alpha RGBA PAR. PAR alpha0=112766, alpha255=108885, partial=4653, no canvas edge leaks. Ground/Par composite QA recompiled from final PNGs pixel-perfect.
- Source-only cold regeneration Ground C/D/E, preferred Ground, PAR and QA has exact SHA matches. One-pixel mismatch and alpha border pollution negative checks rejected, and fabricated source checksum rejected.
- Final in-chat private reproducibility ZIP: 4586215 bytes, 16 items, SHA256 `35c827e4c7f0cce804cde45f6548abb9ba5ed18f143c0bc0406e64a0d9266441`. ZIP downloadable in conversation, **not confirmed uploaded to Drive**.
- Drive private verified Ground/Par/QA [Stage11 folder](https://drive.google.com/drive/folders/1PFMDeEYdzxjLY0OfG3Lir7JR13HkFNJx); [full Stage11 authority and failure analysis](FS_R17_STAGE11_FRESH_GROUND_THREE_VARIANTS_ART_FAIL_20261030.md).
- Independent visual **FAIL**: Ground grass still mottled and painterly/structured fine detail well below current PAR, despite color/stone experiments. Keep clear gap, do not hide under 0-pixel composite diff. House proportion vs Ground low flora is now reasonable; individual flower-cluster bounding boxes max13×9px. Historical tree-root bark 32×32 ownership still HOLD (full tree PAR; Ground only root shadow).
- Imagegen generated another pre-labeled PASS QA panel rather than a true editable source, **quarantined** and never promoted to technical evidence. Do not repeat this failure as a real test.
- **Next** invest in a true original artist-grade ground material kit and individual original PAR sprite sources; STOP repeating procedural grass/stone parameter tweaking. Never touch sealed FS/K4, Map.rvdata, Scripts.rvdata or user's collision/passability.



## R17 Stage12｜2026-10-30 Artist Source Quilt Ground C

**CURRENT: GROUND/PAR 544x416 TECH PASS, Ground artisanal C candidate (HUMAN HOLD), PAR SOURCE-EDITABILITY HOLD, TREE-CONTACT SEMANTIC HOLD, FORMAL SEAL NO.** Actual new Ground was created in Windows Python from original hand-painted `A2_VSCliff.png` art atlas + old 32px `grass_tile.png` source and quilted stone/grass patches; NO previous Ground image or completed Master was opened. This is the first test moving beyond trivial random grass/pebble parameter tuning.

- Three variants: A soft source art but bland; B rich tall-grass source wrongly appears as huge GROUND vegetation (VISUAL FAIL); C combines 86% source flat grass +14% artist green microtexture, with beige hand-painted stone patch quilting and tiny 6x6px flowers. C is **candidate only**, not art-approved ground3 richness.
- A new cubic-Bezier bug was caught visually: the original formula omitted the `t` multiplier on control point `b`, resulting in disconnected paths. Fixed before candidate C export and preserved in failure record.
- Real Ground SHA256 `1e3e97fc1ec9288f78eabd42c351b694f5aa55e8123bd1e8d7a8acf556911363`; unchanged true RGBA PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`. Native 544x416; actual ground+par composite 0 RGB diff. Official source + strict native alpha gates exit0, **technical only**.
- Isolated recompile from source 3 images + generator reproduces 7 expected PNGs byte-identically. Three negative mutations (width -1px, dirty-alpha border 1px, forged Ground source SHA) each exit2.
- Private ZIP 5,685,497 bytes/21 entries CRC PASS SHA `9f8cb4d5eda0814015dacef9861a353568ae9212934524d8f0d5821e4210e93e`; Windows E:/G: and Google Drive re-downloaded Ground/PAR/ZIP SHA equal.
- [Drive Stage12](https://drive.google.com/drive/folders/1c6w2ffUrA_jA349VlUXpYZkXm13twx4g) | [GitHub detailed audit](FS_R17_STAGE12_SOURCE_QUILT_ART_CANDIDATE_20261030.md) | [reproducible candidate source](../../tools/r17_direct_stage12/build_stage12_a2_quilt_v2.py) | [testing source](../../tools/r17_direct_stage12/validate_and_package_stage12.py).
- **Art is not signed off:** Ground's paved roads are visibly better, but flora distribution and detail still below ground3. Stage7 transparent PAR still one precomposed source, not native 1x editable per object, and includes grounding/flowerbed semantics requiring acceptance. Latest Ground contains no isolated tree bark; original lowest-32px contact expectation remains open. No sealed FS binary, Map.rvdata, Scripts.rvdata, collision or passability changes.
- Next work: judge C at 1x; develop true high-fidelity low-plant clusters and independent PAR sources. Do not repeat a faux `PASS` ImageGen QA board, and do not attribute formal pass to machine-only SHA equality.
