# PMD0001 Attack rejection: source-locked native pose review

**Purpose:** Review the failed procedural 8F next to genuine historic PMD G9 XML-defined 11F poses, not to claim a finished new PixelLab or concept-style motion.

## Sources
* Historical user-private G9 ZIP: `P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027.zip` (Drive ID `1QWdMHbu1VTQ85kaOEXSankeSsIY6FvOS`).
* `GODOT_0001/rock_0001/Attack-Anim.png`: 704×576, 11 columns × 8 directions, native 64×72 tiles.
* `AnimData.xml` action `Attack`: 11 durations `[4,2,4,2,2,2,2,2,2,2,4]` with `RushFrame=2`, `HitFrame=5`, `ReturnFrame=7`.
* Earlier concept-derived procedural 8F and `PMD0001_STATIC_64.png`, archived in the T-B private Drive.

## Why last attack failed
`build_tb_monster.py::attack_frames` used whole-body `body_pose()` squash/move + `add_lava_bolt()`. **6/8 frames** reconstructed *byte/pixel exactly* with an unarticulated, whole-body pose transform; other 2 are the same with projectile pixels. No new joints, jaw pose, crouch-leg articulation, contact arc, or physically attached muzzle.

## Change of method
1. The old sequence is **ART FAIL / ARCHIVE**, not an approved asset. No more changing body squash constants.
2. Original 11-frame legacy PMD animation is preserved as a separate **motion reference**, not merged into concept identity or promoted as finished.
3. For next actual attack, drive approved concept from 3 distinct key poses: F0 = crouch (legs visibly compressed and jaw closed); F4 = jump/charge (rear legs extend and upper body turns while staying 3/4 SE); F7 = contact (jaw open and flame emitted at mouth); F10 = recover. **Feet pivot and palette fixed**, no clone/extra toes.
4. Use PixelLab `estimate-skeleton` + `animate-with-skeleton-v3` to constrain real limb articulation where feasible; if frog skeleton estimate is unstable, use `animate-with-text-v3` per key pose, then revise with edit-animation. Actual API/credits **not run** this turn.
5. Return to Godot **4.7.2 native** and the human visual review. This directory provides a stand-alone 
   `tb_attack_review.tscn` that can run as the `project.godot` main scene in the existing T-B demo.

## Godot review
- ZIP has the original T-B project plus `tb_attack_review.tscn/.gd` and 11F native atlas `row1` and `row2` under `res://assets/monsters/tb/`.
- Open in Godot **4.7.2**. Start **TBAttackReview** (main scene in rework ZIP). Press **SPACE** to compare; **1** and **2** replay 11F row variant; **R** resets. The scene labels `RUSH` / `HIT` / `RETURN` according to original XML metadata.
- The GIFs are preview renderings only, not native Godot evidence; no original XML tick rate is asserted as an actual frame-time conversion. The preview uses 30 ticks/s solely to show timing.

## Acceptance gate
Reject any candidate if: the only change is rigid body movement, mouth/legs do not move, attack is conveyed only by VFX, sprite is cropped, identity is lost, angle drifts, or source rights are unverified. Geometric SHA PASS does not override these gates.

## Handoff and privacy
All art / native source stay in private Google Drive. GitHub holds scripts, source hashes, failure log, and Handoff. No PC result library, no changes to main / T-A / T-C.
