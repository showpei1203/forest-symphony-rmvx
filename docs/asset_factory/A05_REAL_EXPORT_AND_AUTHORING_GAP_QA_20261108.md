# FS Asset Factory A05 actual-source QA | 2026-11-08

Source: isolated private Drive archives; NO artwork/XML/ZIP binaries committed publicly.

## Direct execution of the exact committed A04 exporter over real native PMD ZIPs
- Git blob verified from extracted local code: `pmd.py` = `a97778e8c886b839d5dd9a4993e9dabf4177b739`; `native_action_export.py` = `dd7d5b71b5f96a35fb2d76c09a94d96f8e3cb92b`.
- Actual private source ZIPs previously pinned in [A02 source inventory](SOURCE_INVENTORY_A02_20261107.md).
- For each of PMD0001 original_0001 / rock_0001, PMD0002 ORIGINAL_0002 / VOLCANIC_0002, PMD0003 ORIGINAL_0003 / VOLCANIC_0003, use REAL XML + all native action PNG data and exact file SHA256.
- Invoke the actual GitHub `compile_native_action` over Idle and Walk for one explicitly indexed row, using source-derived existing Anim/Offsets/Shadow frames. Results: **12/12 no-op native atlas recompilations PASS**. All three decoded RGBA sheets are pixel-exact to source, every untouched direction row remains unchanged. XML dimensions: 0001 Idle 32×40×3, Walk 40×40×6; 0002/0003 Idle/Walk 32×32×4; all these actions are eight-row native sheets.
- One deliberately invalid pixel-level mutation in PMD0001 original Walk row 3 frame 0 changed exactly one RGB channel in the selected Anim frame; all seven other rows pixel-exact, test PASS. This mutation is a TECH negative control, **NOT an artwork deliverable**.
- This is stronger than A04's separately implemented 12/12 crop/paste roundtrip: it is direct execution of committed exporter over actual private files. But still NO new user-approved lava variant or complete eight-direction animation art, and no native Game.exe.

## Master-first V3 full AuthoringPAR vs four-object Runtime PAR coverage gap
Whole real private ZIP frozen source: `FS_MASTERFIRST_V3_NATIVE_GROUND_PAR_COLLISION_QA_20261107.zip` SHA `b38c08109e25299fa9f4ceabd7f34b42cc82531ba56c8f09cc9f3a4af0429511`.
- Full Master 1280×928 SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`.
- Authoring CompletePAR RGB-from-Master draft SHA `b9935121ef816fb4c79c958c839167b1e9fb9917f120efe0d5bd42c76a9e5d74`.
- Runtime four-object PAR SHA `e2486f7a780d260ccfceadac024b94ee37108371c91c7a73f2cf254463c76edb`.
- Authoring nonzero-alpha **864,528**; four-object Runtime nonzero-alpha **118,425**, entirely contained in Authoring. Difference **746,103 Authoring-only alpha pixels** across **1,049 / 1,160** 32px tiles; **476,566** of those pixels lie in tiles flagged walkable by the V3 DRAFT collision grid.
- These 746,103 pixels are **NOT 'missing runtime occlusion'**. Authoring PAR includes items that intentionally belong behind an actor and other non-runtime elements. The metric only shows that four object-specific masks do not establish object-provenance for the entire Authoring PAR.
- Added `tools/asset_factory/adapters/authoring_coverage.py`: fail-closed source-master RGB registration, runtime alpha subset of Authoring, optional binary collision grid geometry and Authoring-only hotspot enumeration. Added 8 synthetic positive/negative fixtures in `test_a05_authoring_coverage.py`. Combined CI **57/57 PASS** run [42416671913](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42416671913), source commit `c04cb60ef1c36cd0feb1be1b0619e05e58a5c97b`. Any later documentation commits require newest HEAD revalidation.
- The real 864,528/118,425 gap was measured by independent actual-data Python in isolated runtime. Do NOT claim newly committed coverage module was directly run over private ZIP unless separately verified.

## Native legal-footpoint STATIC prefilter, not an engine result
The real V3 four masks plus DRAFT 29×40 collision grid show some pixels at tiles marked draft-walkable:
- LEFT_HOUSE_ROOF: 6 draft-walkable tiles intersect source mask, 4 intersect an *assumed* 25×32 actor image centered on tile. Top potential tile x/y: (5,4), (13,6), (7,6).
- RIGHT_HOUSE_ROOF: 9 draft-walkable tiles intersect source mask, 9 assumed actor overlaps. Top (25,6), (30,4), (29,4).
- LEFT_TREE_CANOPY: 49 draft-walkable tiles intersect mask; 48 assumed actor overlaps.
- LOWER_RIGHT_TREE_CANOPY: 57 draft-walkable tiles intersect mask; 56 assumed actor overlaps (its genuine source extends beyond bottom-right canvas edge).
These are only static image-box candidate coordinates. Actual actor footpoint/footprint, world depth, Game.exe's legal movement, switch203, camera/pose and art are NOT TESTED. Do not promote roof candidate because V3's original legal actor roof tests were ENGINE_ONLY / blocked. They are an exact shortlist for future independent adversarial review.

## A05 deliberate QA failure and correction
Initial isolated static footprint probe mistakenly converted source **L-mode grayscale masks to RGBA and then took the opaque alpha channel**, which treated all pixels as filled. It produced a nonsensical 790 walkable mask-intersection count for each of the four objects. **Discarded as INVALID**. Correct reading is L intensity for L masks and alpha channel for RGBA. Re-ran and obtained the counts above. Future regressions must include one L-mode mask negative fixture to prevent the error.

## Orca status and source exception
- Connected Orca environment is online and historical R4 dual-agent reviews exist. Current Orca Agent permission mode still cannot be safely established as approval-required; no new S1/M1 write-capable agents launched or local worktrees created. The two A04 adversarial task specifications remain [here](ORCA_A04_TASKBOARD_20261108.md).
- A26 approved new lava Idle/Walk private ZIP `A26_PMD_TWO_ACTIONS_FS_RATIO_PRIVATE.zip` (historical recorded SHA `460b8ca230e579e78d2f3350f0f10c0ba0ab5af2fbaee063faf3bdb3baee1399`) remains **SOURCE_NOT_VERIFIED** after targeted Drive search and historical PC path read-only check. Do not substitute old original PMD atlas.
- No PixelLab credit use, no user's-PC new work product, no main overwrite. User ART new asset PENDING, native VX this iteration NOT_RUN, formal seal NO.
