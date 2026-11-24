---
name: fs-ta-pixel-expression
version: 0.1.0-research
status: documented-not-auto-installed
scope: Forest Symphony T-A ACTOR01 R26+ 64x64 pixel expressions and head pose
---
# FS T-A Pixel Expression & Head Pose Skill (R27, 2026-11-25)

## Mandatory source and non-negotiables
- Before ANY T-A work, re-read latest `godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md` and R26 genuine PixelLab authority on `feat/fs-pixellab-ta-actor-20261121`.
- Approved A62 F00 original 64x64 sprite SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`; white hair, green/charcoal clothes, 45deg south-east combat view. Preserve F00 exact RGBA and preserve original hidden outfit source as UNKNOWN, not inferred.
- **R26 provider SUCCESS:** PC Bridge issue #133 fixed source/token/balance GET, #134 no-cost validation, #135 `estimate-skeleton` 18 points for 0.1 generations, #136 `animate-with-skeleton-v3` four real NEW F03/F05/F07/F09 64px RGBA for 3.0 generations (total 3.1). Never replay jobs #135 or #136. Full private source: `https://drive.google.com/drive/folders/10r8kphLlS0ludVAN0uPzMPdVpGd8eRYL`. GitHub R26 commit `1a700f304efd7164d80a57949da007e3b9b25770`.
- R26 **TECHNICAL PASS, USER ART REVIEW PENDING**. F03 arm stretch, F07 unclear hit/grip, F09 sword below feet all need review. R19-R25 prior art rejected. R26 new art full Godot/FSBattle NOT RUN. Do not present skeleton/QA as art success.
- User wants head motion INCLUDED in the *future pose model*. R27 is RESEARCH and zero-cost dry-run only; **no new PixelLab output, no approved head/face artwork, no Godot change**.

## Learned practical rules (original synthesis, not third-party code)
1. **HeadPose and FaceExpression are separate.** HeadPose: use existing PixelLab Skeleton v3 18 labels, specifically NOSE, LEFT/RIGHT EYE, LEFT/RIGHT EAR plus NECK. Eye group can move together by approximately 1 source pixel while relative facial geometry remains constant. Do not fabricate API fields like `head_rotation`, `fixed_head` or `emotion`; source schema wins.
2. **R26 failure explanation:** Actual private R26 job shows face five labels unchanged in all 4 target poses, while NECK X shifted only. Accordingly no explicit head turn was authored. The model may redraw face pixels anyhow; never claim pixel-perfect static face from coordinates alone.
3. **Expression art should be restrained at 1x.** Plan neutral, focus (F03), effort (F05), impact focus (F07), recover (F09). For tiny 64px body sprite, a 1–2 pixel eyebrow/eyelid change may be enough. If face is unreadable at 1x, choose head silhouette or 128px separate dialogue portrait instead of inventing tiny features.
4. **Keep identity across frames:** hair silhouette, eye spacing, skin/garment palette, 45deg camera, head-to-neck connection, ground anchor. Hair follows head/recoil, no random 1px shimmer. Avoid jumping expression every frame; switch while blink/impact, not for no reason.
5. **PixelLab official strategy:** estimate source skeleton → manually check direction → genuinely generate full-body pose from one reference → inspect real 1x → optional masked correction for single head/hand ROI. Editor Fixed Head/Freeze features documented for editor, NOT necessarily REST Skeleton v3 request fields. Confirm current REST schema before any paid call. Never use generic high-res image downscaling as game art.
6. **No tool fantasy:** Aseprite `mcp__aseprite__...` Linked Cels are useful but not connected/validated in this chat; third-party Scenario/SpriteCook need their own integrations and may bill. Don't install/re-run anything just because a Skill says so. R26 real provider route is fixed allowlisted GitHub PC Bridge in PRIVATE repo, token never revealed, request locked, journal-before-POST, no automatic billable retry.
7. **QA gates separate:** SOURCE SHA; Skeleton 18 labels/face vectors; transparent 64x64; exact F00; palette and pixel alias QA; eye/ear/head oscillation at 1x; visual hand/weapon/sword angle; PRIVATE Drive provenance/job/usage; HUMAN ART gate; Godot 4.7.2 native and full FSBattle are separate later checks.
8. **Preview owner FIRST:** show true transparent 1x, nearest 4x, head crop ~8–12x, F03/F05/F07/F09 plus independent weapon composite, GIF; show defects explicitly. Never add costly expressions/12F before owner's visual approval.

## R27 zero-cost head model candidate (not a real generation)
- F00 reference: unchanged (0,0). Relative to the existing R26 target keypoints, move all five face landmarks rigidly: F03 (-1,+1), F05 (0,-1), F07 (+1,0), F09 (0,+1) source pixels; NECK moves 0.5 times the same offset; body joints unchanged.
- Model semantic expression tags: `neutral`, `focused`, `effort`, `impact_focus`, `recover_neutral`. These are planning metadata, not API payload fields.
- Validate with `ta_r27_head_motion_dryrun.py --receipt <PRIVATE_R26_JOB_RECEIPT> --out <LOCAL_QA.json>`; source-locked input, all 18 labels, negative tests, no network/no costs. **Do not publish PRIVATE receipt/joint coordinates on GitHub**.

## References genuinely reviewed
- https://github.com/ForestSenYT/concept-to-pixel-assets/blob/main/SKILL.md ; `references/character-pipeline.md` (head block integrity, expression transitions, blink, low pixel density); its own default 96x160/Unity are NOT FS defaults.
- https://github.com/willibrandon/pixel-plugin/blob/main/skills/pixel-art-animator/SKILL.md (Aseprite linked cel / frame duration / tags; integration not verified).
- https://github.com/ervareza/agent-skill-pixel-art/blob/v4.3.0/skills/pixel-art/SKILL.md ; `references/animation_principles.md` (palette QA, pose-to-pose arcs, native preview; generic color caps not forced on A62).
- https://github.com/scenario-labs/skills/blob/main/skills/scenario-sprite-animation/SKILL.md (frame order, spritesheet QA; do not replace working PixelLab provider).
- https://www.pixellab.ai/docs/tools/animate-with-skeleton ; https://api.pixellab.ai/v2/docs ; https://www.pixellab.ai/docs/tools/inpaint ; https://www.pixellab.ai/docs/tools/edit-animation-pro (verify live cost/schema, not 1:1 API equivalence).

## End of each stage
Write ACTUAL work evidence + source/QA/ART status + provider usage (or ZERO/NOT_RUN), Failure Log, GitHub T-A Handoff, private Drive file receipt and Linear SHO-38. If shared skill is not loaded automatically on Windows, load the GitHub SKILL.md explicitly. Never pretend skill registration or runtime tests happened just because file was committed.
