# T-A Failure Log / 2026-11-21
Only record genuine issues; never conflate construction QA with ART PASS.

| ID | Gate | Severity | Finding | Attempts | Next macro action |
| --- | --- | --- | --- | --- | --- |
| TA-01 | ART | BLOCKER | Old A35 RUN frame F6/F7 pose previously on ART HOLD; optical flow preserving those poses cannot eliminate source pose drift | 0 new repair iterations | Rebuild one **entire** RUN12 by PixelLab Text V3 with reference identity, use Skeleton V3 keyed gait if needed |
| TA-02 | ART | BLOCKER | RUN candidate independent Weapon/FX atlases are all-transparent **placeholders**; no sword-to-hand contact proved during run | 0 | Full RUN12 complete equipped sword layer at 45° view |
| TA-03 | MODEL | BLOCKER | No PixelLab paid endpoint available to this agent; fresh Text V3/Skeleton V3 generation NOT RUN; additional cost 0 | 0 | Obtain connected PixelLab provider authority or run same exact source in authorized provider tool |
| TA-04 | NATIVE ART | BLOCKER | New native GitHub CI has synthetic memory atlas proof, not original Drive asset runtime/GPU screenshot | 0 | Secure private, authorized Godot asset staging for 1× screenshot/video and contact play |
| TA-05 | SOURCE | NOTICE | A54 updated handoff not located by this round's Drive/GitHub name/path searches | 0 | Confirm A54 authoritative link before replacing legacy approved baselines |
| TA-06 | ENGINE | RESOLVED | 12-frame rig timing/3-layer structure needed independent validation; added Godot 4.7.2 CI; first run success | 1 | Keep CI green after preview scene and do full original-art validation later |

Nonblocking isolated pixels/soft shadow tuning: 0 cycles; no endless single-frame loop. The demonstrated initial RUN frame count and technical 256×192 atlas check are not art acceptance.
