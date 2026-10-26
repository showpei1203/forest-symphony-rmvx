# FS V6 P3 R4｜Ground-Exclusive Object Production & Handoff (2026-10-27)

## Binding user rule
All ordinary horizontal terrain is Ground ONLY: independent grass/turf, paths, soil, sand, paving, and surface transitions cannot be copied into any external sprite or PAR. Only visibly physically attached moss, vines, roots and planter vegetation may extend from an object; Contact Shadow must remain independent. Formal Authority: authority/art/FS_GROUND_EXCLUSIVE_OWNERSHIP_RULE_V1_20261027.md. Previous R3 house remains invalid for final art.

## Actual progress, authorized Windows isolated construction
Workspace E:/GameAssetToolLab_20261023/MAP_TARGET_V6_20261027/P3_R4_GROUND_EXCLUSIVE_OBJECT. Existing actual 261×183 RGBA house source was inspected at 4× source pixels and compared with Ground B 544×416. Two new candidate architectural sources and a standalone barrel prop were produced, source-preserving RGBA:
- R3 original: 8589 known forbidden-ground alpha overlaps; rejected.
- R4A: excludes 7583 original background/ambiguous pixels but garden/soil remnants remain; rejected for ART.
- R4B conservative structure: excludes 9369 original source pixels, retains 18455 architectural candidate pixels. Explicit forbidden ground owner intersection=0; a deliberately injected forbidden terrain pixel causes immediate gate rejection. Still ART FAIL because original garden was interwoven with wall/flower roots, leaving ragged window/wall edges. Do not claim that semantic zero overlap or negative test independently proves the asset artistically correct.
- Two barrels extracted into independent transparent source (no inherited turf in barrel bitmap). Attached roof moss/ivy mask independently staged. Sacred tree trunk/root and soft flora remain human art candidate sources; flora came from prior GrabCut, NOT formal user acceptance.
- Single manifest derives ground, PAR_COMPLETE, pixel owner, real VX 1× actor 4 positions, and 17×13 collision. 15/221 tiles blocked, 1-tile doorfront walkable, soft bush walkable.

## Automated QA and releases
12/12 ground exclusion, old-source-rejection, 1px contaminated-ground negative, source RGBA preservation, barrel separation, single-manifest PAR, actor/foot collision checks PASS. Native Game.exe NOT RUN, Human Visual ART FAIL/PENDING.
Private ZIP: https://drive.google.com/file/d/1oywsEndzDXIDmpNThXVz18CuPUM3PD0i/view
11,405,659 bytes; SHA256 1863b339da4d65b6c2844faf005c1a68f35c99e6302b65e1c817437090a64ee4.
Cold unzip verified 58 source/output file SHA256 values and reran source builder, R4B cutter and scene compiler to identical final composite SHA256 900282d24db4ad92a8e7bf4e633aaeee67c8312b83d0a3e0a7867211a3a54a20.
Visual review with embedded source, 1× world, barrel and actor previews: https://docs.google.com/document/d/1JeNv_CVv4TMmHgM7ZvzAsCPzhepugwdsAau3vPmg91U/edit
GitHub runnable scripts: tools/fs_map_v6/build_ground_exclusive_house_r4.py, tools/fs_map_v6/build_ground_exclusive_house_r4b.py, tools/fs_map_v6/compile_ground_exclusive_objects_r4.py. No private PNG artwork committed to public repo.

## Defect catalog updates
FS-ART-109 Original house carried its own lawn/soil/flower turf. R3 formal source = FAIL. New source candidate tech extraction excludes known polygons; formal art STILL FAIL.
FS-ART-110 Attached-growth exception requires demonstrable connection to roof/wall/roots; cannot relabel source grass as house moss.
FS-ART-111 Self-certified semantic mask cannot substitute independent visual review; zero forbidden pixels pertains to explicitly assigned ownership polygons only.
FS-ART-113 House wall/flowerbed source entangled: masked R4B creates jagged/unfinished architectural contact; choose fresh inherently ground-free architectural source. R4B may serve geometry/testing only.

## Next actual construction
1. Obtain or generate one intrinsic ground-free complete building with clean roof/walls/doorstep and pixel-crisp original alpha; preserve proper roof moss/vines only as attached source. Use new Rule V1 negative terrain injection.
2. Repeat for standalone barrel/well/sign/fence/rock tree roots and shrub. Only after true art acceptance, place and configure collisions/occlusion and run native RPG Maker VX Game.exe. Continue target 1280×928 village scale without recycling the finite 544×416 Ground as repeated patterns.
No SEALED FS scripts, F1R1 A04, or another conversation's map candidates were edited.