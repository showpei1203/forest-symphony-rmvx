# FS SCENE21 v2.4 - Visual FAIL: forensic + mandatory source gate
2026-10-25 | Authority: v2.4 VISUAL FAIL / NOT PROMOTABLE | Sealed FS unchanged

## Confirmed regression
User's 546x443 screenshot has 544x416 scene matching v2.4 Master at 225637/226304 = 99.705% equal pixels, remaining 667 pixels only actor. `Game.ini` incorrectly says `Title=FS_STYLE_FIRST_V233_SCROLLING_VILLAGE`: cloned runtime build identification wasn't changed.

Generated asset source is a framed and captioned art gallery, 1435x1096 RGBA, with *no* alpha==0 or alpha==255 pixels. alpha min/max=(1,252). It is not valid isolated alpha source. v2.4 used 5 hand-picked rectangle crops, HSV-seeded OpenCV GrabCut, then deliberately clears top 2px and left/right 2px. Chapel alpha x>=180/187 is forcibly zeroed. Golden tree includes foreign adjacent flower and lower shrub fragments. Four of five extracts still touch their bottom bounds (opaque counts 182,73,70,56), not by itself proof of truncation but warrants review. No approved border exception was filed.

Ground is directly copied from v2.3.3's 544x576 variant, extended from v2.2 ground with a 192px rolled/dithered donor. No Ground-only semantic visual clearance for the new composition was performed. `woodland_flowerbed` GrabCut output with dark rectangular background was placed as `GROUND_DECAL` at x222,y247, so Ground is already contaminated.

5 new source ledgers say `CANDIDATE_NOT_HUMAN_ACCEPTED`; all 8 object manifests say `human_visual_gate=PENDING`. The build ignored those statuses, accepted them, and shipped an isolated Game.exe candidate. Native VX had not been executed in the prior QA. Master=Ground+PAR 0 diff, 1px negative shift, blocked/reachable counts are *technical consistency*, not visual integrity tests.

## Mandatory fail-closed pipeline, effective now
- S0 New asset generative contract: only full isolated transparent object (or native transparent modular parts), large 8px safe margin, no scene gallery/title/grid/overlapping objects. Art-gallery images may be style references only.
- S1 Ground-only: clean terrain source separately, terrain/walkability semantics and 100% Ground-only visual; no cropped vertical elements, decorative black rectangles or hidden material seams. Ground authoring must not inherit visual pass merely from old opaque files.
- S2 Object source integrity: parent witness, component checklist, no missing roof/branches/trunk/roots/windows/accessories, no foreign connected objects; edge-touch requires explicit visual exception. Never repair incomplete geometry by deleting alpha beyond an x coordinate.
- S3 Alpha QA: render each on black/white/magenta/checkerboard/real ground; check matte residue, foreign objects, boundaries, all 100%/200% native pixels. Allow segmentation tools only as mask candidates.
- S4 Approval: **build MUST fail if ANY source `source_visual_qa != VISUAL_APPROVED` or object `human_visual_gate != APPROVED`.** No pending art in a playable candidate without explicit marked visual test only; no PASS claim.
- S5 Compiler: Ground/PAR/Master/Owner/Collision/Occlusion/Height must share same approved Manifest. RGBA diff=0 is necessary, never sufficient. Ground-only and PAR-only must independently pass.
- S6 VX: Game.ini Title, build ID, ZIP, Manifest, asset SHA, loaded screenshots must identify same version; real Game.exe walking, collision, occlusion, camera scrolling tests.
- S7 Human Art: user visual signoff at 100%/200% and full scene after source/engine QA.
- S8 Handoff: private ZIP + tests + logs + provenance; verify Drive readback file size/SHA (not just metadata and not an earlier ZIP) before claiming backup complete.
- No expansion to 864x640, treehouses/bridges/Level0/1/2 until an isolated mini benchmark with Ground/1 building/1 tree/1 flower passes art, source and native tests.

## Demonstrated fail-first script
Local deliverable `FS_V24_FAILURE_FORENSICS_HANDOFF_20261025.zip` contains `fail_closed_source_gate.py`, source and screenshot forensic evidence. Against the issued candidate it returns **24 fail records**, including 8 scene-object and 5 source-approval records, not 24 independent art bugs. Gate does not claim it can visually recognize every incomplete silhouette.

Drive Authority: https://docs.google.com/document/d/10YAjj5nPNUwZxWz-9GOWxF3K-4ZEuM6kV3bH21e602M/edit
Related Linear: SHO-39.
