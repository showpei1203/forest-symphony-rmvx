# FS Sprite-Gen Toolchain | CURRENT HANDOFF | 2026-11-23
Branch: feat/fs-sprite-gen-toolchain-20261123 (created from feat/fs-pixellab-tb-monster-20261121).
Scope: T-A/T-B offline atlas QA and runtime format only; T-C Ground/PAR unchanged; no formal art or gameplay promotion.

## Actually completed
- Windows installer under allowlisted PC Bridge, source pin bb3be7b127d46de237e0b4e03f026be4fd207da6, sprite-gen 4.3.0, Python 3.11.0, Pillow 13.0.0, NumPy 2.4.6. PC owner Windows Issue #108 and Actions #45171329220 SUCCESS, CLI five verbs smoke checked.
- Extra Issue JSON field security negative #107 rejected correctly, issue run failure expected.
- FS branch Python adapter validate_atlas.py: preserves raw source and atlas, checks structural integrity, outputs source SHA references and art_gate=HOLD Godot sidecar.
- FS branch FSSpriteGenAtlas.gd: read sidecar and create SpriteFrames using exact atlas regions, per-state FPS, duration and loop.
- Python synthetic four-case QA locally PASS: valid, out-of-bounds reject, frame count reject, blank-alpha reject. Files and matching dedicated Python tests committed.
- Synthetic Godot native test script added. As of this handoff the new importer native smoke on the owner PC has not yet been executed; don't claim PASS until Windows runner publishes independent result.

## Nonpromotion / unresolved
- No real approved ACTOR01 paper-doll underpaint or 12F new attack, T-A still ART HOLD.
- T-B R19 real art-only native success is separate, still human ART HOLD and not FSBattle/ATB/ACT integrated.
- This tool does not create correct art from flattened missing data. No Codex/Grok/provider generation requested.
- No copied private raster in public GitHub. Owner private Drive stays source-of-truth for raster.
- Godot 4.7.2 new sidecar importer native NOT_RUN until verified separately.

## Next bounded unit
- Add narrowly-scoped PC Bridge synthetic adapter native task; re-read source branch pin, run Python unittest and Godot 4.7.2 installed binary, check explicit PASS markers, log Issue/Actions.
- After technical PASS, only then test a copy of ONE approved private existing T-B atlas into private Drive QA (not upload to public GitHub). Human visual gate remains HOLD.
- Main/T-A/T-B/T-C branches and E: originals remain untouched.

## References
- PC bridge #107 https://github.com/showpei1203/chatgpt-pc-bridge/issues/107
- PC bridge #108 https://github.com/showpei1203/chatgpt-pc-bridge/issues/108
- Full integration contract godot_port/docs/toolchains/FS_SPRITE_GEN_TOOLCHAIN_20261123.md
