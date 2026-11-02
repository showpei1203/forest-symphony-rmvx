**SUPERSEDED FOR ACTIVE MAP DEVELOPMENT: A36D R2**. Follow [A36D latest Handoff](CURRENT_HANDOFF_STAGE16_A36D_20261102.md). A36C remains read-only baseline for 222-tree dense forest, not the current visual art candidate.

# Forest Symphony | Stage16 A36C Dense Forest Handoff | 2026-11-02

**LATEST MAP BRANCH: A36C DENSE FLAT FOREST, ENGINE TEST PASS, ART NOT SEALED.**
The user's latest visual direction is **a screen full of interlocking forest canopy**, with roads and small village clearings cut through the forest. Keep original FS and all A35/A36/A36B sources immutable.

## Canonical user references (must read first)
- Reference root `00_Reference_Original`: https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- Map reference `01_Maps_Parallax`: https://drive.google.com/drive/folders/18PuuvYK1ClurHzLeKLG6yXZqKXDLa_tS
- Trees: https://drive.google.com/drive/folders/1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw
- Full Maps: https://drive.google.com/drive/folders/1dzRwlr3Npz9zr-uX3fnE0bM-HaDGicqe
- Buildings: https://drive.google.com/drive/folders/1_1fCD0jLwISt1SApxKwbNF3zIVMOyYlW
- Permanent authority: `authority/FS_CANONICAL_DRIVE_ART_REFERENCES_A36C_20261102.md`.
- Previously imported legitimate user reference `Trees1.png` exists in `E:\FS_ROUTE_B_STAGE16_A27_PIXELLAB_GROUND_FULL_TREE_20261101\SOURCE_DRIVE\Trees1.png`. New tree sprites were assembled from A34's 104 independently verified existing forest sources, **not falsely claimed to be new PixelLab generations**.

## Source locations
- A36C working path: `E:\FS_STAGE16_A36C_DENSE_FOREST_20261102`.
- A36C isolated actual VX native: `E:\FS_STAGE16_A36C_DENSE_FOREST_VX_NATIVE_20261102`.
- A36C separate native VX cold copy: `E:\FS_STAGE16_A36C_DENSE_FOREST_VX_COLD_20261102`.
- A36C Godot project: `E:\FS_STAGE16_A36C_DENSE_FOREST_20261102\GODOT_A36C_DENSE_FOREST_40x29`.
- Baseline B (read only): `E:\FS_STAGE16_A36B_FOREST_VILLAGE_VISUAL_20261102`.
- Main local assets: `A36C_FLAT_FOREST_GROUND_1280x928.png`, `A36C_DENSE_FOREST_PAR50_RGBA_1280x928.png`, `A36C_TRUE_GROUND_PLUS_PAR_1280x928.png`, `A36C_SCENE_MANIFEST.json` and `SOURCE_INDEPENDENT_RGBA/`.
- Actual A36B vs A36C composite side-by-side: `A36B_VS_A36C_ACTUAL_GROUND_PAR_BEFORE_AFTER.png`. This is real pixel composite, not an AI concept rendering.

## Specific A36C measured improvements
- Canvas **1280x928 (40×29 @ 32px)**, flat only; no cliffs/height/tunnel.
- Baseline A36B **54 trees** -> A36C **222 trees** (168 new tree placements, using pre-existing A34 alpha sprite source variants).
- Original 60 shrubs + **70 new understory shrubs** = **130 shrubs**. Two original A36B houses, four landmarks, for **358 distinct placed independent RGBA objects**.
- Visible tree-canopy alpha union (@ alpha >=100) rises **19.788% -> 51.290%**, an objective spatial measure, **not a user-approved numerical aesthetic gate**.
- **246 blocked root/house cells; 914 of 914 open tiles connected**, 306 explicitly reserved protected path/door grid tiles; walking corridors persist even though crowns overhang. All independent tree sprite PNGs are whole and fully inside scene geometry.
- No PixelLab credits spent; source-driven layout, natural cluster samples, stable foot-y ordering. Existing house designs unchanged, and **the two duplicated cottage appearances remain a known art limitation**.

## Actual native engine and evidence
- `A36C_VX_NATIVE_11_CASES_SCREEN_QA.json`: **11 actual RPG Maker VX map positions / 22 RGSS Player 544×416 screenshots**, map 50 entered, **358 alpha resources loaded**, **0 RGSS modal dialogs**.
- Real new A36C tree-root collision test: attempted down move **(11,11) -> (11,12)**; native player stays **(11,11)**.
- Real traversable road move: **(11,8) -> (12,8)** succeeds.
- `A36C_GODOT_GPU_PIXEL_QA.json`: Godot 4.7.2 AMD RX6700XT native **6 full-sized 1280×928** rendered images plus **6 actual 544×416 crop images**. Static source vs real GPU has **max RGB per-channel delta=1; 0 pixels >1**.
- `A36C_NATIVE_VX_COLD_REBUILD_QA.json`: separate clone **3777/3777 files byte-identical SHA256**, independent RGSS window enters Map050, **358 objects loaded**, captured new native 544×416 screenshot, **0 RGSS modal errors**.
- Gate summary: `A36C_STAGE_GATE_QA.json`, engine_pass=true, **Formal Seal=NO**.

## Failed assumptions and safeguards
- Increasing tree count without footprint and road protection risks blocking the network: tree candidates were rejected if they block reserved path tiles, collide with front-of-house safe areas, or disconnect any walkable tile. Random seed is fixed and checks fail closed.
- Tree-crown overlap is expected, but actor-occlusion visuals **still require actual human review at many forest positions**, beyond these representative 11 cases.
- Stable sprite tie sorting by **(foot_y,id)** is mandatory, inherited from A36B's fixed A36B overlap bug.
- Do not equate native engine PASS with final art acceptance. The current map is denser and demonstrably more forest-like, but tree variety, architectural variety, forest/house integration and understory are still visually imperfect.
- Original FS ground3/par3 vs ground8/par8 pairing authority retained. **Terrain PAR/cliff height and parallax stairs still DEFERRED**, pending original source-level and RGSS audit, not part of this flat forest branch.

## NEXT A36D (visual refinement)
1. Before drawing new assets, review canonical Drive `Trees`, `Full_Map_References`, `Buildings`, `Plants`, `Props` and reuse verified native originals to enrich species, trunks, forest edge, low shrubs, flowers and path-side details.
2. Replace the visibly cloned second cottage with a genuinely different FS-style building asset, but don't compromise pixel-art consistency or actual independent alpha isolation.
3. Inspect nine-case VX montage: validate actor/canopy occlusion around entrance and narrow forest paths, ensure readability and passability without reducing overall canopy.
4. Consider natural dense tree belts above, near south village entrance and around outer edges to reduce broad open-lawn impression, not a blind density percentage chase.
5. Repeat actual paired Ground+PAR compilation, 11+ native VX frames, GPU pixel QA, independent cold SHA, complete before/after, Failure Log and Handoff.
6. ART VISUAL ACCEPTANCE pending user review; do not call A36C final or sealed.

## Execution sequence in A36C folder
- New candidate generation (source safety): `a36c_build_dense_forest.py`
- Isolated native VX: `a36c_build_native_vx.py`
- Prepare and capture 11 cases: `a36c_prepare_capture.py` then `a36c_capture_native_11_scenes.py`
- Godot source assembly: `a36c_build_godot.py`
- True Godot GPU: Godot 4.7.2 console `--path GODOT_A36C_DENSE_FOREST_40x29 --script res://a36c_godot_full_native_render.gd`
- Godot RGB inspection: `a36c_validate_godot.py`
- Cold clone and native screenshot: `a36c_native_cold_verify.py`
- All-gate actual QA and montage: `a36c_finalize_stage_gate.py`
- Full source package and SHA/CRC independent extract: `a36c_package_private.py`

The builder refuses to overwrite an already produced candidate; to reproduce, clone baseline into a **new** stage directory rather than deleting the validated A36C.


## Verified A36C Google Drive source and visual evidence (post-packaging, 2026-11-02)
These links were read back from the actual connected Google Drive folder after remote sync; no URL has been guessed.
- **Drive A36C stage folder:** https://drive.google.com/drive/folders/1y4L8cHwF2gd49SlCZHbrEpF1-p3sWNMt
- **Full private ZIP 53,016,955 bytes / 431 members:** https://drive.google.com/file/d/1tNx5FtiSfPjk-evYC9LVu_Y48VfCSCP3/view
- **Actual A36B vs A36C full Ground+PAR before/after:** https://drive.google.com/file/d/1builvGSnCMVIEnArbjoKXw8m9LKBmy9S/view
- **A36C full 1280x928 Ground+PAR:** https://drive.google.com/file/d/1UbU_R1vVNKEpAhKt6LS9-bLa6_riPf67/view
- **Actual RPG Maker VX nine-region montage:** https://drive.google.com/file/d/1h9YiVzJXMhvp-dFfvKdmgoM0I5cr21Ij/view
- **A36C Ground only:** https://drive.google.com/file/d/1H8UbMW1Qk9pvHqzCiKE7nS9G6A4lA-aB/view
- **A36C transparent PAR only:** https://drive.google.com/file/d/1oJqY0YQ_MGvKqWkCJDnLT44cGv6w2PL0/view
- **Canopy alpha mask:** https://drive.google.com/file/d/1EZeGvLp2ZJJz1__aOOqPtDiHM4MsQbUq/view
- **Cold VX QA:** https://drive.google.com/file/d/1KuaVr5J-QgyLH8S2z1lMm2mG9tsChxRz/view
- **Stage gate QA:** https://drive.google.com/file/d/158buJS2Hn6uT_Zt-y_rsfCj8ZW8J9IP0/view
- **Archive CRC/SHA/extract QA:** https://drive.google.com/file/d/1Adm5qBldU460_371spvBjS_Ct5bdOnkI/view

Local archive SHA256: `c2b9caa44541c0295fea6bbf6099dff2de37e77e10808b69be0a96a64d695d36`. Google Drive lists matching uploaded ZIP byte size, but the synced cloud object's downloaded bytes have **not** been independently rehashed. Engine PASS, art still PENDING, Formal Seal NO.
