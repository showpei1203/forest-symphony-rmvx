# FS Asset Factory v0.1 — **static-only** prototype

Owner: ChatGPT (Drive/GitHub). Codex is an optional executor for multi-file/native Windows operations. Gemini reviews art independently; PixelLab is a separate *authorized, cost-gated* generator. This folder is public source code, **never a repository for PMD/Actor source artwork**.

## What exists now
- \`validator.py\`: strict candidate-only validator for a sprite manifest or a four-layer map manifest.
- \`tests/test_validators.py\`: synthetic positive/negative examples constructed on the isolated GitHub Actions runner, no commercial game PNGs.
- \`.github/workflows/fs-asset-ci.yml\`: runs tests on Pull Requests.
- [Baseline Index](../../docs/asset_factory/BASELINE_INDEX_20261107.md): real FS authorities and evidence status.

**This does NOT** implement native PMD XML exporter, RPG Maker VX/Map050 or Tankentai SBS. It cannot certify human art quality, semantic occlusion correctness, nor engine import. Passing output is **PASS_STATIC_ONLY**, \`native_vx: NOT_RUN\`, \`formal_seal: NO\`.

## Commands (cloud CI / isolated ChatGPT runtime, **not user's PC**)
\`\`\`sh
python -m pip install pillow
python -m unittest discover -s tools/asset_factory/tests -v
python -m tools.asset_factory.validator path/to/manifest.json --root path/to/approved/source-root
\`\`\`
Exit 0 means static candidate PASS; exit 1 means at least one fail-closed Gate. Output is JSON to stdout. Do not redirect it into a user's-PC output folder. If a native Windows VX test requires temporary local files, obtain explicit approval first and verify cloud copy and cleanup afterward.

## Manifest v1 — a compact *candidate* format

### Sprite
\`\`\`json
{
  "schema": "fs-asset-candidate/v1",
  "kind": "sprite",
  "asset_id": "actor_example_synthetic",
  "frame": {"width": 16, "height": 16},
  "require_binary_alpha": true,
  "animations": [
    {
      "name": "walk",
      "direction": "SE",
      "expected_frames": 3,
      "frame_paths": ["a.png", "b.png", "c.png"],
      "require_distinct_adjacent": true
    }
  ]
}
\`\`\`
The 16×16 size is **only a synthetic fixture**, **not FS native**. Production Actor uses original sheet/SBS contracts; PMD animation-specific dimensions/frame counts come from the actual XML, not invented defaults. No inferred FPS, direction order, or pose family.

### Map
\`\`\`json
{
  "schema": "fs-asset-candidate/v1",
  "kind": "map",
  "asset_id": "forest_trial",
  "canvas": {"width": 1280, "height": 928, "tile_px": 32},
  "master_sha256": "full_64_character_sha256_of_runtime_full_ground_png",
  "layers": {
    "authoring_ground_only": "Authoring_GroundOnly.png",
    "authoring_complete_par": "Authoring_CompletePAR.png",
    "runtime_full_ground": "Runtime_FullGround.png",
    "runtime_occlusion_par": "Runtime_OcclusionPAR.png"
  },
  "collision": {
    "walkable": [[1, 0]],
    "spawn": [0, 0],
    "goal": [0, 0]
  }
}
\`\`\`
The example collision grid above is illustrative only. **Real grid must be exactly height/tile rows × width/tile columns**, e.g. 29×40 cells for 1280×928. Each value is 1 walkable or 0 blocked. Full master must be byte-hash locked. Complete PAR / occlusion RGB under alpha must match Master at identical XY. GroundOnly + CompletePAR must reconstruct Master RGB exactly; the native switch 203 and alpha semantics still require their own tests.

## Fail-closed gates included (not exhaustive)
- S_FRAME / S_DIMENSIONS / S_EMPTY / S_SOURCE / S_DUP_PATH / S_DUP_FRAME / S_ALPHA / S_NATIVE_COUNT.
- M_CANVAS / M_GRID / M_LAYER / M_DIMENSIONS / M_SOURCE_SHA / M_SOURCE_RGB / M_AUTHOR_RECOMPOSE / M_RUNTIME_RECOMPOSE / M_COLLISION / M_SPAWN / M_GOAL / M_REACHABILITY.
- In-root file paths only, no absolute/traversal source reference.

**Known missing**: asset ownership and per-object mask semantics, collision source ownership, frame pivot/silhouette/left/right-foot pose, PMD XML offsets/durations/shadows/8 directions, original Actor \`_1/_2/_3\` file mapping, native \`Game.exe\` and visual gate. All remain next-phase blockers and must never be reported PASS because these synthetic tests passed.

## No-cost first
No PixelLab generation, external paid API, or new user's-PC files. Stop any pipeline that needs privately licensed source images in GitHub Actions public logs/artifacts; those binaries must remain in private Drive and be validated by controlled private/isolated execution instead.

## Mandatory handoff
Before ending **every FS iteration**, write \`docs/asset_factory/CURRENT_HANDOFF.md\` on the feature branch or a new versioned handoff path; mirror a complete handoff in private Google Drive, list Git commit/PR, Drive file ID, source hashes, actually executed tests, errors, Art/Native/Cloud gates, and exact next step. A GitHub branch creation alone is not delivery. No merge into sealed \`main\` without reviewed and evidenced acceptance.
