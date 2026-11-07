# FS AI Asset Factory — CURRENT_HANDOFF A02 (2026-11-07)

> **Mandatory next-chat entrypoint** for the Asset Factory workstream. Do NOT restart A01, overwrite sealed FS / main, generate aesthetic concepts without a real source/art brief, or mistake static QA for VX/art acceptance. Previous [A01 Drive Handoff](https://docs.google.com/document/d/1gf1QVlNkx6oIzg7U38WfEp2l6gJeerx22jdNA7urJok/edit). New **[A02 private Drive Handoff](https://docs.google.com/document/d/10co8RTL-WXb2fhiiExLOfxmoasTg8kgjl7wb9rcnvXw/edit)**; its content and placement in Forest Symphony/05_Handoff require readback to confirm.

## 0. Hard rule priority
1. [Global cloud-first storage rule](https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit) — GitHub/Drive persist, not user's PC. Never create local persistent worktrees or ZIPs on user's PC. Any necessary Windows temp files need separate prior approval and cleanup.
2. [FS rules index](../../authority/FS_CURRENT_RULES_INDEX_20261107.md), [cloud policy](../../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md), [FS router](../../.agents/skills/fs-rmvx-router/SKILL.md), [private Asset Factory plan](https://docs.google.com/document/d/1p6OZ9TSG0kThKbrLqEN4ONKInBy4EM3eikqPzDBdYR4/edit).
3. [Baseline Index A01 + A02 delta](BASELINE_INDEX_20261107.md), [A02 actual private-source SHA metadata](SOURCE_INVENTORY_A02_20261107.md), [tools README](../../tools/asset_factory/README.md).
4. Check latest PMD/Actor user-approved/failed candidates, A65 original-image modification decision and V3 vs A36H R3 map Handoff before touching any images. Do not upgrade historical approvals by inference.

## 1. Real executed work
- Repo: showpei1203/forest-symphony-rmvx (**public**: only source code, synthetic test fixtures, nonsecret provenance hashes).
- Feature branch: feat/fs-asset-factory-v1-20261107. PR [#15](https://github.com/showpei1203/forest-symphony-rmvx/pull/15) **Draft/open/unmerged**. Main/sealed art not altered.
- New production-facing modules (separate adapters; still static-only):
  - tools/asset_factory/adapters/pmd.py: exact per-action XML contract and species-specific native atlas sizes, Duration, Rush/Hit/Return frames, CopyOf aliases, one-row and eight-row Anim/Offsets/Shadow. No generic 3f/8dir.
  - tools/asset_factory/adapters/actor.py: 3 keyframes _1/_2/_3, source SHA, frame geometry, playback loop; semantic footstep/weapon/45° not automatically approved.
  - tools/asset_factory/adapters/map_objects.py: private source SHA per object, binary mask equality, subset/union, no multiple object ownership. No semantic occlusion or Master RGB approval.
  - tools/asset_factory/tests/test_a02_adapters.py: **15 positive/negative synthetic tests**, plus A01 existing 14.
- Actual GitHub Actions **run ID 42376970935**, job **128416449077**: **completed/success**, source commit **9867c87cec72a67f8e65c9147ece0e58a689a5ff**; log **Ran 29 tests in 0.056s, OK**. Subsequent documentation-only commits are not implied to be the same workflow run; inspect current PR head/latest Actions before final reporting.
- **PixelLab 0 new calls, user's-PC 0 writes; no private source art was committed.**

## 2. Important real-source binary breakthrough (not merely a plan)
Private Drive originals fetched into isolated ChatGPT runtime, SHA256 calculated from actual ZIP bytes, XML parsed and Anim/Offsets/Shadow raster sizes independently checked (not just historical handoff):
- PMD0001 original_0001: 34 concrete actions, 2 aliases, 13 single-row / 21 eight-row; ZIP SHA 23309b50c0a07a7321950407f0417bc501985ba5efe4f3b45472ad457582832f; XML SHA c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162; Idle 32×40×3, Walk 40×40×6, Attack 64×72×11.
- PMD0002 ORIGINAL_0002: 12 concrete, 2 aliases, 1 single / 11 eight; ZIP SHA 309a19d3be249411e7ec9e2c3d546638a00660c7e34a76bf4c8ac5b373f46818; XML SHA e1c494c9d795980bb77622e8ce782b4fba62bd1e5103165351748dc3924702c0; Idle 32×32×4, Walk 32×32×4, Attack 64×64×9.
- PMD0003 ORIGINAL_0003: 12 concrete, 2 aliases, 1 single / 11 eight; ZIP SHA eee94e4fb8e388c5f685db53f36ef470e0088959d9b0a9a3bef3cae712578e97; XML SHA b5b556e42df4322440f63da430e918bbad794c83cdf58dbff2393138f96c15d3; Idle 32×32×4, Walk 32×32×4, Attack 72×72×11.
- Actor A63 source ZIP SHA 154b3970778ab758008139b19e7dd15c62614c947889a66dd9b31d1e94ba9be9; approved A62 reference F0 **48×48** PNG SHA a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba; approved A62 3-pose 144×48 strip SHA ea063e6ec2db5caf3bddb2dd0b277d888f60e65fe6392bccdad4fdcc34274d5f.
- [Full action and exact PNG byte hashes](SOURCE_INVENTORY_A02_20261107.md). Original native ZIPs are grammar/evidence baselines; not proof that user-approved *new* lava art passed eight-direction.
- Original PMD0003 Idle and Walk source PNG were byte-identical, not a new-generation achievement.

## 3. Gate matrix
| Gate | A02 |
|---|---|
| GitHub delivery / branch | PASS for checked-in source, draft PR |
| Synthetic unit static | PASS 29/29 on verified Actions run; final branch commits need latest CI recheck |
| Source ZIP/XML SHA | PASS, actual private bytes for original 0001/0002/0003 and A63 |
| Original PMD Anim/Offsets/Shadow atlas geometry | PASS independent private scan |
| New committed adapter execution over the private ZIPs | NOT_RUN; **do not equate synthetic 29/29 with this** |
| PMD0001 user-accepted A25 look/A26 Idle+Walk | Historical limited approvals only; not eight-direction |
| PMD0002/0003 evolution chain visual identity | PENDING |
| Actor native Tankentai/SBS, 32px runtime | NOT_RUN |
| Master-first source Master object-level real sample | NOT_RUN (A02 module synthetic only) |
| VX Game.exe + switch 203 movement / occlusion | NOT_RUN |
| User art approval for new sheets/maps | PENDING |
| Formal seal | NO |

## 4. Next exact stage A03
1. Check CURRENT_HANDOFF and latest user artwork decision. Do NOT use an out-of-date 40×40/48×48 *candidate* as the actual native 32px sheet without explicit export/visual validation.
2. Add a **private ZIP native scan runner** that calls the *same committed* pmd.py inspect_pmd_assets on PMD0001/2/3 original actions; produce JSON gates and source SHA evidence only in private Drive. No licensed art to GitHub.
3. Pin latest approved PMD0001 A26 Idle/Walk candidate sources separately from original PMD ZIP. Try narrow action-level compiler with native XML, 8-direction identity gate before batch generation.
4. Use A62 approved recipe with **existing original Actor reference** and latest A65 user instruction to modify rather than regenerate; verify true _1/_2/_3 and proper unarmed 45°.
5. Map Master-first V3 source + one tree/roof object + negative clear area: actual source ownership and per-pixel masks. Never merge V3 with A36H R3; do not let ground vegetation leak into Runtime PAR. Real switch 203 + VX only after user-PC temp-scope authorization.
6. Keep PixelLab authorization per batch with fixed credit ceiling, but no paid job is implied here.
7. At end: new versioned private Drive Handoff, GitHub CURRENT_HANDOFF, Source Inventory, Actions run/commit/QA source evidence, ART/NATIVE/FORMAL status, rollback.

## 5. Rollback / safety
- To roll back A02, revert only the feature-branch commits adding adapters, tests, A02 metadata and this handoff. A01 branch checkpoint stays. **Do not force-reset main**.
- Private Drive source ZIPs remain original, unmodified. Public PR contains metadata but never source PNG/XML/ZIP.
- If readback/CI fails, mark as failed, never claim formal delivery or act as if next step auto-runs.
