# FS AI Asset Factory — CURRENT_HANDOFF A01 (2026-11-07)

> **This is the mandatory next-chat entrypoint for the Asset Factory track.** Never start over. Do not merge into sealed main or regenerate images without evidence. Full private Drive mirror: [A01 Cloud Handoff](https://docs.google.com/document/d/1gf1QVlNkx6oIzg7U38WfEp2l6gJeerx22jdNA7urJok/edit).

## 0. Execution status (separate the gates)
- **Cloud-delivery gate:** PASS for the GitHub code/baseline in this PR; private Drive Handoff mirror is a separate readback check.
- **Static unit gate:** **PASS, 14/14** synthetic tests on actual GitHub Actions runner, on tested code commit \`b42a75fe58f53e9261dd7ab2ce0b4395ce84e402\`.
- **Actual FS/PMD binary data integrity:** NOT VERIFIED in A01. Do not infer source SHA from historical Handoff prose.
- **Real production Sprite adapter / PMD XML support:** NOT IMPLEMENTED.
- **Map source ownership / geometry correctness:** NOT VERIFIED; synthetic source-registration tests only.
- **Windows RPG Maker VX Game.exe Native:** **NOT RUN A01**.
- **Human ART PASS / Formal Seal:** **NO**. This A01 phase produces tooling only.
- **PixelLab paid generation:** **NOT RUN**, zero authorized/new paid calls.

## 1. Fixed authority read order (do this in every follow-up)
1. [Cross-conversation Global Hard Rules](https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit): PC only needed installs/runtime. Any temporary user-PC work file requires advance scope, cleanup plan, and explicit consent.
2. [FS Current Rules Index](../../authority/FS_CURRENT_RULES_INDEX_20261107.md), [cloud-only rule](../../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md), [FS router](../../.agents/skills/fs-rmvx-router/SKILL.md).
3. [Drive Asset Factory V1 plan](https://docs.google.com/document/d/1p6OZ9TSG0kThKbrLqEN4ONKInBy4EM3eikqPzDBdYR4/edit).
4. [Baseline Index A01](BASELINE_INDEX_20261107.md), [tooling README](../../tools/asset_factory/README.md).
5. Latest per-track PMD/Actor or Master-first V3/A36H R3 source Handoff and approved Source Registry before touching assets.

## 2. Exact GitHub state
- Repo: \`showpei1203/forest-symphony-rmvx\` (**public**, do not commit private artwork/keys).
- Working branch: \`feat/fs-asset-factory-v1-20261107\` (created from \`main\`).
- Draft PR [#15](https://github.com/showpei1203/forest-symphony-rmvx/pull/15), **open / not merged**.
- Tested validator/test source commit: \`b42a75fe58f53e9261dd7ab2ce0b4395ce84e402\`.
- Actual workflow: \`FS asset static QA (synthetic only)\`, run ID \`42375943827\`, job ID \`128413412425\`; GitHub reports **completed/success**. Inspection of job log shows \`Ran 14 tests in 0.064s, OK\` and no remaining deprecated \`Image.Image.getdata\` warnings.
- Prior passing workflow run \`42375842290\` was on initial code and exposed Pillow API warnings; these were fixed and rerun.
- New files (branch only):
  - \`docs/asset_factory/BASELINE_INDEX_20261107.md\` — source/evidence locators with explicit unverified binary SHAs.
  - \`tools/asset_factory/validator.py\` — fail-closed sprite + four-map-layer static candidate checks.
  - \`tools/asset_factory/tests/test_validators.py\` — synthetic pass/fail set (14 cases).
  - \`tools/asset_factory/README.md\` — schema v1 and non-goals.
  - \`.github/workflows/fs-asset-ci.yml\` — automated cloud tests (PR trigger only relevant paths; no paid APIs/secrets).
  - \`docs/asset_factory/CURRENT_HANDOFF.md\` — this document.
- To repeat: run GitHub Actions / \`python -m unittest discover -s tools/asset_factory/tests -v\` in an isolated cloud CI, **not on user's PC**.

## 3. What source contracts mean
- Actor/SBS: original $actor01 3×4 walk sheet with 32px cells; battle at 45° with unarmed image and separate paper-doll weapon, **3 frames per action** / \`_1/_2/_3\`. Do not assume generic 8 directions × 6 frames from the PDF.
- PMD: native XML action-specific geometry, Duration/Offset/Shadow, 8 directions. A27 examples Idle 32×40×3, Walk 40×40×6, Attack 64×72×11; these are examples, **not global rules** and not complete approved 8-direction art.
- Map: new FS Elf Village is **MASTER-FIRST**; four distinct files: Authoring GroundOnly / Authoring CompletePAR / Runtime FullGround / Runtime OcclusionPAR. Runtime PAR uses Master RGB same XY only where actually in front of the actor. Collision and real switch203/native movement independently tested.
- Master-first V3: limited native tree exit/clear control PASS, roofs and art not fully accepted; A36H R3 is a **separate** 197-source visual candidate with art pending; do not merge their masters.
- Research PDF proposes reusable canonical format, templates, automated QA; its 64×64, 8-direction examples are *not* native FS authority.

## 4. A01 validator scope / known gaps
- Sprite: source within root, PNG RGB/RGBA, dimensions, nonempty alpha, duplicate adjacent images when explicitly required, optional binary alpha, animation/direction count.
- Map: exact dimensions, frozen full-master PNG SHA256, four layers, source-pixel RGB match under PAR masks, authoring composition, runtime composition, 32px grid collision, spawn/goals and BFS reachability.
- Explicit machine-readable outputs: \`PASS_STATIC_ONLY\` or \`FAIL\`; \`native_vx: NOT_RUN\`; \`user_art: PENDING\`; \`formal_seal: NO\`.
- Not yet present: approved native XML readers/offsets and legal source SHA pin, per-object tree/roof/bridge semantics, visual frame identity/rig/alternating feet, character weapon anchors, native \`Game.exe\` witness, full-grid scene semantics, master style approval.
- GitHub Actions runner uses only generated synthetic fixtures and Pillow; commercial/third-party assets remain PRIVATE Drive.

## 5. Next iteration **A02** exact task order
A. Use Google Drive connector directly to list the source-of-truth private PMD0001–0003 and Actor01 folders, identify actual approved PNG + XML, dates and authoritative latest Handoff. Compute/verify SHA of actual bytes **in isolated ChatGPT runtime only**, and update \`BASELINE_INDEX_20261107.md\`. Avoid guessing, exposing private asset contents or persisting source files on user's PC.
B. Write *real-data-backed* PMD XML metadata inspection and Actor export profile in \`tools/asset_factory/adapters\` using actual source geometry/action counts. Do not overwrite originals; no paid generation yet. Include fail-closed malformed XML and wrong frame-count tests in CI using **synthetic XML only**.
C. For map, add source ownership and object-level mask schema/validator while preserving Master-first RGB/XY; use *private* Drive binaries for a dry-run only if permitted and verified.
D. Do not run native Windows VX without explicit user approval for temporary local run files and cleanup. Do not try to solve bad art by just passing more pixel metrics.
E. Each A02 session MUST write a new versioned private Drive Handoff and update this CURRENT_HANDOFF pointer or file on an isolated branch, with actual CI run/commit, unresolved gates, rollback and direct links.

## 6. Access, budgets, and hard prohibitions
- ChatGPT is Cloud Owner, directly writes Drive/GitHub as available. Codex only when specialized multi-file/Windows execution is justified; Gemini independent reviewer; PixelLab generation only after **explicit batch credits authorization**, query existing jobs first.
- Last historical PixelLab balance: 1414.80 generation credits (NOT a fresh balance); A01 used **0** generation credits.
- GitHub public: code/synthetic fixtures/nonsecret metadata only. Google Drive private: all PNG/GIF/ZIP/XML and uncertain-rights art. Never paste API token into chat or repo.
- **No new user's-PC files or folders used in A01.** Existing historical PC files unchanged. An assistant-side isolated scratch directory was attempted for optional GitHub download/test; connection failed; it is **not** on the user's PC, and **did not replace** the actual successful GitHub CI.
- Stop if Drive or GitHub write/readback fails; never claim success based on intention.

## 7. New-chat handoff shortcut
**Read this file and linked A01 Drive Handoff before continuing.** Current task is A02 private source binary inventory → XML native contract → re-run CI → new cloud Handoff. Do not regenerate visual concepts, do not trust old local E:\\ paths, do not merge #15 into sealed main, and do not ask user to repeat the already settled storage policy. Any unverified Gate remains \`NOT_RUN\`/\`PENDING\`.
