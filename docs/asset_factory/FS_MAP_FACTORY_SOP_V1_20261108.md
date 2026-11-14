> **REFERENCE_ONLY｜A11**：保留物件家族、四圖與碰撞技術；現行優先試驗為 [唯一現行總規範](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) 的 M-A「高品質完整 Master→同源像素分層」。本 SOP 原先獨立物件家族先行是 M-B 備選／量產法。

# FS Master-first Ground/PAR Map Factory SOP V1 — scene-scale, semantic-source-first
Authority: user's 22-page production report pp9-11,18-20 + verified FS 4-layer Master-first / RGSS2 32px scheme, 2026-11-08.
Goal: many coherent, high-quality elf-village/forest maps in a repeatable authoring recipe, NOT hundreds of manual alpha mask revisions.

## M0 lock a scene-level art target and source
Input must name an actual approved FS reference (Ground3 richness / elf village reference), rights and SHA, target top-down 3/4 camera, 32x32 grid, full canvas, terrain families, atmosphere, buildings/tree species/detail density, desired walkable route, points of interest and lighting. Source/reference art not yet approved -> HOLD before final production.
FS style target = crisp 1x pixel art, coherent roof material, trees clustering beyond canvas edges, paths organic, natural grass/flowers/rocks; do not infer the actual exact 16-color HEX palette until reference source extracted and user/art approved.

## M1 semantic layout, not pixel-wise guess
Create a stable manifest of POIs, terrain polygons, paths/roads, houses and their full side wings, trees canopy/trunks, bridges with DECK distinct from NEAR/FAR RAIL, water, props and "will actor walk here" candidate zones. Use object IDs and family IDs. Define depth intent before pixels:
- ground_base/ground_decals/path/bridge_deck/shadow_back: never runtime foreground occlusion;
- tree_canopy/front_roof_eave/near_rail/cliff_top: eligible foreground, conditional to actual footpoint/depth and layer semantics;
- rear_rail/trunk/house_wall: default back or blocking, unless separately proven actor overlap;
- collision and depth metadata are gameplay, not implied by alpha, RGB color or brightness.
No parsing flat brown deck pixels as near_rail merely because the materials match. Invalid semantic ID -> FAIL_TEMPLATE, not mask adjustment.

## M2 tile vocabulary and semantic object families
Configure connected Wang terrain set for grass/dirt/stone/water border, paths (18-config possible), approved grass tufts/flowers/scattered pebbles and building kits. PixelLab Create Tileset 32px or Pro 32px tools can source these after generation approval. No generic 16px training example overrides FS 32px.
Maintain reusable object families: tree canopy+trunk; roof with whole house/workshop coherent; bridge with independently designed deck, far rail, near rail and posts; stone cliff with 1-2 tiles physical overhead depth; gazebo with supporting beam; independent vegetation decor.
Each object source is generated or assembled as a coherent sprite/shape+mask BEFORE placing into Master. Do not find its identity by thresholding the finished RGB Master.
Scale up richness by adding family variations and scatter rules with fixed seed, not repeatedly editing the same tree/bridge pixel.

## M3 PixelLab generation in reproducible stage (not always whole final image)
1. If approved material/style profile exists, use it as reference; master art remains 1 coherent image in the FS accepted Master-first process. Use PixelLab Tileset/Tiles Pro for terrain + building kits, map/extend for coherent regions, not separate independent fragments with no shared context.
2. When using Create Map local 4x4 tile area or extension, selected region MUST overlap prior approved pixels and inpaint only the newly empty portion so the model sees a style/connection anchor. Save seed, init strength, reference IDs, input mask, output image and generation cost.
3. Build semantic object family and mask together: e.g. full FRONT BRIDGE RAIL source art with alpha silhouette, front/back/ground role, footpoint rule. If the object is part of a flat full Master that cannot be reliably separated, regenerate/refactor the complete bridge family/semantic region as an image+mask pair while preserving the scene style. No GrabCut wood-color extraction.
4. Build whole scene Master and approve overall composition. Freeze source SHA after art target is confirmed; authoring can retain rich named layers, runtime still only two visual PNGs (plus collisions).
5. Never assume one PixelLab whole-map call can output a native FS Ground+PAR. FS exporter owns that last mapping.

## M4 Canonical authoring layers (many) distinct from FS native output (four)
Canonical editor layers:
- ground: terrain_base, terrain_transition, paths, bridge_deck, ground_decals, ground_fx
- scene objects: props_back, structural_walls, vegetation, house_and_workshop, tree_canopy, bridge_front, roof_eaves, cliffs, light/shadows
- gameplay: collision, actor_footpoints, depth/occlusion regions, nav/entrances/spawn/triggers
- debug: source ID, per-object masks, camera/actor placement, collision topology, 1x review.
Tiled Tile Layer / Object Layer / Image Layer / Group Layer are good authoring intermediates, not mandatory FS runtime formats.
Each independently registered object:
  instance_id, family_id, source_png_sha256, source_semantic_class, world_xy, complete_mask, occlusion_mask,
  collision_shape, legal_actor_footpoint predicate, depth_order, desired foreground role, z/switch rule.
Parent/source background may remain visible in Master, but same RGB is NOT proof of correct near-rail semantics.

## M5 FS native four-image contract (do not replace with generic report diagram)
1. Authoring_GroundOnly: true terrain and reconstructed pixels behind removed objects (when needed for authoring).
2. Authoring_CompletePAR: all raised objects, with independent source and ownership IDs/masks. This is NOT the final character-overdraw layer.
3. Runtime_FullGround: 100% complete frozen Master image at original world XY; houses, foliage and all scene details remain visible. It avoids double-edge seams.
4. Runtime_OcclusionPAR: ONLY source-registered pixels that must be in front of a legal actor for their depth context. Identity and predicate must come from object/footpoint design, never RGB segmentation. RGB identical to Master XY and no pixels from nearby ground/deck/grass.
A scene may require multiple depth categories or a conditional overlay/switch 203; FS/RGSS2 adapter handles exact renderer mechanics. Never promote all Authoring CompletePAR to Runtime OcclusionPAR.
Collision map is a SEPARATE gameplay output.

## M6 deterministic decorator rules (report pp11,19)
Create seed-based vegetation clusters, stone/grass/flower variants and path exclusion zones. Example specification:
  terrain:forest_v1, seed:18427, grass_tuft_probability:0.08, stone_probability:0.025,
  avoid_walkable_central_path:1 tile, preserve POI entry clearances:2 tiles.
These numbers are ILLUSTRATIVE trial parameters from report, not approved FS default density. Scene-level QA must ensure lush forest without repeated cloned tree patterns or unnatural paths.
Record each placed instance ID, source family, seed index and object-footpoint rule.

## M7 automated map technical QA and negatives
HARD:
- 32x32-aligned map size and exact source SHA.
- Native Master/Runtime image same dimensions; complete source object attribution; masked RGB matches Master XY; per-owner mask no unwanted overlap; no stray foreground pixels assigned to deck/vegetation based on color alone.
- Object semantic class explicitly permitted in foreground; bridge_deck/grass_path/water_surface disallowed when near_rail source ID.
- Correct L mask grayscale vs RGBA alpha; nonzero means any overlap, not >20% named "any"; allow artistic soft alpha only if manifest explicitly declares it and exporter supports it.
- Collision passability graph connected from player spawn to intended POIs; entry/exit and bridge deck traversable; no isolated roof walkway or illicit water passage.
- Object clips bounds only when intentionally extending beyond canvas and recorded in manifest. Native color/occlusion geometry does not certify art.
VISUAL/ART at 1x whole scene: style vs original Ground3, coherent house and workshops, shadows, natural dense vegetation, organic paths, crisp ground, no obvious cut edges, no bridge wood deck in foreground rail, actual actor readability. Art reviewer judges WHOLE SCENE / representative interactions, not every rail pixel.

## M8 exception repair and escalation
QA emits per-instance concise exceptions. If a near railing includes deck, classify SEMANTIC_TEMPLATE_FAIL and reject source, do not iterate GrabCut V0/V1/V2. If whole house+workshop looks stitched, regenerate the FULL building as single object family in same style, not repaint seam.
One targeted inpaint attempt max for an isolated source anomaly. Repeated 2 similar failures -> halt batch and fix source family or PixelLab prompt/style skeleton. No more same scene V17/V18/V19 detail-only cycles.

## M9 native adapter and real 203 semantics
Export runtime PNGs + legal 29x40 / scene grid per actual map size, source manifest, collision. Embed only according to existing RGSS2/FS switch 203 and scene script contract. A Python/Godot composite, hash or BFS is static-only.
Actual native VX test must inspect Game.exe on approved isolated Windows clone, exact x/y + real_x/y + pattern/direction and walking transitions, test actor ON/OFF behind canopy/eave/near-rail and clear negative, with screenshot/shadow/alpha and collider. Requires separately approved PC temporary scope and cleanup; if unavailable NATIVE_NOT_RUN.
A V4 784/784 connected draft is not automatically valid art, bridge deck, nor engine pass.

## M10 two-scene same-template repeatability trial
M-P1 ELF_VILLAGE: full two houses (left whole workshop integrated), 2-3 canopy groups extending outside viewport, organic path, varied grass/flowers/rocks, true ground footpoints and roof eaves.
M-P2 FOREST_BRIDGE: connected Wang dirt/grass/water, one complete bridge object family split into deck, near/far rail as semantic instances, no floating actor or repeated deck on PAR, collision entry/exit. A06 image mask is FAIL reference, not approved rail.
MUST use the SAME family schema, Tiled group naming, 32px semantic registry, common exporter, test plan and metrics. Two maps need human 1x scene art review and real native VX before mass production; otherwise report pilot HOLD.

## M11 native visual/engineering gates and KPI
Track per-scene first-pass style pass, object-semantic alpha leakage, complete source attribution, ground repeat score, natural vegetation density, illegal collision tiles, distinct correct occlusion interactions, number of exceptions and PixelLab credits. Art pass is judged on final 1x map not an upscaled attractive composite. Technical pass cannot substitute.
Start budget zero until authorized. Once two scene pilots pass, validate 5-10 seeded variations, then 20 maps to calibrate budget/error rates. Source report's examples 30-80 sheets/day are NOT actual FS results.

## M12 storage, roles, rollbacks
ChatGPT owner locks manifests / exporter / CI and Drive Handoff; PixelLab creates source sprite/map parts only in bounded paid batches; Orca S1 sprite / M1 map adversarial reviewer only under verified read-only approval mode; Tiled/Aseprite editor as needed. No unsandboxed worktrees on user PC.
Save proprietary Master/source object images and QA screenshots to RESTRICTED private Drive; public GitHub only source code/profiles/manifests sanitized/CI. Master and original FS sealed material immutable; feature PR Draft. Every pilot records source SHA, provider model version, seed, template version, native Game.exe evidence, ART verdict and rollback.

## Official capability verification
PixelLab Map guide https://www.pixellab.ai/docs/guides/map-tiles
Wang Create Tileset https://www.pixellab.ai/docs/tools/create-tileset
Tiles Pro variations/path/building kit https://www.pixellab.ai/docs/tools/create-tiles-pro
Tiled layer groups https://doc.mapeditor.org/en/stable/manual/layers/
