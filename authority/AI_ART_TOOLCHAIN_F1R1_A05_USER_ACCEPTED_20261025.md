# FS F1R1 A05 — User Acceptance Authority (2026-10-25)

## Decision

The user replied **「驗證OK」** after the A04 native VX + Godot new-source Forest Symphony scene playable deliveries. This is explicit user acceptance of the **F1R1 A04 forest benchmark only**.

- Human Visual Gate for F1R1 A04: **USER PASS / APPROVED**
- Accepted F1R1 version state: **F1R1_REFERENCE_ACCEPTED** (frozen benchmark)
- Previous F1R1 A04 `HUMAN_VISUAL_PENDING` statement: **superseded by this decision**
- Existing FS sealed mainline, any other project's P1G/LPC or parallel FS art branch: **UNCHANGED**
- Uncompleted creature evolution chain/new houses/multi-level maps/paid API tests/commercial asset licensing: **NOT ACCEPTED**

## Exact immutable reference

A04 private playable ZIP: [FS_F1R1_A04_NEW_FOREST_VX_GODOT_NATIVE_20261025.zip](https://drive.google.com/file/d/1aETm97DkQs59joYpqBiX1KnqyzRV32qw/view?usp=drivesdk)

- SHA-256: `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`
- File bytes: 9,102,910
- Files: 176
- COLD QA: 22/22 technical assertions PASS
- Native RPG Maker VX RGSS2 `Game.exe` actually booted: `F1R1_VX_NATIVE_221_221_PASS`, 18 blocked + 203 walkable cells
- Native Godot 4.7.2 actual Windows machine physics: `F1R1_NATIVE_PHYSICS_221_221_PASS`
- ASF/Tiled/Godot native screenshot comparison: 0 RGBA pixel drift
- Source: 544×416 32px scene; new Ground derived from approved pixel-style sampling and deterministic patch quilting, **eight reused** approved private sprite objects
- Earlier unsorted F1 precursor **191px visual compile failure** remains an archived failure (NOT retroactive PASS)

## Acceptance record and Handoff (new, non-destructive A05)

- Drive [A05 user-acceptance handoff ZIP](https://drive.google.com/file/d/1UHs6eAZl5v-7_1_fzdKKul44-RB5V3Vl/view?usp=drivesdk)
- File: `FS_F1R1_A05_USER_VISUAL_ACCEPTANCE_HANDOFF_20261025.zip`
- SHA-256: `60371cbe71e614b80133d52f3fd66dbbedc037b980fc5471cd84e82119a90d8a`
- 6,278 bytes, 9 files; checksum and ZIP CRC checked. Original A04 9MB game test ZIP not duplicated.
- A05 includes `USER_ACCEPTANCE.json`, `CURRENT_HANDOFF.md`, `NEXT_CHAT_PROMPT.txt`, quick validation CMD, previous genuine native Godot/VX logs.
- Art commercial licensing remains a **separate** unresolved gate.

## Next actionable pipeline

1. **F2**: source-first original building and complex forest map, Ground walkable default / only explicit prop footprint, water/hole exceptions, house roof y-sort/collision. Distinct directory and NEW Gate A–F; use the accepted F1R1 as reference but never overwrite.
2. **P2 isolated 3-stage creature family**: consistent chibi archetype, juvenile/adult/final, separately generated/validated Idle/Attack animations, clip completeness, equipment/appearance coherency. Do not touch parallel P1G.
3. Existing PixelLab and SpriteCook SDK packages do not imply authenticated generation service. No purchase/paid calls without user approval.
4. Every test version needs ZIP/CMD/source/LOG/CURRENT_HANDOFF with Drive/GitHub/Linear status; don't promote a candidate from a machine-only pixel parity check to Human PASS.

**Acceptance authority is additive. Preserve all old ZIPs and failure reports for reproducibility.**
