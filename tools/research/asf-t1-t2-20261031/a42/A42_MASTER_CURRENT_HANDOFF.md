# FS A42 CURRENT HANDOFF / master action skeleton testing (2026-11-01)

## Authorities, do not regress
- FS original source and Tankentai SBS sealed; no original FS/PMD game file overwritten during A41–A42.
- A37 Dodging **T4** is USER-SELECTED third-frame variant, must NEVER silently revert to old T3.
- A31 Walk original rhythm accepted, FS humanoid sprites require **exactly 3 stored frames per action**, 40×40 tests -> 120×40 1-row RGBA.
- Camera native FS actor01_1/_2/_3 south-east 45°; all three frames independently assessed for head, face planes, shoulders, torso, hips, feet. One 90° profile = Camera FAIL.
- All animated person sprites **unarmed**. SBS paper-doll system overlays weapons; ignore the original image's weapon when transferring pose.
- A40 real PixelLab /estimate-skeleton supplied 18 labeled humanoid joints; quadruped/PMD monsters not restricted to human joints.
- PixelLab raw outputs and source-anchored assemblies are distinct assets; never misrepresent a source-locked substitution as a raw provider generation. PixelLab gen3 re-renders first frame.
- Scripts need pre-POST submission locks, SHA and actual PixelLab job readback. No uncertain retry.

## A40 Severe Critic Damaged — evidence baseline
Real v3 job c0f23f1e-15a0-419a-a819-cb7a2c94cda6. Three controlled 18-joint severe poses, F2 shows head/shoulder/hip sinking and knee buckling. Source-anchored art **CANDIDATE**; human 45° identity and SBS engine not fully accepted.
Drive: https://docs.google.com/document/d/1spKklH9MXSA583hcGP3t7u8JgcLmXePNIT2PjJSUarU/edit

## A41 Normal Damage — R1 semantic failure, R2 improvement
Real gen3 R1 job d6c10beb-bf89-42b0-a01d-cff847ff9cf2 (2 gens) gives F1 horizontally outstretched arms, **SEMANTIC FAIL** (looks like attack/cast).
Real gen3 R2 job dd62eb1a-85b3-49da-9f8d-b01bd4a0cb32 (2 gens), constrained both hands near torso, brief hit flinch and exact original F2 guard.
Real F1 plus source-anchored F0/F2 yields exactly 3 frames and 120×40 native pixel art; 45°/user approval still **PENDING**. Quota 1699.7 →1695.7.
Drive: https://docs.google.com/document/d/15M301wAXiM9Kzl4VaQUyRrHHlUlMqHTHefIShFOhMQ4/edit
GitHub: https://github.com/showpei1203/forest-symphony-rmvx/tree/test/asf-a41-normal-damage-3frame-skeleton-20261101/tools/research/asf-t1-t2-20261031/a41
Visual comparison: https://uploads.linear.app/d746c4c3-5c2a-4d27-bd14-654c2574ba67/43a7565d-d13c-4abd-9b49-05e736a84af9/24caac6e-8735-4386-b55d-c6e337a7771e
Private 27-file ZIP: https://uploads.linear.app/d746c4c3-5c2a-4d27-bd14-654c2574ba67/53a574eb-a0bd-4b26-8ac0-f8eccf34b2d1/f5fe776c-3e1c-4fc6-b810-dd7432ed80c4

## A42 Moving to Close Attack
Real gen3 job 7aaaa250-1076-41e6-86f1-e3f05e7054e5, three 40×40 raw images, 120×40 source F0 anchored in-place approach candidate, 2 generations. PixelLab step sizes remain subtle; camera and action art **PENDING**.
Crucial: WORLD-SPACE travel toward the enemy must be controlled by Tankentai SBS script, not baked into frame images. As of A42 no actual VX/Tankentai SBS engine script modifications or runtime tests. User must not be told engine PASS.
Drive: https://docs.google.com/document/d/1qRCRUGHMjozNdtE75NY4ZdFPlEIp0dLeXCkVjZEm36k/edit
GitHub: https://github.com/showpei1203/forest-symphony-rmvx/tree/test/asf-a42-approach-3frame-skeleton-20261101/tools/research/asf-t1-t2-20261031/a42
Real frame preview: https://uploads.linear.app/d746c4c3-5c2a-4d27-bd14-654c2574ba67/5093a671-6231-4acb-8001-5f184494a629/b8ff086e-4800-49a9-a5d8-cfd1f6044978
Latest private ZIP **V2**, 17 files (contains all scripts and shared bone rules), 43664 bytes, SHA256 7452c81c440fc010871b538dcc5b4868050da58b9ded0474954dba1859c799ee:
https://uploads.linear.app/d746c4c3-5c2a-4d27-bd14-654c2574ba67/8a38febc-350d-4ab1-8a61-00c3767492db/33e85f9b-0435-4f84-a606-6db871356a2f

## Balance readback
A40 1699.7, A41 R1 1697.7, A41 R2 1695.7, A42 1693.7 /2000, all real job IDs read back completed, **6 gens** charged in A41–42.
Original FS/PMD and A37 T4 unchanged.

## Next action gates
1. Visual review A41 R2, A42 in-place movement for precise 45° camera, anatomy and no weapons.
2. Consider A42 approach exaggerated yet plausible stance with real PixelLab skeleton and 3-frame-only visual; avoid flying/twisted limbs or 90° face.
3. Before promoting approach to formal SBS, implement a separate world-space approach/retract animation in a disposable VX/Godot test build and test paper-doll weapon anchor, collision, return to home.
4. Only once the user art and engine gates PASS may update formal game sprites. The other 16 reference actions remain unapproved until individually tested.
