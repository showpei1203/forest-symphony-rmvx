# FS T-C D24｜2026-11-26｜美術優先、真透明非地表原圖完整工廠與 ART HOLD

**15 檔真私人圖片／生成來源／SHA／A/B完整圖／冷重建工廠與 Failure Log ZIP**：[Google Drive (19,400,566 bytes; CRC PASS)](https://drive.google.com/file/d/1lFPX6IV0lJ6dNmQte1ocRHFlyPBtmMoC/view)，SHA256 `0383e4f1cad3fdac2497036e6b4dd1b04c117b7024b386635645162b8e55288c`；owner-only Drive metadata `shared=false`。

**真正新來源**：[獨立 RGBA 原圖 1474×1067](https://drive.google.com/file/d/1Ao4UargsAT-mzPTds326aRifdctQOUuO/view)；[鎖定 D17 原 Ground 1280×928](https://drive.google.com/file/d/1UXoCasoLz4mSed115uSjlbEvIVgT-MbI/view)；[D24-B 全非地表 PAR 1280×928](https://drive.google.com/file/d/19gBWUYg0xckbJ6oC-dBVw1oMyu6VNvez/view)；[靜態合成全圖](https://drive.google.com/file/d/1f2JY59NGr2n58qzu3Ddkt2vS4Xajor9p/view)；[A/B 全圖](https://drive.google.com/file/d/12sc18GxFZRNcq4DUkJWvVL3HmRurAJEK/view)；[橋頭 A/B QA](https://drive.google.com/file/d/1N9Y83pNaj4duak5omG6_rq_-V6dWODyT/view)；[D23 真 Godot Native vs D24 STATIC 的明確標註比較](https://drive.google.com/file/d/1NXsxnmhk2pAK3lr0LLnip9c3ENior8e1/view)；[真數據 QA](https://drive.google.com/file/d/1AzXgLi6wh7bJha8euIAAJXacuIiZ49K8/view)。

**避免過度宣稱：**D24 **Godot 原生真圖 NOT RUN**，D23 Native PASS 不算新圖通過。D24 B 靜態來源／alpha／1×配對／冷重建 TECH PASS，但長達388px的橋梁仍約 12 格、實際裂谷更窄，建築比例及整張 32px Style DNA **Human ART HOLD**，正式十二圖 **0/12**。沒有覆蓋 D17／D22／D23 圖、沒有改動 Windows E: 或 T-A/T-B。以下是完整本地來源 QA／失敗交接正文。

---

# Forest Symphony | T-C D24 ART-FIRST | FS_04_MAZE | 2026-11-26

## Scope and authority
- **Goal:** improve one whole map's independent Ground + every non-ground CompletePAR artwork; not extend D21 physics, actor depth, scripts, collision or saves.
- Art direction authority: latest ART-FIRST SOP and T-C CURRENT_HANDOFF. Approved scene world: 40×29 grid at 32px = 1280×928. Godot target: 4.7.2. Formal ART PASS remains **0/12**.
- User's standing Ground-first contract: **Ground-only FIRST; freeze SHA; independently generate ALL non-ground in transparent PAR; Composite is QA only**, no reverse-cutting a mixed Master.
- The only locked Ground is unchanged D17 `1280×928 RGB` SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`.

## Real new independent art
- New image generation was an **independent all-non-ground original `1474×1067 RGBA`**, not the RGB-checker fallback used by D23. Source SHA256 `69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407` and **1,149,019 genuine alpha=0** pixels. A full original PNG is retained unchanged.
- It contains **eleven** major complete pixel-art islands: full forge, ore crane depot, whole arched iron bridge, three lanterns, three basalt formations, smaller supply workshop, crimson banner. All **376,213 source pixels with alpha>32** belong to the eleven retained components. There is **no mixed map Master**, no object mask based on actor occlusion and no Ground extraction.
- The source is **NOT directly generated as 1280×928**. Native output comes from complete bounding boxes re-laid at their unchanged **1× original pixel size**, without image interpolation or polygon trimming. Only very low source alpha (<=8) is cleaned in the derived PAR. Important distinction: this is valid structural re-layout, **not** original whole-world-coordinate direct authoring.
- Genuine output `1280×928 RGBA CompletePAR` B: SHA256 `a5c657c8e38150f5300874283124970ba0b089eed52c2dc763bd646d6330e51b`, alpha=0 **806,922** pixels, **0** inter-object overlap pixels, outermost 5px high-alpha objects **0**. Source significant alpha>32 entirely accounted for; a small amount of low-alpha fringe/background noise is omitted by crop.
- Real Pillow separate Ground+PAR static composite B SHA256 `604d9db4ec8926257831cf2839e4cfb1ef5a19319bea2771afb26f4f81a43fab`.
- Fresh isolated cold rebuild generated **exactly the same QA JSON and A/B PAR/Composite PNG SHAs**. `build_d24.py` is source-locked and has all world placements reproducible.

## Whole-frame ART QA and documented failure reasons
- Two world layouts (A, B) were rendered and viewed at full 1×; both have 0 overlap and no high-alpha object clipped at the 5px border. The selected **B** positions the 388px bridge to the right (`target_xy=(853,406)`) instead of the old A `target_xy=(778,406)`; its right landing is visibly closer to the land on the opposite bank. The original source bridge itself remains whole, with no scale. 24px color sampling under approximate bridge tower feet shows mostly non-bright-lava, but is **not** sufficient for formal geometric/walkability approval.
- **Critical art blocker remains:** the image generator again made the bridge about **388px (~12 tiles) wide**, although the actual lava channel is much narrower. This is a coherent-style improvement, not the requested **5–6 tile bridge**. Structural success is not proportional/semantic ART success.
- Forge is still relatively large (~495px wide, 15.5 tiles) compared with corridor/field; light/shadow palette aligns better with the Ground than a white-key RGB plate, but original A35/A36 Style DNA human review is not completed.
- The source does contain some minor red/orange fringe in antialiasing. Unlike D22/D23, this candidate does **not** apply background color-key removal; fringe removal or native-authoring must be independently evaluated.
- Generated source lacks direct frozen world coordinate authoring. Eleven intact objects in a consistent style may still have imperfect footpoints. No claim of direct native world alignment.

## Gate by actual evidence
| Gate | State | Evidence |
|---|---|---|
| D17 Ground SHA/mode/size unchanged | PASS | SHA locked, RGB 1280×928 |
| New independently authored non-ground source actually carries alpha=0 | PASS | RGBA 1474×1067, source SHA, 1,149,019 zeros |
| 11 significant whole objects preserved at 1× | PASS | Source alpha>32 376,213 all accounted for, no polygon trimming |
| D24-B PAR 1280×928 original-size construction + cold rebuild | PASS | B PAR SHA and cold SHA identical |
| Ground+PAR static compositing | PASS | B Composite SHA and cold SHA identical |
| **Real private D24 Godot 4.7.2 native** | **NOT RUN** | Prior D23 engine success does **not** automatically certify D24 |
| Bridge proportion, natural bank landing, overall scene style | **ART HOLD** | Full-scene 1× manual assessment, no owner approval |
| Gameplay/ACTOR01/collision/saves | NOT RUN | Outside T-C ART-FIRST |
| **Formal 12-map ART PASS** | **0/12** | No user approved complete visual map |

## Verified private Drive components
- New true-RGBA source: https://drive.google.com/file/d/1Ao4UargsAT-mzPTds326aRifdctQOUuO/view
- Frozen D17 Ground, content unchanged: https://drive.google.com/file/d/1UXoCasoLz4mSed115uSjlbEvIVgT-MbI/view
- D24-B complete PAR: https://drive.google.com/file/d/19gBWUYg0xckbJ6oC-dBVw1oMyu6VNvez/view
- D24-B static composite: https://drive.google.com/file/d/1f2JY59NGr2n58qzu3Ddkt2vS4Xajor9p/view
- D24 two full layouts: https://drive.google.com/file/d/12sc18GxFZRNcq4DUkJWvVL3HmRurAJEK/view
- D24 bridge detail A/B (only QA): https://drive.google.com/file/d/1N9Y83pNaj4duak5omG6_rq_-V6dWODyT/view
- D23 **native** versus D24 **static** full-scene visual comparison: https://drive.google.com/file/d/1NXsxnmhk2pAK3lr0LLnip9c3ENior8e1/view
- Source/QA final JSON: https://drive.google.com/file/d/1AzXgLi6wh7bJha8euIAAJXacuIiZ49K8/view
- Rebuild Python: https://drive.google.com/file/d/1yYA3q2xWAA0OUHh6LA0sLbcTS-1uNqYj/view
- All source artworks and QA are owner-only on private Drive. Do not commit images to public GitHub. Original D17/D22/D23 sources preserved. No changes to T-A/T-B or user's Windows E:.

## Next **complete art** step (not a technical rabbit hole)
**Bridge is the remaining macro blocker.** Image generation repeatedly makes ~12-tile bridges for a ~3–4 tile lava gap. Either commission a complete **scene-native size, world-aligned all-non-ground PAR** with a 5–6 tile bridge, or author a new coherent Ground map with a crossing proportionate to the asset (Ground FIRST, PAR SECOND), while preserving all old candidates. The current D24 should go to owner as a **true-transparent technical and visual candidate** but remain ART HOLD, not be promoted as final. No more collision/actor z-index work in T-C.
