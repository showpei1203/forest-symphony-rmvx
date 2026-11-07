# A02 source inventory — 2026-11-07
Status: **private source byte SHA verified / original PMD geometry verified / synthetic CI 29/29 PASS / native VX NOT_RUN / user art PENDING**.

This PUBLIC document contains nonsecret metadata and hashes only. Private images/XML/ZIP remain on Drive. Source-original native geometry does not promote lava variant art.

## Actual downloaded source ZIP and original XML SHA256

| Family | ZIP filename | ZIP SHA256 | Original AnimData.xml SHA256 | Concrete actions / aliases | 1-row / 8-row actions |
|---|---|---|---|---:|---:|
| PMD0001 | P3_R3_G2_NATIVE_GODOT_XML_PLAYER_20261026.zip | 23309b50c0a07a7321950407f0417bc501985ba5efe4f3b45472ad457582832f | c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162 | 34 / 2 | 13 / 21 |
| PMD0002 | P3_G4R1_PMD0002_VOLCANIC_STAGE2_20261026.zip | 309a19d3be249411e7ec9e2c3d546638a00660c7e34a76bf4c8ac5b373f46818 | e1c494c9d795980bb77622e8ce782b4fba62bd1e5103165351748dc3924702c0 | 12 / 2 | 1 / 11 |
| PMD0003 | P3_G5R1_PMD0003_FINAL_LAVA_EVOLUTION_20261026.zip | eee94e4fb8e388c5f685db53f36ef470e0088959d9b0a9a3bef3cae712578e97 | b5b556e42df4322440f63da430e918bbad794c83cdf58dbff2393138f96c15d3 | 12 / 2 | 1 / 11 |

Each non-alias action has actual Anim/Offsets/Shadow PNG present; PNG size matches XML width * duration count, height * 1 or 8 direction rows. The aliases Strike→Attack and Dance→Shake do not have separate atlases. These checks were performed against private ZIP bytes in isolated ChatGPT scratch, not by public GitHub CI.

## XML-native pilot contracts

| Species | Idle | Walk | Attack |
|---|---|---|---|
| PMD0001 | 32×40, 3f, 96×320 atlas | 40×40, 6f, 240×320 | 64×72, 11f, 704×576 |
| PMD0002 | 32×32, 4f, 128×256 | 32×32, 4f, 128×256 | 64×64, 9f, 576×512 |
| PMD0003 | 32×32, 4f, 128×256 | 32×32, 4f, 128×256 | 72×72, 11f, 792×576 |

Actual original Idle / Walk / Attack Anim PNG SHA256 in that order:
- PMD0001: bae238b6ae50dc97781a03b2210dc3ee1954c9f6207826e49091227bb9c783d1 ; 84e8e7a58f68204a47f990becc7e8c324e486e5127557261e8ccbe55e9e979b2 ; f8b6b5fc9132d9fb701741086bacfc0e80d0a8d2b45473abb425d4c6b427a252
- PMD0002: d251cbd9aaf3f9ff6ee6f6119a9ce87267e2548124fd499c0c62fe1083fc72b9 ; 294de55669bceca7e4c0904ce5f41203368c0f24261cedae09ed699cd2002576 ; cc976349dff5223caac3c4e1031c5606ac51102acbb3ef88670e428c36a4230e
- PMD0003: 53547ad2b27a60f270a9cd698ab53fe55df8352d6ebc54fecae955362d8563c3 ; 53547ad2b27a60f270a9cd698ab53fe55df8352d6ebc54fecae955362d8563c3 ; 6868234db16c2d0ae6c40caaca121f81e96d7c118951ab46eb88b7bbb287a69c

Original PMD0003 Idle and Walk happen to share identical bytes; this is original-source evidence, NOT a statement about approved evolutions.

## Actor A62/A63 private source lock

- FS_A63_REUSABLE_RIG_WAITING_W2_GIF_QA_20261102.zip SHA256: 154b3970778ab758008139b19e7dd15c62614c947889a66dd9b31d1e94ba9be9.
- REUSABLE_RIG/APPROVED_ACTOR01_SE45_F0_48.png: 48×48; SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba.
- REUSABLE_RIG/APPROVED_A62_RUN_3POSE_144x48.png: 144×48; SHA256 ea063e6ec2db5caf3bddb2dd0b277d888f60e65fe6392bccdad4fdcc34274d5f.
- User-approved A62 specific run motion is not approval of all actors/actions. 48px is a rig baseline, NOT the original VX 32px walking sprite nor native SBS PASS. Check newer A65 original-asset edit direction before changing actor artwork.

## New code / tests

- tools/asset_factory/adapters/pmd.py: native XML dimensions, duration/count, aliases, events, real 1/8-row atlas dimension checks.
- tools/asset_factory/adapters/actor.py: three stored keyframes, per-action playback and source lock. Actual identity, weapon anchors, motion and VX are still pending.
- tools/asset_factory/adapters/map_objects.py: private owner source SHA, complete and occlusion mask union, subset and no conflicting ownership. No real Master-first object run yet.
- tools/asset_factory/tests/test_a02_adapters.py: 15 synthetic cases; combined 29 tests PASS in GitHub Actions run 42376970935 at commit 9867c87cec72a67f8e65c9147ece0e58a689a5ff.

## Gates / no promotion

- PMD original source grammar: SHA and dimensions verified directly; newly coded adapter currently synthetic CI only.
- PMD0001 A25 appearance/A26 Idle-Walk were approved in their respective historical revisions, not by these original ZIPs.
- PMD0002/3 original format does not imply full-eight-direction lava appearance PASS.
- G19 192px monster candidate is NOT PMD-native.
- Master-first map V3 and A36H R3 stay distinct. Object mask static proof is synthetic; real object ownership, switch 203 and legal actor movement NOT_RUN.
- User-PC artifacts none; PixelLab 0; public licensed artwork none; draft PR unmerged; formal seal NO.
