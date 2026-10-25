# FS v2.8 G1C Road Mask Topology — FAIL

Date: 2026-10-25. G1B Ground image unchanged (source crop SHA256 `1c6cfc72368b4f2d7ffff9f21d56192aa91eb30244ac641e9baac881c50be053`).

Automatic road mask checks: 544x416, 123150 pixels classified as road (54.418% of image), 459 distinct 4-neighbor components, largest component 112170 pixels or 91.084% of mask, 354 components smaller than 16 pixels. This means the **automatic color-based road segmentation is unreliable**, not that the drawn path is necessarily physically disconnected. `ROAD_MASK_FAIL`; never use this mask as passability/collision authority.

G1/G2 source and visual review still PENDING. No object/PAR or VX build ran. Keep negative witness. Required correction: semantic road geometry Blueprint and reviewed entrances, then formal path/collision compilation and live VX testing. Formal FS sealed and v2.1/v2.2/v2.3.3 untouched.

Independent CLI and before/after overlay in private conversation deliverable ZIP, SHA256 `b935d7a79a9ce596131b9764a4a49eb87673c66d37a8de494b06826a7bbea928`. This is a research/review artifact, not approved game Ground.