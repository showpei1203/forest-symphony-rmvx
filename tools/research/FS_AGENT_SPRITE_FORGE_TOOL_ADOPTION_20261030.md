# FS Shared Game Asset Tool Registry | Agent Sprite Forge (2026-10-30)

## Classification
Tool: Agent Sprite Forge (ASF) by 0x0funky. Source: https://github.com/0x0funky/agent-sprite-forge
Upstream pinned revision (local clone): `5324342fdfab72430f4e9604f3fe427009f8596d`
Code/documentation license: MIT. Generated image/video ownership and commercial terms are determined separately by the producing model/provider; only licensed or original game art may enter final FS/PMD/CG assets.
Status: **ADOPTED IN ISOLATED TOOL LAB; LOCAL CODE ART SMOKE PASS; IMAGE-TO-VIDEO / GROUNDPAR QUALITY / ENGINE IMPORT NOT YET VERIFIED.** This is not a formal art or game build PASS.

## Local installation (remote Windows DESKTOP-90VT437)
- Read-only upstream checkout: `E:\GameAssetToolLab_20261023\tools\AgentSpriteForge`
- Five isolated skills: `E:\GameAssetToolLab_20261023\ASF_SkillRegistry_20261030`
- Skills: `codeart2d`, `generate2dmap`, `generate2dmedia`, `generate2dsprite`, `video2dsprite`.
- Installer copied 164 files; `tools/install_skills.py --check --dest ...` returned **in-sync**; Python `compileall -q` exit 0.
- Environment observed: Git 2.56.0, Python 3.11.0, Pillow 12.3.0, NumPy 2.4.6, ffmpeg 9.0.2. No global Codex/Grok skill installation and no paid API calls.
- Offline sample: render_pixelspec with upstream `slime.pixelspec.json`, strict QC = **PASS**, green/blue/red variants, 3 unique frames, 10 files, zero failed and warned checks. Output: `E:\GameAssetToolLab_20261023\ASF_Test_20261030\slime-smoke`. This only proves code-drawn asset pipeline, not AI consistency.
- `pytest` was not installed in existing system Python; full upstream automated test suite NOT RUN.

## Intended use
1. **FS R17 ground-first map experiment**: `generate2dmap` can supply candidate Ground-only reference/art, transparent reusable props, map metadata, exports to Godot/Tiled/LDtk. Treat ASF as an upstream asset producer only. Preserve the latest R17 Ground/PAR authority, pixel-crisp requirements, common blueprint/manifest/coordinates, object feet/door anchors, semantic occlusion and collision; use our own deterministic Ground/PAR compiler and strict RGBA comparison. Stage13 GROUND ART FAIL and GROUND/PAR INTEGRATION FAIL remain unchanged.
2. **PMD monster families**: `generate2dsprite` one approved master per distinct species, then `video2dsprite` for idle/walk/run/attack/hurt, consistent palette and anchor; visible species anatomy/silhouette changes are mandatory, not merely recolours. Retain original/licensed art provenance.
3. **VX / LPC / Tankentai SBS actors**: treat output frame grids and durations as candidate only. Verify original VX size, actor foot pivot, facing direction, separate equipment/weapon registration and RGSS2 runtime compatibility. Godot exports do not imply VX compatibility.
4. **Godot/game export**: Aseprite JSON, Godot SpriteFrames and PNG atlas may be adapted only after actual editor imports and game capture.

## Nonnegotiable integration rules
- Never modify SEALED FS Scripts.rvdata, Map.rvdata, PMD, LPC or CG artifacts; use isolated test-only copies.
- Never regenerate Ground and PAR independently from text prompts and assume alignment. One shared scene blueprint and source positions must govern both layers; keep PAR semantic roles, actor occlusion and collision independent.
- Do not treat a sprite-movie extraction as proof of consistent anatomy or pixel-art quality. Required review: contact sheets, source/provenance SHA256, alpha, palette, nearest-neighbor quality, fixed frame/canvas dimensions, feet/pivot, weapon attachment, attack timing, looping and style match.
- Paid API key or signed-in CLI may trigger quotas/spend; require deliberate choice before calling any generation route. Offline code-art fallback must be accurately identified as code-drawn.
- No project-wide adoption or FORMAL PASS from one smoke test; inspect actual engine output in Godot and native RPG Maker VX and obtain visual approval.
- Upstream states 0.4.0 exports are parse-verified but not independently opened in all target editors. Verification is part of our acceptance gate.

## Acceptance tasks
- ASF-A01 repository clone, exact commit provenance: PASS (2026-10-30).
- ASF-A02 local skill installation, hash manifest, syntax compile: PASS (2026-10-30).
- ASF-A03 codeart2d PixelSpec strictly verified example: PASS (2026-10-30).
- ASF-A04 1 original Q-style character, 6 actions, 32x32 / project-native fixed canvas, native Godot and VX actual rendering: NOT RUN.
- ASF-A05 PMD evolution/species A-B visibly differentiated (silhouette, face/anatomy, accessory), >=4 frames each, 0 clipping and timing checks: NOT RUN.
- ASF-A06 FS R17 approved art kit + rich 544x416 Ground-only candidate, separate full PAR and canonical scene manifest; Ground-only no floating structures, user art fidelity, semantic anchors, VX/Godot: NOT RUN.
- ASF-A07 full upstream pytest + editor import check, resource/cost and licensing audit: NOT RUN.

## Handoff / next action
Begin with A04 and A05 in the isolated lab; do not displace existing R17 Ground-first development. For maps, use ASF as an alternate candidate art/prop maker, not a replacement for R17 authority. Record inputs, scripts, command lines, output hashes, failure categories and human screenshots. If any gate fails, classify FAIL and revise only the isolated source artifacts. Tool adoption must not be confused with art acceptance.
