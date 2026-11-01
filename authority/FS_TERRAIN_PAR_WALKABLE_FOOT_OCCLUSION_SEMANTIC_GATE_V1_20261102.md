# Forest Symphony | Terrain PAR Walkable-Foot / Occlusion Semantic Gate v1.0
Date 2026-11-02. **ACTIVE / overruling terrain pixel-class masks as PAR.**

## The critical distinction
**PAR != terrain outline / cliff face / collision.** PAR is a layer that **covers a sprite when the sprite walks to a physically behind location and is actually expected to be visually hidden**. A dark/brown cliff-wall RGB pixel, a visible cliff front, or an impassable cliff alone does not qualify. Most cliff walls are permanent **GROUND** because the hero walking in the lower open plain must be rendered in FRONT of them, not cut off by their copied brown pixels. Tiling 64×64 cliff-colored excerpts into PAR without an actor-facing zone was wrong even though static Ground+PAR RGB looked pixel-perfect.

## Required per-candidate contract
Each proposed terrain foreground object must carry:
- `object_id`, independent original RGBA source asset and SHA, alpha bounds and exact XY.
- `geometry_role`: e.g. overhang/roof/front ledge/bridge face/cave arch **not** just "cliff RGB".
- `occluded_actor_foot_tiles`: explicit array of reachable VX 32×32 tile IDs where actor is *behind* that object. Empty list => NOT PAR.
- `actor_elevation_id` / `terrain_elevation_id`, front/back direction relative to actor and occluder foot/depth; verify in actual scene graph.
- `blocked_cannot_enter_tiles` must remain collision logic, not surrogate evidence for PAR.
- `should_show_in_front_tiles`: actual lower-ground foot tiles where the same rock wall should be **behind** actor.
- `visual_masks/region` only the source pixels that occlude actor on accepted behind-foot tiles, never full contour. Preserve unchanged opaque Ground source so imperfect masks don't destroy art.
- Separate SHADOW/LIGHT; do not reuse as opacity or cliff mask.
- `vx_case_behind`, `vx_case_front` actual visible native screenshots with actor position & foot tile. Fail closed until both are verified and front never accidentally covers the actor.
- Additional cave/portal transitions must have actual map event/passability: merely depicting a cave entrance in the illustration is not evidence that the player can walk behind the cave roof.

## A35 -> A35B evidence
- A35 Ground user-approved source direction, image 1280×928 RGB SHA `478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00` LOCKED.
- Rejected **217** A35 pieces from brown cliff RGB classification as "terrain occluders" because none has `occluded_actor_foot_tiles`, elevation/region, and actual front/behind positive pair. Rejected pieces still archived in A35 as error reproduction, DO NOT DELETE source.
- 746 provisional walkable foot tiles A35, 414 blocked; source image cliff-pixel mask intersected actor 32px bbox on **291 claimed walkable tiles**. This is a **collision classification and foot-region audit flag**, NOT evidence 291 PAR candidates. A35 height/collision have known 51 cells split into small disconnected regions; do not claim all walkable or terrain resolved.
- A35B isolated candidate has 0 **active terrain PAR** and true fully transparent 1280×928 PAR50 SHA `3ddfa14f3ff633edcbe37d2a8d022608d374dbb5ef1698cfa408c54ca4e25c16`. This is intentional, not a missing deliverable: no terrain overlay has yet passed actual back-foot occlusion eligibility. Future overhang/cave lip/roof must be added when an actual behind-walkable zone is authored and tested.
- Actual same-engine real VX 544×416 screenshots at 11 positions / 22 frames with overlay ON versus OFF, after initial two title fade frames, **identical Ground-only hidden frames and zero scene RGB background diff**. Actor recovered up to **77 originally wrongly overwritten visible pixel positions** in case3 west valley: A35 550/627 actor positions vs A35B 627/627. Lower center case7 recovered20; east lower8 recovered13; middle plateau case4 recovered8. Other scenes remain at full 627.
- Cave mouth source is `A35B_GROUND_SOURCE_IDENTICAL_1280x928.png` and candidate arch exists **only as a semantic TODO**, not rendered in PAR, pending verified portal and height/entrance.
- Native Godot actual GPU full 1280×928 6 frames+6 viewport crops, exact 0 RGB mismatch to original source Ground. VX native scene and collisions unchanged (blocked cliff and permitted grass movement pass). Cold native VX later separate source SHA test.

## Rule
`A FEATURE IS PAR iff at least one reachable, physically behind actor-foot tile and a validated source mask would occlude the actor there, while front-of-feature actor stays visible.`
If no verified foot tile exists, active terrain PAR pixels = 0. That's better than 217 fake masks. Do not reactivate old masks from RGB, alpha outline, or collision alone. Keep active PAR object-by-object with native X/Y foot and rendered actor tests, not full snapshot trick.
