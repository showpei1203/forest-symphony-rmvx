# Forest Symphony B0 SCENE04 Height Benchmark — 2026-10-23
Status: B0_DUAL_ENGINE_ISOLATED_SMOKE_PASS_NOT_FORMAL

## Canonical asset registry, READ FIRST
https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit

Already indexed 170 Drive files and 9 leaf asset folders; **do not rediscover these every new chat**. All paths, file IDs, license gates and local cache source hashes are in the registry.

## Deliverables
- Complete test ZIP: https://drive.google.com/file/d/1qeoPSvbAW_0C_BC7ty37XMaxTwU1JQTe/view
- Current B0 handoff: https://docs.google.com/document/d/1OKPOtTf8j6__47wiDdHwoZk_aDjSHUgiDf1pjcRqrNs/edit
- Benchmark authority: https://docs.google.com/document/d/1Mv-ijuSH432yTd3ZtuK5Afj3daQYxuLTrKJYpGOAzI0/edit
- Windows original workspace: `E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023`
- One-click test: `RUN_B0_ALL.cmd`; machine JSON: `reports/B0_ALL_GATES.json`

## Verified
- 10 project-authored *test* source sprites; no restricted Hanzo art.
- Canonical 544×416, 17×13 tiles, 17 independent props, two height-1 plateaus, 2 designated stairs, water blocking, world-height aware stair edge validation.
- Ground/Par_COMPLETE/Par_BASE/Occlusion/Collision/Height derived from one manifest.
- 13/13 structural, alpha, height, collision/path, independent Tiled pixel and negative-injection checks PASS.
- Tiled vs Master RGBA zero pixels; Base + Occlusion zero pixels; malicious one-pixel sign offset detected as 102 pixels.
- Godot 4.7.2 with AMD Radeon RX 6700 XT GPU produced two native 544×416 screenshots, 7-step and 8-step plateau routes, actor back/front order.
- Genuine RPG Maker VX Game.exe in **isolated Project1 test clone**, 230 frames, stair both directions, cliff and water blocking; upper/lower screenshots background pixels match canonical Master exactly outside actor.
- Verified deliverable: 173 entries / 457,864 bytes / full ZIP CRC and internal SHA256; ZIP SHA256 `baa7f8274676b1630ed553ba42e602925f1fc2dc5cc88f4c10c001819595397d`.

## FAIL-CLOSED / pending
- No formal sealed Forest Symphony Scripts.rvdata integration yet.
- No human visual Gate F approval.
- Programmatic test art is not matching SCENE04 reference-level visual standard.
- No third-party Hanzo source approved for shipment.

Continue by cloning and hashing real sealed FS binary, testing adapter without modifying SEALED project, then building license-clear approved terrain/source kit and richer B1 ground3 scene. Never claim FORMAL PASS here.