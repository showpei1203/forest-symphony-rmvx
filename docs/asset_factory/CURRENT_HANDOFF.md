# FS AI Asset Factory — CURRENT_HANDOFF A04 (2026-11-08)

**Entry for next chat.** This supersedes active A03 execution status, but A01/A02/A03 remain immutable historical stage records. Don't restart old research, don't merge PR #15, don't generate concept-only images.

## Authority / evidence
- Global Cloud-Only P0: https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit
- Production rules: main/authority/FS_CURRENT_RULES_INDEX_20261107.md; main/.agents/skills/fs-rmvx-router/SKILL.md.
- Repo: showpei1203/forest-symphony-rmvx, branch feat/fs-asset-factory-v1-20261107; [Draft PR #15](https://github.com/showpei1203/forest-symphony-rmvx/pull/15), no merge to main.
- [A04 private Drive full handoff](https://docs.google.com/document/d/1uutNu7PzEveBqeohO8ltuIeNU4hbP5bdZ80FSej1Fj0/edit)
- [Orca S1/M1 independent adversarial tasks](ORCA_A04_TASKBOARD_20261108.md).
- [A03 private actual-source QA](https://docs.google.com/document/d/11fCR2Z6gmIAZzDTHZbnSse5jFwi4v0sVuYnj_mz1byg/edit), [A02 exact PMD SHA inventory](SOURCE_INVENTORY_A02_20261107.md).
- [A03 handoff](https://docs.google.com/document/d/1YtPce0j-Sy86H335TuLdeGDMEgFFkQ0QdvroAHBjPIo/edit).

## Verified A04 actual work
1. Added tools/asset_factory/adapters/native_action_export.py: in-memory PMD action atlas compiler; checks source SHA for every native input, authentic original per-action XML width/height and Duration length, accepts ONLY explicit native row indexes, requires actual per-frame Anim/Offsets/Shadow triplets, never auto-rotates or resamples. Protects all untargeted native rows at decoded RGBA pixel level. Rejects CopyOf alias as an independent action. Returns PARTIAL CANDIDATE status, art/direction/native not certified.
2. Added tools/asset_factory/tests/test_a04_native_action_export.py with 9 synthetic positive and intentional-fail tests, combined total 49. Actual GitHub Actions run [42413705628](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42413705628), source commit e2056e0af774e0ff15125bd9f4ced31f68652e24, completed SUCCESS, log Ran 49 tests in 0.083s, OK. New docs have been committed after this run; latest PR-head CI must be checked separately before calling the final HEAD green.
3. Independent real private-source atlas identity roundtrip in isolated ChatGPT container. Six ZIP source families (PMD0001 original_0001/rock_0001, PMD0002 ORIGINAL_0002/VOLCANIC_0002, PMD0003 ORIGINAL_0003/VOLCANIC_0003) × Idle/Walk = **12/12 PASS**: actually parse native XML, crop an original row, paste it into the same exact row for each of Anim/Offsets/Shadow, verify all decoded RGBA bytes exactly equal and every other row untouched. This was independently implemented as a real-data geometry/roundtrip check, NOT the claimed actual execution of the new GitHub native_action_export with approved lava artwork. No new approved sprite sheets resulted.
4. Read-only connected Windows (DESKTOP-90VT437) inspection: Orca.exe running, existing E:\FS_ORCA_PILOT_20261107 files inspected. Historical dual Codex Agent A36F R3/R4 findings verified from handoff; R3 9 hair pixels false-positive accepted due <=12 tolerance, R4 isolated VX 10/10 static and 4/4 move, art NO. This historical data is independent from V3 Master-first; never merge their masks/claims.
5. Orca task board written to public repo: [A04 Orca independent QA](ORCA_A04_TASKBOARD_20261108.md). Agent S1 = Sprite native action adversarial review, M1 = Map semantic/actor collision adversarial review, Native tester only after separately approved PC temp scope. Both new Orca agents **NOT LAUNCHED THIS STAGE**. Old Orca pilot documents report CODEx YOLO permissions; current Orca UI approval status cannot be confirmed from connector. DO NOT let an unsandboxed autonomous agent write user's PC. Worktree != OS sandbox.
6. The documented historical location E:\GameAssetToolLab_20261023 was read-only inspected and currently contains tools/Pixelorama only. Cloud Drive filename search for exact A26 private ZIP and candidate Idle/Walk did NOT return the binary. A full E: search had time limit, so do not assert the files definitively do not exist. The approved A26 lava Idle/Walk original private binary remains SOURCE_NOT_VERIFIED and must not be faked with original_0001 or rock_0001.

## Gate matrix
- New exporter synthetic CI: PASS 49/49 on recorded source commit. All later documentation-only commits need final-head CI check.
- Real source original direction-row identity roundtrip: PASS 12/12 in isolated execution, NOT official exporter over newly approved art.
- Real accepted A26 lava source binary: SOURCE_NOT_VERIFIED.
- PMD 8-direction *new* creature art: PENDING; original native geometry checks exist from A03 only.
- Actor A62 historically user approved moving loop; 48px source not native 32px VX/Tankentai; no new Actor art.
- Map V3 four-object source ownership static PASS in A03; all Authoring CompletePAR object ownership and legal eave player-footpoint scene semantics PENDING.
- Orca new Agent S1/M1: NOT_LAUNCHED; historical Orca R4 work is NOT A04 execution.
- New Windows VX: NOT_RUN; user art new asset: PENDING; Formal Seal: NO.
- New PixelLab use: 0. Main unchanged. User-PC new persistent working files: NONE.

## Next A05
1. Try a focused authorized recovery of real A26-approved lava Idle/Walk sources with exact SHA. If missing, stop repeating same scan, open missing-art exception, use newer clearly labeled approved baseline only if independently verified. No fake originals.
2. After Orca Agent permissions can be confirmed to require approval, run S1/M1 **read-only, independent** QA tasks against the cloud branch and private per-asset evidence; no new PC worktrees or outputs. Report precise exceptions.
3. Exercise actual native_action_export.py with real private bytes in isolated container; a strict no-op or one-direction sample is a TECH/FORMAT proof only. First new art exporter requires real approved per-direction source, not fabricated rotations.
4. Generate separate Authoring CompletePAR full owner masks; test a real legal-actor footpoint along a roof eave/bridge/canopy and clear negative. Native Game.exe only when PC scope and cleanup explicitly approved.
5. Final CI on latest HEAD, GitHub and Drive Handoff readbacks, exact source SHA and status split. Stop blind retries or PixelLab credit burn.

## Rollback
Revert ONLY A04 feature-branch commits when necessary; keep A01-03 history and private Drive original artifacts. No main overwrite. Never use public PR to store licensed PNGs, XML or ZIP.
