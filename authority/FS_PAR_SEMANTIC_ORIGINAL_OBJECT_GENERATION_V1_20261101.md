# Forest Symphony — Semantic PAR Object Generation Authority v1.0
Date: 2026-11-01 (Asia/Taipei)
Status: ACTIVE USER AUTHORIZATION (conditional); NO VISUAL SEAL or ENGINE SEAL implied.
Scope: FS Stage16 Ground/PAR and following maps only; separate from SBS/PMD animation projects.

## User authorization, precise interpretation
After the target art style is established, a PAR object MAY be independently generated or designed according to scene semantics and user descriptions. It no longer has to be an exact pre-existing asset from the reference library. Existing source assets remain the style reference / source-of-truth for **provenance**, not a closed whitelist of permissible object designs.
The A29 scene has **NOT** acquired independent final visual approval. The authorization does not convert A29 into a visual PASS and does not authorize rewriting or replacing locked original Ground.

## Generation routing order
1. Read current authority, FS_SOURCE_ASSET_LOCATION_REGISTRY_V1, CURRENT_HANDOFF and latest scene manifest before producing any PAR object.
2. Fix the intended visual style from user-approved benchmark, 3/4 top-down perspective, scale / silhouette, lighting, palette and pixel-density. If not confirmed, mark new creations VISUAL_CANDIDATE only.
3. Classify the prompt meaning: (a) flat low terrain detail -> GROUND or separate ground-aligned overlay, (b) upright tree/building/rock/lantern/vegetation -> PAR object, (c) special movement geometry -> explicit collision/region.
4. Choose a source-owned sprite, tool-assisted transformation, or an original object generation from an approved pixel-art pipeline based on scene requirements. No mandatory literal identity with the source inventory.
5. Record source_type one of DRIVE_SOURCE, PIXELLAB_NATIVE, AI_GENERATED, PROGRAMMATIC, HUMAN_EDITED and exact parent/reference/version/tool/prompt/seed/credits when available. Never label generated material as provided original source.
6. If using AI, generate **the isolated complete object sprite** with transparent alpha (not an entire flattened scene), preserve editable source, and explicitly record usage cost. Additional model credits are NOT presumed authorized merely by this design permission; zero-credit alternatives can be used first.
7. Stage in a new A30+ isolated candidate directory. No changes to SEALED production, A27 original Ground, A28 source/tone, A29 files, or raw Drive sources.

## Hard object gates (fail closed)
- Entire object visible within its independent RGBA source: tree crown, trunk and root, house roof / sides, rock perimeter, etc. Check alpha on source crop edges BEFORE transparent padding; padding cannot disguise a crop failure.
- Native pixel edges, 32px world grid conventions, fixed camera angle and consistent non-blurred pixel resolution; no unknown black/colored matte, halos or out-of-style outlines.
- Scene manifest records each object's immutable (x, y) top-left, dimensions, full source and sprite SHA256, independent foot / Y-sort, alpha, collision footprint and ownership.
- Object must be entirely within target map or have a formally declared intentional cross-map split. No silent clipping by 544x416 viewport.
- Keep true original opaque Ground separate from isolated PAR_BASE_RGBA and reversible PAR_TONE_RGBA/PAR_FINAL_RGBA. RGB-only tone pass must preserve exact alpha per pixel and original sources. Contact shadows on an independently tracked layer if used.
- Walkability defaults to GROUND walkable; canopy, lamp head, roof and leaf alpha do not by themselves block full silhouette. Collision is based on ground footprint and actor passage; dynamic front/behind tested in engine.
- Sample visually distinct objects (do not merely recolor a duplicate), but gate on cohesive style, not novelty alone.
- Export no-actor composite and actual Godot native actor overlap evidence: behind partly visible, behind fully hidden, front visible, near trunk, road. Ensure legal 32px feet, BFS connectivity and pixel-diff details.
- True RPG Maker VX map/occlusion/passability must be independently tested in a bootable isolated VX project. A screenshot of a VX NameError modal is **NOT** engine PASS.
- License-unknown Drive art is private-test only; generated objects must also have verified usage rights before commercial deployment.
- Private art stays on user's Drive / local approved store; GitHub may contain docs, scripts, hashes, structured manifests and findings but no uncleared binary sprites.
- Cold extract/rebuild and SHA check all outputs, provide mobile vertical preview with verified URL and update CURRENT_HANDOFF. FormalSeal=NO until art and both native engine gates pass.

## A29 baseline for A30
A27 original GROUND 544x416 SHA256: 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce.
A29: 12 independent PAR objects; 4 complete trees (3 Drive-derived, 1 PixelLab existing), 209/209 BFS walkable, Godot 8/8 cold exact SHA. A29 art approval pending, native VX map BLOCKED by NameError 'undefined method p45b_prepare_resources for class Module', FormalSeal NO.
A30 must resolve isolated VX script startup, then map test; this authorization does not change gate priority.

## Principle
The reference asset library constrains the **style**, not the **set of imaginable objects**. Pixel-art approval comes from complete, authentic layers and tested engine behavior, never from an attractive but flattened screenshot.


## A32 user mandate — dedicated SHADOW / LIGHT ownership and crisp PAR silhouettes (2026-11-01)
Scene/environmental cast shadow, area shadow, bloom, lamp glow, day-night light and global light modulation MUST be separate SHADOW and LIGHT layers. They MUST NOT be baked into PAR as a false fix for alpha edge blur, nor merged into Ground. PAR exclusively owns object-intrinsic painted pixels, alpha geometry, Y-sorted occlusion and foot/collision metadata; intrinsic sprite texture color/shading (part of the artwork rather than an added scene light layer) must be distinguished from separable environmental illumination. Ground only owns continuous terrain and truly flush terrain textures. The engine compositor and manifest must assign every rendered effect to the right layer explicitly.

For original or source-derived PAR, especially FS A32 top two broadleaf canopies: use lower object trees as a pixel-step contour reference; trim soft alpha fringe and low-opacity stray leaves in isolated RGBA, maintain full tree canvas, crown/trunk/root, foot, 32px collision and native front/behind visual QA. Alpha changes are allowed solely when visually justified by edge cleanup; do NOT claim alpha-identical when it was intentionally sharpened. Never use Gaussian blur / generic full-scene sharpening / fake dark outside silhouette or shadow to hide an unclear tree outline.

**NEXT USER-ORDERED STAGE AFTER A32: A33 must work on the too-soft native PixelLab GROUND edges vs reference Ground3, not keep polishing PAR.** Original A27 Ground SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce stays locked in A32; A33 Ground candidate receives separate new filename and digest, with fresh native VX / Godot revalidation. Reference [A32 detailed Handoff](../experiments/route_b_25d_20261031_stage16/STAGE16_A32_PAR_TREE_CANOPY_PIXEL_EDGE_NATIVE_VX_HANDOFF_20261101.md) and [A33 Ground kickoff](../experiments/route_b_25d_20261031_stage16/STAGE16_A33_GROUND_PIXEL_EDGE_REWORK_KICKOFF_20261101.md). Formal Seal NO.


## Priority override after user's A32 art rejection (2026-11-01)
A32's native engine/silhouette checks passing does not authorize automatic move to Ground. The user rejects A32 upper tree art for lacking visible internal leaf shapes; Stage A32B must first produce the upper-two-tree rework for **user visual acceptance**. Only after the user approves A32B, begin A33 Ground material-edge style changes. Retain immutable A27 Ground and A32B PAR sources until user signs off. Never infer "user accepted" from an algorithmic descriptor, native VX 24-screen result, or the assistant's own preference. Relevant [A32B latest handoff](../experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A32B_20261101.md).
