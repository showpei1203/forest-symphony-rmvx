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


## A02 additions (2026-11-07)
- adapters/pmd.py: inspect genuine AnimData.xml (CopyOf alias, species-specific action frame size/count/durations/events), require native Anim/Offsets/Shadow matching dimensions with 1 or 8 actual raster rows. It does NOT force all actions to three frames or assume every atlas is eight rows.
- adapters/actor.py: validate a candidate action has three stored _1/_2/_3 PNG keys and an explicit playback loop; original VX walk 32px and approved A62 48px motion candidate remain separate.
- adapters/map_objects.py: fail-closed owner Source SHA and binary complete/occlusion mask membership, overlap and union proof. Occlusion semantics and original Master source registration remain separate gates.
- tests/test_a02_adapters.py: 15 new synthetic positive/negative fixtures, combined 29/29 successful Actions run 42376970935 on source commit 9867c87cec72a67f8e65c9147ece0e58a689a5ff.
- [A02 actual-source inventory](../../docs/asset_factory/SOURCE_INVENTORY_A02_20261107.md): ZIP/XML/selected PNG SHA and original action-specific native metadata, **no protected artwork**.

Private approved source downloads and bytes belong to Drive/isolated runtime, never public Actions artifacts. Every pass here is STATIC ONLY. User art, 45° identity, per-object occlusion semantics, Tankentai/VX native and formal seal remain independent PENDING/NOT_RUN.


## A03: private-data offline source checks (2026-11-08)
- adapters/private_zip_scan.py scans a SHA-locked PMD ZIP entirely in memory, never extracts entries to a user's PC, fails closed for wrong SHA, ZIP path traversal, duplicate names, missing AnimData.xml / native Anim-Offsets-Shadow files or invalid species-specific geometry. Input is **private Drive ZIP bytes in an isolated runtime**; outputs contain only source metadata, never source PNG/XML/ZIP.
- adapters/runtime_masks.py validates one real Master-first 32px-grid Runtime FullGround + Runtime OcclusionPAR pair against individually SHA-pinned object mask files. All Runtime PAR alpha must be owned by exactly one binary mask. The overlay RGB must equal the same Master XY under alpha. This **does not validate the entire Authoring CompletePAR object list** or infer walkable-footpoint roof semantics.
- tests/test_a03_private_runtime.py adds 11 synthetic positive/negative tests, for a total of 40 with A01/A02.
- An actual isolated scan using the *same committed source blob* was run against 6 historical private PMD folders (116 action atlases / 348 native PNG checks) and Master-first V3's 4 object runtime masks (118,425 owned pixels, no overlaps). It also checked the A62 approved 48px running-reference strip. These are **source-static tests, not engine/art approval**.
- [A03 official private source QA](https://docs.google.com/document/d/11fCR2Z6gmIAZzDTHZbnSse5jFwi4v0sVuYnj_mz1byg/edit) and [A03 official private Handoff](https://docs.google.com/document/d/1YtPce0j-Sy86H335TuLdeGDMEgFFkQ0QdvroAHBjPIo/edit). Current [A03 active Handoff](../../docs/asset_factory/CURRENT_HANDOFF.md) separates true-private-source, synthetic CI, native and art gates.
- Any A26 approved lava Idle/Walk binary that exists only in old local documentation must be recovered and source-locked independently before export. Original PMD native source names/geometry are not substitutes for approved art.

CI on public GitHub uses only generated synthetic pixels. Any real-data runner is **local to isolated ChatGPT scratch/private Drive**, not triggered automatically by a public PR. No PixelLab API is called by these scripts.
