# Stage 16 A05 — Categorized failures / stop rules
1. Source style vs generated style divergence: Ground3 32px actual sample has fine dense multicolor texture. A05 grass output has smooth neon round artifacts.
2. Geometry ≠ semantic material. Binary inpaint mask and exact composite truly preserve spatial domains, but the model still paints green dirt instead of sand in specified road.
3. Pass1 outside green RGB proxy 40.14% -> 90.50% is NOT art-quality score. Do not use hue or number of changed pixels as aesthetic success.
4. R2 with IPAdapter: target road regenerated but sand-like RGB proxy 60.82% -> 30.11%; greenish sand fragments. ART FAIL.
5. R3 control with IPAdapter disabled *only* for road: sand-like proxy 19.31%, green-like 77.47%; solid green blobs even worse. Simple reference-bias-only hypothesis disproven as sole explanation; one A/B trial isn't general proof.
6. Pixel-exact masked compositing creates precisely preserved boundaries; it may exacerbate hard, unnatural seams. Human visual Gate remains independent of 0-pixel regression.
7. CPU reference conditioning ~55–63 seconds per 384x384 inpaint step, DirectML full IPAdapter crashes natively per A04; no GPU PASS claims.
8. No native VX Game.exe / Godot rendering or PAR/collision; ART FAIL means Formal Seal NO. No sealed source edit.
9. Preserve actual SHA ledger, source input, AI outputs, API workflow JSON, masks, QA and 32px nearest previews in private 38-file ZIP; no complete ground3 composite or model weights on public GitHub.
10. A06 new test must target *material conditioning* not more prompts; use domain-specific source references and a real model spatial guidance, with native 32px acceptance.