# FS Asset Factory A08 | 22-page research-to-implementation audit
Date: 2026-11-08. Applies to BOTH sprites and Master-first Ground/PAR.
Source: user-provided 22-page PDF titled "遊戲資源量產化研究報告：以 PixelLab 為核心，建立 FS Sprite Sheet 與 ground/par 分層地圖產線". This is an operational audit and paraphrase, not a reprint.
Priority: user instruction > verified FS source contract > source's illustrations / estimates. Public code only; private game source bytes in restricted Drive.

## Non-negotiable central rule (report p1, p2)
FIXED SPEC -> REUSABLE TEMPLATES -> BATCH GENERATION -> AUTO QA -> EXCEPTION REPAIR ONLY -> FS EXPORT -> USER ART + NATIVE GATE.
PixelLab is ONE interchangeable generator, never the pipeline itself.
No per-image, per-rail, or per-frame cycles after one exception pass. Escalate failures to the archetype/template/semantic source.

## Page-by-page coverage ledger (source vs actual FS)
| PDF page | Report element | FS-specific implementation and precedence | Readiness |
|---|---|---|---|
| 1 | Executive loop, PixelLab features, unknown FS assumptions | Fixed pipeline, no source speculation, clear technical/art status; original FS examples now supply native dimensions | RULE WRITTEN |
| 2 | Canonical Asset -> QA -> thin FS Adapter; schema unknowns | Two target adapters: PMD native XML + Anim/Offsets/Shadow and FS Actor _1/_2/_3; Master-first FS Ground/PAR separately | PARTIAL CODE |
| 3 | Canonical folder, anim rows/directions/pivot/loop | Independent asset_id, source provenance, action-specific dimensions, durations, loop/sequence; no universal 64px | RULE WRITTEN |
| 4 | Canonical manifest + output profile separated | Versioned manifest stored in public source (no protected image bytes); explicit mapper not copied from hypothetical example | PILOT SCHEMA |
| 5 | Character persistent 4/8dir, skeleton and reference | Source-approved concept + camera + family, 8-dir true visual views; A62 48px three-keyframe actor only approved run | SOURCE GATE OPEN |
| 6 | PixelLab/Aseprite/Spine/Tiled/TexturePacker/Pillow job placement | PixelLab art / direction / skeleton; Aseprite review & fixed-grid export; Tiled authoring; Python QA; FS exporter; no tool substitutes for FS format | RULE WRITTEN |
| 7 | Archetype families and parameterization | Humanoid, quadruped, flying, blob, boss; cap proportions, shared skeleton + equipment layers, avoid generating each walk from scratch | TEMPLATE SPEC |
| 8 | Skeleton/state/LOD and provisional cost | Reuse archetype rig; optional animation-detail LOD; per-batch hard spend authorization; PDF's USD estimate NOT fixed production cost | BUDGET GATE |
| 9 | Map: tileset vocabulary -> semantic layout -> decoration, layer contract | FS: 32px, coherent Master-first plus SOURCE OWNED object/occlusion registry; layer subtypes authoring-only | TEMPLATE SPEC |
| 10 | Tiled layers + map factory, overlap references | Tile vocabulary/terrain brush -> semantic layout -> procedural decorators -> approved Master -> semantic PAR -> FS adapter; PixelLab selections keep context overlap | TEMPLATE SPEC |
| 11 | Deterministic decor rules, auto QA first | Stable seed & configurable grass/flowers/rocks; SOURCE semantic IDs not color clustering; code checks geometry | TEMPLATE SPEC |
| 12 | Sprite QA: frame size, palette, pivot, silhouette, delta, loop, empty | Automatic hard gates, optical metrics in advisory / exception mode; game-art and foot alternation remain manual/visual | RULE WRITTEN |
| 13 | Sample Pillow/NumPy check script | Treat sample as pseudocode; build action-group-aware QA with per-native XML count and explicit expected rows; no universal duplicate ban | PILOT CODE |
| 14 | Aseprite & Tiled CLI, Git LFS and CI | Validated commands in official docs; GitHub source-only PR, private Drive artwork instead of public LFS due image rights | CI EXISTING |
| 15 | CI, roles, exception review | Art owner approves style/identity; technical artist owns archetypes/rigs/decor; exporter engineer builds format; Orca independent adversarial QA only when safe | RULE WRITTEN |
| 16 | Goblin 8dir + 2 skeleton references example | Replace Goblin 64px demo with PMD0001 native Idle3/Walk6 or Actor 3-keyframe action; only use user-approved source | PILOT QUEUED |
| 17 | Normalize -> pack -> QA -> native exporter; provisional USD costs | Fixed cell, transparent background, loop semantics; per-action FS exporter and log; estimates are illustrative only | EXPORTER PARTIAL |
| 18 | Terrain pairs, grass/stone/paths, building kits | FS 32px terrain vocabulary and named variation families; no obligation to replace master with assembled generic tiles | TEMPLATE QUEUED |
| 19 | Tiled layout & seeded decorator + PixelLab hero areas | Two scenic pilots: elf-village buildings/canopy and forest/bridge. A map scene needs semantic object ID before source mask | PILOT QUEUED |
| 20 | Map CLI/export QA and authoring -> runtime flatten | User's 4-layer FS Master-first truth: Authoring GroundOnly, Authoring CompletePAR, Runtime FullGround=Master, Runtime OcclusionPAR only true foreground | FORMAT RULE |
| 21 | Source links: PixelLab, Aseprite, Tiled, skins | Rechecked official docs; use current API/options rather than assume 2026 PDF's call price and availability are guaranteed | VERIFIED DOCS |
| 22 | Source links: Git LFS, GitHub actions, style docs | Current CI and restricted Drive asset policy overrides report's generic LFS recommendation for proprietary images | POLICY MAPPED |

## FS facts that override the report's UNKNOWN fields
- Engine is RPG Maker VX / RGSS2; Godot is only auxiliary QA. FS world 32x32 grid; viewport commonly 544x416. Large 1280x928 scene valid.
- Native PMD0001 original AnimData.xml: Idle 32x40, 3 frames, durations 40/6/6; Walk 40x40, 6 frames, durations 4/4/4/4/4/4; Attack 64x72, 11 frames. PMD0002 Idle/Walk each 32x32/4f; PMD0003 Idle/Walk each 32x32/4f; their durations differ. Each concrete action has Anim/Offsets/Shadow PNG, one or eight atlas rows depending on action; CopyOf aliases are not physical atlases. No invented direction-row identity until actual ordering confirmed.
- FS Actor battle actions have 3 STORED keyframe images named _1/_2/_3; actual playback may be 0,1,0,2, and approved A62 fighting-run reference is 48x48, NOT the general 32x32 walking character.
- A25 PMD0001 lava appearance accepted as reference; A26 generated five-frame Idle/Walk CANDIDATES not art-approved and not XML 3f/6f native. A26 exact source ZIP is not verified. Never approve by relabeling.
- Master-first V3 includes 1280x928 full Master and current two-tree/two-roof runtime masks. A06 candidate fifth bridge-rail had source-exact RGB but selected deck and had silhouette gaps: art FAIL. Source identity must be authored before mask; no GrabCut from similar RGB to decide depth.
- Exact style palette HEX, real PMD direction row index order, 3D/skeleton anchor per family, max FS atlas, current PixelLab account balances/API entitlements, and specific protected Ground3 art license remain UNSPECIFIED / REQUIRE SOURCE LOCK. Do not silently invent them.

## Current vendor docs recheck (November 2026, not guaranteed account entitlement)
- PixelLab 8-direction sprite Pro: all 8 views in one operation with concept/style/reference, optional quadruped body and view; actual output limits/credit use depend on model. Official: https://www.pixellab.ai/docs/tools/create-8-rotations-pro
- PixelLab skeleton: saved/reusable poses, template or animation-to-animation, fixed head option; pixel animation still needs review. Official: https://www.pixellab.ai/docs/tools/animate-with-skeleton
- PixelLab map guide: local 4x4-tile selection with partly overlapping source for context and inpaint only new area. Official: https://www.pixellab.ai/docs/guides/map-tiles
- PixelLab Wang top-down transitions: standard 16/32, 24 top-down beta; Pro 16/32/64 experimental. Official: https://www.pixellab.ai/docs/tools/create-tileset
- PixelLab tile pro: variations, 18-config paths, Wang, building kit. Official: https://www.pixellab.ai/docs/tools/create-tiles-pro
- Tiled layered editor: tile/object/image/group, custom properties, depth/order. Official: https://doc.mapeditor.org/en/stable/manual/layers/
- Aseprite CLI: --sheet, --data, --format json-array and --tag etc. Official: https://www.aseprite.org/docs/cli/
- PDF cost example USD 0.45 and 50% buffer is hypothetical, NOT a quote, observed FS cost, or approved spending limit. No PixelLab generation permitted without actual access and explicit bounded batch authorization.

## Definition of production success (NOT achieved yet)
- Sprite pilot: two distinct approved characters/monster family members, true approved 8 directions as required, two action loops each, original XML/source identity/pivot/weapon rules, native Game.exe or native loader screenshot, user ART seal. First-pass success and repair count recorded.
- Map pilot: two DISTINCT scene layouts from same semantic object-family/terrain/decorator template, source registered Master/4-layer FS export, correct bridges/roof/canopies without ground contamination, collision/footpoint native 203, user visual 1x seal. First-pass success and repair count recorded.
- No synthetic CI total is a substitute for the above. Art, Format, Native, Cost, Cloud gates remain separate.

## Next required files (same feature branch)
FS_SPRITE_FACTORY_SOP_V1.md, FS_MAP_FACTORY_SOP_V1.md, A08_EXECUTION_QUEUE.md, canonical manifest/template JSON, manifest contract validator/tests and CURRENT_HANDOFF. Private imagery and approved art SHA only in restricted Drive; public contains code, rules and non-sensitive metadata.
