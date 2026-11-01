# A27 Pmd 6 action SE trial + FS actor01 1:1 animation
2026-11-01. A25 PMD volcanic design, A26 PMD Idle/Walk animations and A26 FS native 1:1 swordsman visual ACCEPTED BY USER.
A27 followed this approval: generated PixelLab Attack, Charge, Hurt, Faint 5-frame PNGs, source A25 approved PMD one-frame PNG, no original asset overwrite.
Idle & Walk approved from A26. NEW four generated actions await user art review. Detached rock blobs from Attack/Hurt automatically filtered by largest connected animal component; raw provider strips preserved untouched.
Created 6 full native-format PMD action PNG atlas candidates with only row1 Southeast replaced, re-timing 5 provider frames to native frame counts Idle3 Walk6 Attack11 Charge10 Hurt2 Faint4. Other seven directions unchanged from legacy G9 and do not match current approved new PMD character. XML/Offsets/Shadow NOT overwritten, so formal PMD engine integration DOES NOT PASS. Faint last frame needs 33px vs native 32px width and loses one pixel: FAIL pixel-crisp gate.
A27 FS both Idle and Attack are native 40x40 PixelLab animation tests using EXACT A26 user-approved Pixen chibi 1:1 frame. Their action and clipping QA in A27_CURRENT_QA.json. These new animations are not yet user approved. FS SBS sheet _1/_2/_3 not modified or integrated.
Preview A27_PMD_6_ACTIONS_FS_TWO_ACTIONS_MOBILE_REVIEW.png; private ZIP available locally.
No third party PNG uploaded to public GitHub. Only code, QA and handoff docs. More complete work requires real eight-direction visual mapping, and proportion stability over full attack/cast/hurt/death FS.

## Final Visual Gate and Quota Readback (same stage)
- New FS Idle native 40x40: 5 real frames, chibi ratio visually stable and no bottom-edge clipping, user review pending.
- New FS Attack native 40x40: TECHNICAL PASS but VISUAL FAIL. No discernible sword slash or satisfactory blade continuity; action mostly arm/hair/cape shifts. DO NOT import to formal Tankentai/SBS. Research skeleton/key-pose control rather than repeat same generic text animation.
- PMD Attack / Hurt generated detached rock fragments. A27 largest-8-neighbor-component filtering removes these in clean candidates, leaving true provider raw outputs intact. User visual gate pending.
- PMD Faint native frame width32 vs final generated bbox width33; 1 pixel would be clipped. FAIL CLOSED for pixel-perfect native Faint until repaired.
- A27 provider charges verified 4 PMD actions at 1 generation each + 2 FS actions at 1 each = 6; account 1860 -> 1854 of 2000. No retries.
- Preserve approved A25 volcanic PMD and A26 FS native 1:1 character and A26 PMD Idle/Walk as sealed visual baselines.
