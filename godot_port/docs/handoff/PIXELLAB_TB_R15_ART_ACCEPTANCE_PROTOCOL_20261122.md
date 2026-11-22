# Forest Symphony T-B｜R15 Real Art Acceptance Criteria (2026-11-22)

**Scope: MONSTER ART ONLY. No combat code, enemy registry, ATB, UI, camera gameplay change or edit to T-A/T-C/main.**

## Six previous monsters: R15 KO → REVIVE → IDLE repair

1. **First pose**: must exactly match the original R14 same-stage KO animation's last frame. Note legacy KO/Idle cell mismatch: BAT Stage1 KO128 vs Idle96; BAT Stage3 KO224 vs Idle192; FROG Stage1 KO128 vs Idle64. End Idle frame is centered on transparent KO canvas **without changing source pixels**.
2. **Final pose**: must exactly match original same-stage Idle F0, including canine-like? Not applicable; Bat eyes/ears/wings and Frog face/legs. **No frame may silently turn to show the creature's back** if its final Idle is SE 3/4.
3. **Continuous motion**: restore from defeated body posture without body splitting, detaching or adding arms/hands/legs/wings. Wings two, feet two for bats; four attached feet for frogs. No camera spin.
4. **QA**: PixelLab /v2/animate-with-text-v3 provider job IDs, complete original raw frame count, exported-frame sampling when provider echoes input frame n+1, unique frame SHA, actual alpha bbox, clipping, source SHA. A frame grazing edge is rejected and at most **two documented rerolls** permitted. Technical PASS alone does not authorize owner art acceptance.
5. **Side-by-side**: old R14 and new R15 genuine 3-stage frame contacts and frame-accurate animation GIFs. Preserve original R14 atlas byte-for-byte; release R15 under distinct filenames and manifest pointers, not destructive replacements.

## New original species: TB03 GLACIER JACKAL

- **Stage1**: one compact silver-blue canine, navy muzzle, cyan ice forehead crystal, ice blue eyes, four connected canine paws, thick dark tail.
- **Stage2**: mature larger same identity, added shoulder crystalline plates and chest fur, four legs, full torso, same fixed southeast 3/4 battle view.
- **Stage3**: legendary enlarged original same wolf family, high prism crystal crown, broad shoulders, deeper ice mane, original eyes/muzzle/tail/feet, unmistakably final stage.
- **Must be a real source chain**, not three independent prompt-only images: PixelLab Pixen Stage1 -> Edit-Image Stage2 from actual SHA-locked Stage1 -> Edit-Image Stage3 from actual SHA-locked Stage2. Preserve source SHA and jobs.
- **R15 initial genuine motions**: IDLE / ATTACK / HURT / KO, 8 frames each per stage = 12 clips / 96 frame slots. All source-linked via real v3 provider jobs. R15 does **not** call third species fully complete.
- **R16 needed remaining eight motions per stage**: GUARD, SKILL, RUN/LOCOMOTION, STUN, TAUNT, CHARGE, CAST RELEASE, REVIVE. Later 24 authentic PixelLab animation clips. For REVIVE use actual new same-stage KO Flast → Idle F0, not ungrounded movement.
- Two additional Stage1→2 and Stage2→3 ice-crystallization transitions: 16F source-exact original endpoint pixels and deterministic pixel effects, **not PixelLab AI morph generation**.

## Gates

- Source AI generated != accepted art. All new stages/motions **OWNER_ART_REVIEW_PENDING** until user approves images and frame-accurate GIFs.
- Godot actual version locked **4.7.2.stable.official.ed1daf0bf**; run native headless import and 9-stage artwork gallery logic, ensuring frame widths, imported texture refs, 84 authentic base clips + six separate FX transitions.
- New genuine PixelLab job lineage and true reported subscription generation count must be stored; never guess USD spend.
- Raster assets only in user-owned **private Drive**, GitHub T-B branch text code and Handoff only. ZIP sha, CRC, count, owner-only Drive API readback. Delete TEMP only after cloud verification, preserve original R14 ZIP.

> The strongest check is whether the creature still looks like the SAME creature throughout the action, not whether every PNG is nonempty.
