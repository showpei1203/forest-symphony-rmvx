# FS Ground-first R1–R3 | 2026-10-30 | Controlled Ground-only research

**Status: GROUND_ART=FAIL / PAR=NOT_STARTED / FORMAL_SEAL=NO.** Existing K4/FS sealed runtime and assets remain untouched.

## Fixed Blueprint (544x416 native; 17x13, grid 32)
House A door (144,208), House B door (400,208), Sacred Tree root (272,304), main crossing (272,240), South exit (272,415), West (0,240), East (543,240). PDF variant A.

## Work actually performed
1. Generated another 1434x1097 high-detail forest concept, but it contains tall trees, posts and stumps and thus fails Ground-only.
2. R1 built a 544x416 Ground texture using multiple visually inspected grass-source patches plus original geometric road paths. Art fails from diagrammatic cobbles and uniform grass.
3. R2 changed road textures to exact 1x stone-source pixel patches. The 49px grass-block joins remain visible and art fails.
4. R3 uses dynamic minimum-error pixel seams. Measured patch-boundary contrast ratio improved from 1.305 (R2) to 1.0526 (R3), but this is a proxy for seams, not an Art PASS.
5. R3 QA shows 9/9 narrow structural checks PASS: dimensions, unchanged R2 road pixels, all six street anchors linked, Sacred Tree root unpaved, 2px and 16px metadata fault injections caught, stitch proxy under 1.15, no sealed FS writes.
6. Independent deterministic reruns of all 3 build scripts reproduced all three identical PNG hashes.

## File SHA256
R1: a232629effd765b9218ef82fb05c7cde0b5ac4daa2ce57921bdf1eaf8e623ce5
R2: 7b49119288a7448834989d1caf159f65a90e452eab3734b792f2c023737c8d08
R3: 50a2e9d145f3d24e573cc4b43e156fd95e53c31e440b2551541c1f7858e68b54
Private QA ZIP SHA256: cc5e76c9fdccf11645d26d73e20482538f61916cd0c19683143dffc659dfc11e; 8,763,496 bytes, 25 entries, CRC PASS.

## Hard limits
The three candidates are programmatic compositions from a generated source, not three native mask-conditioned AI generations. Source ownership was visually checked in local patches but not pixel-semantically certified. No PAR, no Godot/VX runtime validation, no user Art PASS, no formal seal. The private ZIP is NOT verified uploaded to Drive; GitHub records text only.

## Stop-loss and next step
Stop spending effort on patch-only ground texturing. Need actual FS SCENE21/ground3 private style refs, genuine mask/layout-conditioned or richer authored native Ground, Blueprint mask and contact constraints. Ground Art PASS must precede generating House A, House B, Sacred Tree native RGBA. Preserve user bottom-32px tree contact rule as A/B test.

NEXT_COMMAND: G0 original project references -> Ground-only controlled 544x416 new source image -> Art Gate A -> then PAR core objects.