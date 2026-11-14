# FS A04 Orca Independent Agent Taskboard (2026-11-08)

STATUS: Cloud task assignments prepared. New Orca agents NOT STARTED on A04. Historical Orca A36F R4 agents ran on 2026-11-07 and those outputs were read back, but are NOT A04 results.

## Security and storage gate
- Connected Windows DESKTOP-90VT437 with Orca 1.4.252 and Codex CLI installed; read-only current Orca process and historical R4 evidence verified.
- Historical Orca handoff documented CODEx YOLO permissions. Current approval mode cannot be confirmed from this connector. DO NOT launch a new write-capable agent until permission set to requiring approval. Git worktrees are not OS sandboxes.
- User's PC: no new persistent project, ZIP, report, test screenshot or worktree. Prior historical E drive files are read-only and must not be deleted. Native Windows VX may create temp files only after separate approval, defined scope and cleanup.
- Source artwork or licensed binaries remain private Google Drive. Public GitHub holds only source code, fixtures and nonsecret provenance. Never call PixelLab paid generation without explicit bounded authorization.

## Source contracts
- Draft PR #15: https://github.com/showpei1203/forest-symphony-rmvx/pull/15
- A03 source and gate Handoff: docs/asset_factory/CURRENT_HANDOFF.md
- A03 private real-source QA: https://docs.google.com/document/d/11fCR2Z6gmIAZzDTHZbnSse5jFwi4v0sVuYnj_mz1byg/edit
- Latest A04 native action compiler: tools/asset_factory/adapters/native_action_export.py
- A04 tests: tools/asset_factory/tests/test_a04_native_action_export.py

## Agent S1: SPRITE red-team reviewer (read-only)
Responsible for independent negative tests of Native PMD XML and Actor 3-keyframe exports; does not code or generate art.
1. For Idle/Walk exact XML FrameWidth/Height/Duration count, test wrong source SHA, wrong atlas row, wrong cell size and invalid CopyOf alias, wrong Anim/Offsets/Shadow composition.
2. For every patch, confirm seven untouched 8-direction rows are pixel-exact; one edited 45-degree direction is not equal to eight correctly designed rotations.
3. PMD 0001/0002/0003 per-species frame count differences; never conflate runtime PMD durations with FS Actor three-stored-frame _1/_2/_3.
4. Actor A62 approved run is 48px source only; missing original native 32px export, weapon anchor and full 45-degree art approval must remain pending.
5. A26 approved lava candidate must be checked with actual source file SHA. A25/A26 handoffs give old local source pointers; no verified matching binary in this iteration. Do not substitute original_0001 or rock_0001 for the accepted revision.
Required return: asset, action, direction row, source SHA, expected, actual, failing gate, smallest suggested change, negative-test evidence and exact artifact reference. No unapproved PC writes.

## Agent M1: MAP red-team reviewer (read-only)
Responsible for semantic occlusion and collision, independent of the Sprite Agent.
1. Use V3 Master-first 1280x928 as ONE specific source; never silently mix with A36H R3 or older A36F Orca R4.
2. Verify authoring CompletePAR all-object owners rather than accept four-object Runtime PAR mask coverage as equivalent.
3. V3 source-registered four-object Runtime PAR covers 118425 pixels with no overlaps; now find legal player walkable footpoints at roof eave, bridge or canopy boundaries.
4. Detect foreground tree masking a house error. Demand object-attributable alpha contributions and exact ON/OFF actor pixel diff.
5. Reject tolerance that permitted historical R3 nine-pixel hair clipping; a reviewed clear endpoint should have zero clipped actor pixels.
6. Native RGSS2 real_x/real_y animation-pattern transitions and Z-stack need separate Game.exe evidence. Constant foot_y minus 40 from A36F Orca R4 is not the semantic rule for V3.
Required return: object ID, world bounding box, source SHA and mask SHA, collision tile, actual visual discrepancy, reproducible before/after or NOT_RUN, gate and suggested smallest fix. No modifications.

## Native QA: ON HOLD
If a user-approved temporary Windows VX test is authorized, use an isolated Game.exe clone with clear cleanup and cloud upload. Compare switch 203 ON/OFF, real movement, exact pose/direction, z-order, and alpha overlap at every intermediate movement frame.
Without approval, NATIVE_VX_NOT_RUN; historical Orca R4: A36F 10/10 static and 4/4 dynamic in isolated rig, ART not sealed.

## ChatGPT Owner
Own GitHub feature code/CI, private Drive sources, approval ledger, failure taxonomy, visual reviews and versioned Handoff. Orca Agent S1 and M1 return independent challenge findings only; do not overwrite each other's files and do not promote assets.
A04 committed native compiler and 9 synthetic tests => 49/49 CI success run 42413705628 source commit e2056e0af774e0ff15125bd9f4ced31f68652e24.
12/12 real PMD Idle/Walk identity paste/recompose checks across original+variant ZIP sources in isolated runtime, without writing source. This was an independent real-data roundtrip test, NOT a direct run of committed exporter with new approved art.
ART PENDING / NEW NATIVE VX NOT_RUN / FORMAL SEAL NO / PIXELLAB 0 / MAIN untouched.
