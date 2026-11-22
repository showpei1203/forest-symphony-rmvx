# Forest Symphony | T-B R14 FAILURE LOG | 2026-11-22

1. **SCRIPT_RELEASE_NAMESPACE_SHADOW (FIXED)**: After all 18 provider jobs succeeded, first R14 Python private bundler crashed `AttributeError: 'dict' object has no attribute 'godot'` because loop over evolution stage accidentally rebound original `argparse.Namespace a` to a stage dict `a=stages[source_i]`. Fixed to explicit `src_stage,dst_stage` local variables, commit `bec0fda3ab0ca1f89acd26d36e586b7618513881`. **No re-generation, no cost, no false pre-fix release**. Reran exact same locked input assets; official Windows Godot 4.7.2 editor import PASS (exit0) and native 76-clip/680-slot QA PASS (exit0). ZIP only uploaded after successful rerun.
2. **PIXELLAB PROVIDER**: 18 real jobs completed; no provider 429 or rejected job in this run. Every job user subscription usage reported 3.0 generations, **54.0** total. Each 10/9/11-frame atlas with zero border pixels and distinct nonempty frames. Zero additional PixelLab cost for Python correction.
3. **ART GATE, STILL OPEN**: Actual three-stage contact inspection shows Leaf Bat REVIVE mid-animation facing too far away from original southeast 3/4 lock; likely a true visual blocker despite engine PASS. Frog REVIVE pose also needs GIF review. Do NOT mark ART PASS nor quietly overwrite previously locked assets. Review one bounded re-generation only if approved in next revision.
4. **EVOLUTION FX**: Four 16F procedural transparent source-to-successor transitions; only endpoints use original exact pixels. This is intentional 2D VFX, **not true PixelLab morph generation**. Explicit provenance in manifest and QA; don't aggregate into AI-generated frame count.
5. **NATIVE RENDER LIMIT**: Godot headless import and frame-count/playback logic were actually run on official Windows native 4.7.2, but no fresh R14 non-headless screen capture was produced. Must not claim full visual ART approval or 45° battle camera verified.
6. **P0 STORAGE**: Genuine private Google Drive ZIP now verified via Drive metadata (shared=false), file count/CRC and SHA256 `07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575`. Temporary user-device staging still to be deleted after readback; R10–R13 preserved. Close after running `cleanup_tb14_ephemeral.py`.

No combat system, T-A, T-C or main modifications. No public GitHub raster files.


## P0 / replay closure
- **P0 temp cleanup CLOSED/VERIFIED**: after true Google Drive owner-only metadata and byte-size readback, cleaned seven named R14 ephemeral outputs and revalidated original ZIP SHA256. All R10-R13 sources and the user-owned Drive originals preserved.
- **Replay fixed**: patched release orchestration's pinned builder commit to verified `bec0fda3ab0ca1f89acd26d36e586b7618513881`; now source-controlled R14 replay no longer selects the first crashed namespace-shadow version.
- Open sole review blockers: R14 new ART gating (Bat Revive locked-facing, Frog Revive orientation and Evolve FX style); no PixelLab provider or Godot engine blockers.
