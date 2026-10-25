# FS v2.7 Native Game.exe Screenshot Acceptance — 2026-10-25

On authorized Windows DESKTOP-90VT437, launched the existing **isolated v2.5 Game.exe** without altering the sealed project. Windows `PrintWindow`/`GetDIBits` captured real 550×445 game window frames, overcoming the previous OS screenshot issue (Chrome covering the game). Excluded the first RPG MAKER VX startup splash. Four subsequent stable 544×416 viewport images (`REAL_VX_01` through `REAL_VX_04`) were compared pixel-by-pixel in all RGB channels with `(0,0)-(544,416)` of the source-built `Master.png` (544×576).

| Frame | Different RGB pixels | Diff bbox (inclusive) | Outside actor ROI |
|---|---:|---|---:|
| 01 | 535 | x258..283, y348..376 | 0 |
| 02 | 535 | x258..283, y348..376 | 0 |
| 03 | 535 | x258..283, y348..376 | 0 |
| 04 | 535 | x258..283, y348..376 | 0 |

**PASS only for real native initial camera background registration.** No uncontrolled image difference outside player footprint. Actor occlusion from multiple sides, blocked movement, scrolled camera pixel identity, and user art acceptance remain pending. Thus RELEASE remains BLOCKED. Do not elevate this to FORMAL FS scene PASS.

The actual screenshot and audit script are retained on authorized Windows at `E:/FS_V25_S0_NATIVE_TEST_20261025/`. A portable generic comparator and handoff ZIP are available in the user conversation. Drive Handoff: https://docs.google.com/document/d/1wCMT71d-_eqMVF4eSU2LDe39kSc6DrzlHtOT-nx2jT0/edit

Baseline FS v2.1/v2.2/v2.3.3/SEALED unchanged; v2.4 remains visual negative witness. Next focus: real-path movement and camera scrolling with actor masks at each frame, not just initial viewport.