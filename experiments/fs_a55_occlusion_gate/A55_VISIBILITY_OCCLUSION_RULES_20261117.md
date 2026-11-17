# FS A55｜動畫遮擋／可見性語意 Gate｜2026-11-17

**Status: DESIGN RULE REGISTERED · NATIVE/ART NOT RUN**  
**Scope:** Forest Symphony Godot 4.7.2 character/monster sprite-sheet production; A53/A54 Body, equipment Icon layer, HitMarker & AnimationPlayer. No VX authoring rollback.  
**Source inspiration:** 2026-11-17 user-supplied Threads screenshots, example of a skeleton warrior seen from NW with sword hand occluded by shield at attack F5/F6. Only concepts are captured, not third-party illustration files or copyrighted prompts.

## Why this rule exists

Anatomically valid rigging does **not** imply the limb should be visible. When a shield, torso, cape, large weapon, wing, or foreground object fully occludes a hand/forearm at a particular pose/view, an image model may hallucinate or preserve a visible limb in front of the occluder. If only the weapon tip is visible, the visible sprite should depict **only that segment**, without a ghost hand, extra fist, misplaced weapon guard, detached arm, or mirrored duplicate.

The user's screenshots compare before/after at NW F5/F6. They report changing both the pose/guide and negative occlusion prompts; the demonstration is a *single viewpoint, two frames, one chosen variant* and must **not** be promoted as universal accuracy for all directions or characters. The example's 31-pixel guide tip is **not** a default for FS 64x64 or original Godot 24x24 Iconset.

## Canonical production contract

1. **Canonical body and equipment remain separate:** A53's 12-frame true PixelLab-generated Body is a distinct authoring source from Godot Iconset Weapon layer, skills FX and collision/hit markers. Never permanently erase a body part from the global A62 source or alter A51/R4 to solve only one view/frame. Produce an isolated new action/view variant if needed.
2. **Determine visibility before generation:** For every direction/action/key pose, author a manifest listing `visible`, `partially_occluded`, or `fully_occluded` for each relevant part (hand, forearm, upper arm, hilt, guard, blade, shield, cape, wing, etc.). Record why, who is in front, and which image/layer owns the visible pixels.
3. **Enforce occlusion in BOTH guide and prompt:** A pose guide may only draw outlines of intended visible pieces. Text instructions explicitly forbid hidden limbs/duplicate fists and prescribe the intended visible portion (e.g. only a short blade beyond shield). When the guide depicts an incorrect visible fist, rewrite the guide first; adding stronger text alone is not considered a fix.
4. **Apply deterministic render order/masks in Godot:** Maintain physically correct foreground-depth ownership of pixel regions. Draw body and equipment separately, with per-frame occlusion or z-index as needed. Simple global layer order can be insufficient when part of a weapon must appear behind a shield while the blade tip must appear in front; use per-region masking/split layers if truly required. Body atlas must not contain baked weapon.
5. **Accept on evidence, not prompt confidence:** Render fresh Godot 4.7.2 native screenshots and 1x GIFs for each frame/direction/action. Compare visible silhouettes and alpha, ensure hand/forearm pixels are not incorrectly present in forbidden visible region, and ensure intended blade segment is visible. Separate screenshot export/engine PASS from anatomy/ART PASS.

## Fail-closed A55 QA gates

| Gate | Required evidence | Fail if |
| --- | --- | --- |
| V0 canonical | Actor source ID, source SHA256, approved angle, frame keytimes | Source unknown or altered without lineage |
| V1 pose truth | Pose screenshot/guide agrees with full-body anatomy and occluder geometry | Hidden arm drawn as guide |
| V2 visibility manifest | Every targeted frame has part visibility and occluder ownership | Missing frame/direction/hidden-limb entry |
| V3 generated pixels | Frame-specific masks or annotated image comparison, no ghost arm/fist, no duplicated equipment | Forbidden pixel group appears |
| V4 runtime layers | Actual Godot frame/camera, Body + Weapon/FX ownership, masking, contact marker | Incorrect draw order, 2nd hand, cropped tip, weapon baked in Body |
| V5 motion | 1x loop and 3x contact sheet, temporal continuity, hand/hilt/occluder invariants | Limb pops between frames or jumpy tip |
| V6 gameplay | Real contact timing, range and damage, cancel/2x playback, freeze/unfreeze | Visual edit changes hit or damages outside range |
| V7 art | User review at native 1x | ART HOLD until approved |

**Metrics are diagnostic:** forbidden-part overlap px, blade-outside-occluder px, edge crop px, adjacent-frame positional jitter and visual alignment. Do not turn one anecdotal 31px guide length or F5/F6 results into universal fixed thresholds.

## Application to current A53/A54

- A53 clean Godot architecture: Body (real 12-frame PixelLab, sword-free), optional independently selected weapon Iconset, HitMarker and AnimationPlayer timeline. The example's shield geometry is **not present** in the A53 barehand model, so we do **not** delete the A53 right arm or change F5/F6 on the basis of a different character's screenshot.
- On later shield-using FS actor/monster, evaluate the requested angle/pose with V0–V7; for A53 equipment, inspect hand-to-icon anchoring and any case where Body/Weapon should cross an occluder.
- A54's static resource contract and cloud CI are independent and preserved. A53 clean original GPU cold-timeout remains NOT RUN for A54 patched candidate; the A55 example does not fix it.
- Avoid making another paid PixelLab call until the exact failing frame/part and required visible guide have been proven on current source.

## Delivery & status

- Published as a **new GitHub branch** based on the A54 static fix, no changes to main, original paid provider images, Drive permission, A51/R4/A52/A53 source, or user PC work files.
- Contains a reusable manifest schema/example for two illustrative frames. Their statuses are `reference_only`, not FS native QA results.
- **A55 RULE REGISTERED / EXTERNAL REFERENCE UNDERSTOOD / ENGINE NOT RUN / ART HOLD**.
