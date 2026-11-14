# A07: MANDATORY PRODUCTION METHOD CORRECTION (2026-11-08)

Owner feedback: stop individual railing-pixel rework. Build a repeatable FS Asset Factory, not never-ending A06 V0/V1/V2 masking.

## User-report authority
User's report: 遊戲資源量產化研究報告：以 PixelLab 為核心，建立 FS Sprite Sheet 與 ground/par 分層地圖產線.
Page 1: fixed spec -> template -> batch generation -> QA -> exceptions only.
Pages 9-10: tileset vocabulary -> semantic layout -> decoration pass, distinct ground/par/gameplay, exporter.
Page 15, pages 19-20: objective QA automated, semantically authored layers flattened to FS runtime formats only at export.
Note report's illustrative par hierarchy is not the FS-engine authority. Later user's Master-first approach remains binding; use full illustrated Master plus semantic object generation, not image-color segmentation.

## Root-cause failure
A06 V0 GrabCut guessed a near railing from an already-flattened painting by color, inadvertently selecting bridge deck, grass and other pixels. V1/V2 manually trimmed alpha, thus optimizing the wrong step. Source RGB agreement, alpha overlap=0, and synthetic CI PASS did NOT certify foreground object identity or usable art.

## Mandatory process
1. Lock actual FS art target (Ground3 richness, 32x32, top-down 3/4, harmonious elf village/forest), representative scene brief, and semantic layout before asset masking.
2. Build/approve a coherent whole-scene Master. Ground visually matches Master, following the accepted Master-first rule. Use repeatable terrain vocabulary, object families, seeds, decor rules, not local hand-painted fragment adjustments.
3. Register each semantic object before any PAR extraction: ID, family, generated source art or instance, explicit shape, collision footprint, actor footpoint/z logic, depth class, object-only complete mask, foreground occlusion mask, source SHA and renderer order.
4. Runtime PAR contains only true front-of-actor object pixels for an eligible legal player position. The near railing must NEVER include the deck just because both are brown. Back structures, grass and ground must remain in the visual Ground/master but not copied into foreground PAR.
5. If the object cannot be cleanly separated from the master, change the source asset recipe and regenerate the complete corresponding semantic object/region and its mask together. Do not keep tuning color clustering/GrabCut thresholds.
6. Validate automatic hard checks (same world XY, SHA, pixel exactness, object ownership, 32px grid, reachability) separately from scene-scale art (coherence, naturalness, visual richness and actual player concealment), native VX, and formal seal.
7. Prove repeatability with at least two scenes, e.g. house/canopy and bridge/forest, using identical recipe before expanding. Record first-pass exception rate, not only CI test counts.

## Stop-work rule
- NO further repeated per-pixel V2 railing repair as the main production workflow.
- Any deck pixels in BRIDGE_NEAR_RAIL mask = architecture/semantic source error (not minor alpha tweak).
- Never mark art PASS merely from 0 RGB mismatch, 0 overlapping masks, or collision graph PASS.
- After one localized exception-repair attempt fails, revise template/object generation recipe; do not create V3,V4,V5 manual trims.
- Prioritize complete scene art and object semantic correctness, then verify under native VX.

## Sprite parallel method
Approved concept -> style + archetype family -> 4/8 direction master -> reusable skeleton and poses -> normalized frames -> canonical sheet -> exception QA -> original PMD/Actor native exporter. A25 monster LOOK approved; A26 five-frame Idle/Walk are only candidate art while native XML requires 3 and 6 frames. Do not invent approved A26 footage.

## Current safety and status
PR #15 remains Draft, main untouched. A06 private V4/5-object ZIP is a diagnostic candidate, not final art. New Orca Agents not launched because approvals were unverified. V4 native VX NOT_RUN. PixelLab paid calls 0. Source and Art seals not conflated.