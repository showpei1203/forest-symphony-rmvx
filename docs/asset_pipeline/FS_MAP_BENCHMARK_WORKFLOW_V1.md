# Forest Symphony Map Benchmark Workflow v1

- Project: Forest Symphony
- Benchmark: `FS_Map_Forest_Clearing_01`
- Related Linear: `SHO-39`

## 1. Goal

Prove that a NEW Forest Symphony map can be created from Map Style DNA and then converted into the existing FS parallax runtime model without copying a legacy map.

## 2. Stage A — Concept candidates

Generate multiple `272×208` opaque map candidates from text-first Map DNA.

Recommended candidate count:
- 3–6 first-pass candidates
- different seeds
- no legacy map as dominant init image

Store in:
`01_Benchmarks/Maps/FS_Map_Forest_Clearing_01/01_Concept_Candidates`

## 3. Stage B — Visual acceptance

Reject before decomposition if any blocking issue exists:
- map looks like a boss/landmark scene
- center is overcluttered
- routes/exits unclear
- camera/projection does not fit FS
- perimeter lacks containment
- focal hierarchy is chaotic
- layout resembles an existing legacy scene too closely
- whole scene cannot be decomposed into reusable assets

Only one candidate becomes the selected Master Scene.

Store selected candidate in:
`02_Selected_Master_Scene`

## 4. Stage C — Exact VX preview

Nearest-neighbor upscale:

`272×208 -> 544×416`

No bilinear/bicubic interpolation.

The ×2 preview is used for actual-RMVX-scale visual QA before expensive decomposition.

Checks:
- route readability at 544×416
- object/character scale compatibility
- texture density
- edge containment
- foreground occlusion opportunities

## 5. Stage D — Decomposition plan

The accepted Master Scene is analyzed into semantic components, not mechanically sliced.

Expected groups:
- Ground material zones
- Route / exit zones
- Tree object placements
- Rock object placements
- Plants / decoration
- Focal prop if any
- Occluder regions
- Lighting / shadow intentions

Store working decomposition in:
`03_Decomposition`

## 6. Stage E — Reusable asset extraction / regeneration

Do not simply cut every object out of the concept image.

For repeated asset families, use the concept scene as a composition/style target and create approved reusable Master Objects through the shared asset pipeline.

Examples:
- standard broadleaf family
- conifer family
- forest rock family
- shrub family
- grass/flower clusters
- signpost/stump family

Objects receive their own Authority, masks, metadata and validation where required.

## 7. Stage F — Ground reconstruction

Ground should be reconstructed from approved material / texture sources and route metadata so it is editable and repeatable.

Avoid treating the concept image as a permanent flattened authority.

## 8. Stage G — Occlusion / Par plan

Apply the current FS render-policy model:
- base scene contains complete environment visuals as needed
- selected object regions are duplicated into Par as occlusion overlays

Occlusion is functional, not a simple horizontal cut.

## 9. Stage H — Compiler output

Target runtime package:
- `groundXX.png`
- `parXX.png`
- optional light overlay
- optional shadow overlay
- metadata / placement manifest

Store generated runtime files in:
`04_Compiled_Runtime`

## 10. Stage I — RMVX runtime acceptance

Test in Forest Symphony with an actual actor moving through the map.

Required checks:
- correct visual scale
- walkable routes match intended layout
- no accidental invisible walls / impossible openings
- actor can pass behind intended trees/walls
- Par occlusion appears only where intended
- ground contact does not float
- exits align to transfer/event logic
- no obvious seams or doubled objects

Evidence stored in:
`05_Runtime_Acceptance`

## 11. Benchmark PASS definition

`FS_Map_Forest_Clearing_01` passes only if:
1. generated layout is original and FS-compatible
2. Master Scene passes visual QA
3. 544×416 preview remains readable
4. scene decomposes into reusable/approved assets
5. Ground/Par compile succeeds
6. actual RMVX traversal/occlusion test passes

Only after this benchmark passes should the project scale to multiple new FS maps or automate batch map generation.
