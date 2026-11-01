# A31 Handoff — Source-motion-preserving actor01 walk / native static idle, 2026-11-01

## User rejected A30
A30 Idle shoulder wobble and A30 Walk stiff/unnatural. No more free-form skeleton animation. A30 is ART FAIL.
Authoritative original E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters\$actor01.png and _1/_2/_3; original SHA-256 verified. 96x128 base sheet is 32x32 native cells in 3 columns and 4 direction rows.

## Exact original motion evidence
Right-facing row2 c0,c1,c2. In frame positions native feet bottom always y32, head top y1/y0/y1 and entire body moves coherently. Loop = c0-c1-c2-c1. Idle is SINGLE STATIC center c1 pose, NOT a breathing animation; A31 Idle purposely static. Original four normalized 40px source frames exist separately (copy offset x4/y6), every pixel retained from original.
Original exact source step adjacent changed pixels: [350, 384, 384]. Exact repeated center difference 0.

## Real PixelLab executed
A31 source animation outfit transfer using A29 unarmed approved-look candidate as outfit image and four REAL original source frames: job 233bd78d-4395-41c3-ac5c-c38bcaa39ec5, 10 generations; all four 40px PNG returned. This recreates clothing teal/gold while retaining ORIGINAL leg, arm, head-body pose structures.
Second pass /edit-animation-v2 on same FOUR coherently generated frames to correct sideways camera to diagonal southeast: job eb3a30f9-6f4d-4bbb-b8bc-a6ad31c23167, 10 generations. All four 40px PNG returned. It is a visually more diagonal candidate but not mathematically verified exact 45°.
Provider sometimes renders duplicated neutral twice with small differences. Final loop selects indices (0,1,2,1); source neutral frame1 reused byte-for-byte. No new poses invented. No per-frame pixel painting; all source motions originate from actual original source. No alignment required (all four feet naturally y38).
Final 4-frame SE45 candidate step changed pixels [426, 420, 420], last-to-first 426; ground line [38,38,38,38].
Idle = exact NEW center frame, no shoulder/body jumps. No weapon in costume source and poses; visual approval pending.
Both original provider raw streams stored. A30/A29 preserved. Original official actor01 files unchanged.

## User preview
A31_A30_FAILURE_VS_REAL_ORIGINAL_WALK.gif | original vs A30 fail vs A31 new
A31_NATIVE_ORIGINAL_VS_GENERATED_WALK.gif | original, transferred costume, diagonal edit
A31_FS_OUTFIT_TRANSFER_REAL_SOURCE_WALK.gif | first pass genuine 4 frames
A31_SE45_NATIVE_MOTION_WALK_LOOP.gif | final genuine provider + exact neutral repeat
A31_THREE_WALK_METHODS_NATIVE_VS_OUTFIT_VS_45.png | all phase strips
A31_IDLE_ORIGINAL_A30_FAIL_A31_STATIC_COMPARISON.png | idle static difference
A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png | one 40x40 PNG
A31_FINAL_QA.json | hashes/job IDs/art gates

## Gate
Real source provenance PASS, original motion phases PASS, four-frame geometry PASS, no vertical ground drift PASS.
User visual naturalness and TRUE 45-degree southeast ART PENDING. Full Tankentai SBS paper-doll overlay NOT RUN.
Credits A31 20 generations; ending 1812.8/2000. No retries.
