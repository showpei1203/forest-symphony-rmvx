# Forest Symphony MAP / Game Asset Pipeline Handoff — 2026-08-19

## Current Priority
Continue Forest Symphony castle-map / parallax asset production and SAM2-assisted QA. Do not restart PixelLab/API integration or the general asset-pipeline discussion. This is an ASSET/MAP checkpoint and does not modify sealed runtime/script baselines.

## Mandatory Binary Ground / PAR Authority

`GROUND = true ground/terrain surfaces + floor/terrain tiles + flowers + grass`

`PAR = EVERYTHING ELSE`

PAR therefore includes buildings/houses/castle, walls/gates/towers/roofs, trees/trunks/canopies, bushes/shrubs, rocks, statues/goddess statues, fountains, fences, flowerbed structures, signs/stalls/furniture, bridges, structural stairs/steps, lamps, crates/barrels and every other non-Ground object.

Actor occlusion is NOT the criterion for PAR membership. The user may later derive actor-covering regions from the complete PAR in Photoshop.

Primary completeness authority: `MASTER ≈ GROUND + COMPLETE PAR`.

## Scale
- RMVX world scale reference = 32×32 px.
- 544×416 is only the classic viewport reference, not a map-size limit.
- Current Castle benchmark Master = 1448×1086.
- Monster sprites are not limited to 32×32.

## Current Castle Status
- Working benchmark/master scene only, not Runtime Approved.
- Actual formal Ground + Complete PAR have not yet passed layer QA.

## Local SAM2 Environment
- Windows + WSL2 Ubuntu: PASS
- NVIDIA GeForce GTX 1660 6GB visible in WSL
- observed driver: 560.94
- PyTorch 2.13.0+cu126
- Torch CUDA 12.6 / `torch.cuda.is_available() = True`
- SAM2.1 Hiera Small loads successfully on CUDA
- Grounding DINO Tiny through Hugging Face Transformers: PASS
- local work root: `C:\SAM2_Work`

Do not replace the proven cu126 environment with CUDA-13 PyTorch on the current driver.

## SAM2 Benchmark History

### v1 Mixed full-scene prompt
- 16 classes at once.
- only 5 detections.
- statue detected.
- `market stall` created a huge false positive over most of the city.
- raw union is not reliable layer authority.

### v2 Category batches + oversized bbox filter
- huge fountain/monument landmark false positives (~69% canvas) were rejected.
- two small statue candidates remained.
- architecture castle-wall bbox (~67.4% canvas) still polluted final mask.

### v3 Tiled detection
Recall increased but precision collapsed:
- castle gate 19 accepted
- tower 26
- building 34
- roof 41
- statue 40
- fountain 21

Tiling is useful for discovery, not truth.

### v4 Alias consensus
Architecture accepted:
- castle gate 5
- tower 11
- building 6

Landmarks accepted:
- statue 7
- fountain 2

Precision improved but was still too noisy for formal inventory.

### v5 Guided SAM2
Strategy changed to:
`ChatGPT visual identification -> bbox manifest -> local SAM2 segmentation`.

16 high-risk objects were defined: Main Castle, NW Round Chapel, six perimeter towers, South Gatehouse, Central Goddess Statue, four fountains, East Windmill and NE Small Tower House.

v5 revealed five authored bbox errors: K08/K12/K13/K14/K16.

### v5.1 Corrected Guided SAM2
Those boxes were corrected and all 16 masks rerun successfully.
Representative fill ratios:
- K01 Main Castle ~0.692
- K09 South Gatehouse ~0.650
- K10 Central Goddess Statue ~0.617
- K11 West Plaza Fountain ~0.605
- K08 SE Wall Tower ~0.304
- K12 East Garden Fountain ~0.889
- K13 NE Garden Fountain A ~0.462
- K14 NE Garden Fountain B ~0.390
- K16 NE Small Tower House ~0.450

Current interpretation:
- Guided SAM2 = useful missing-object / QA evidence
- Grounding DINO = optional discovery hints
- neither decides Ground vs PAR
- raw masks/unions are not runtime layers

## Critical Correction: Whole-Mask PAR Coverage Is NOT a Hard Gate
Do not formalize a rule like `>=80% of the complete SAM2 object mask must be in PAR`.

Reason: fountain/landmark masks may include water, floor, flowers or grass. Those pixels legitimately belong in Ground under Binary Authority. Requiring whole-mask overlap would incorrectly force legal Ground into PAR.

Any earlier `PAR Completeness Validator v1` full-mask-overlap concept is superseded before formal adoption.

## Next Validator Direction: Witness-Point / Core-Structure QA
Implement `PAR Completeness Validator v2` with:
1. exact Master/Ground/PAR dimensions and pixel registration;
2. `MASTER ≈ GROUND + COMPLETE PAR` recomposition and visual diff;
3. witness points on guaranteed non-Ground structure for the v5.1 high-risk objects;
4. small-radius PAR-presence checks at those witnesses;
5. optional SAM2 masks only as supporting visual evidence;
6. PAR source-pixel fidelity where applicable;
7. manual alpha/edge/contamination review.

Examples of valid witnesses: statue body/pedestal, fountain stone basin rather than water, tower roof/wall, castle wall surface, windmill body/blade.

## Immediate Next Steps
1. implement/finish Witness-Point PAR Completeness Validator v2;
2. author/review witness coordinates for the 16 v5.1 objects;
3. produce actual Castle Ground and Complete PAR under Binary Authority;
4. run registration, recomposition, witness omission, alpha/edge QA;
5. fix contamination/omissions;
6. after Visual PASS, proceed to collision, exits and RMVX actor-scale test;
7. later integrate these rules into the procedural-parallax compiler.

## Do Not Do
- do not restart PixelLab/Cloudflare transport work;
- do not reinstate a 544×416 map-size cap;
- do not redefine PAR as occlusion-only;
- do not let SAM2/Grounding DINO decide PAR membership;
- do not use raw union as a final layer;
- do not resume endless Grounding DINO threshold tuning unless a new discovery use case requires it;
- do not use the superseded whole-mask 80% PAR rule;
- do not call this Castle layer split Approved until actual Ground + Complete PAR passes recomposition/visual QA.
