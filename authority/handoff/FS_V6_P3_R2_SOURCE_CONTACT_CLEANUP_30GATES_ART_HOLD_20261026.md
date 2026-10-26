# Forest Symphony V6 P3 R2 | House Contact Semantic Cleanup | 2026-10-26

**State: TECH 30/30 PASS. VISUAL SOURCE/CONTACT HOLD. HUMAN ART PENDING. NATIVE VX NOT RUN.**

## What actually changed
- R1 source house `OCHRE_HOUSE.png` 261×183 had 34,346 nontransparent pixels including roof-adjacent/bottom baked original meadow and dirt. R2 rebuilt a cleanable asset with separate architecture and flowers/accessories RGBA ownership masks, preserving all pixels within the retained geometry exactly (no blur, no AI redraw, no donor-block insertion).
- Removed **6,501 alpha-owned baked-ground/background pixels**. The underpaint exposed beneath is **unchanged Ground B**, verified on pixel arrays, not synthesized a second unrelated ground.
- Produced `HOUSE_R2_CLEANED_ALPHA_CANDIDATE.png`, original and removed-pixel semantic masks, `BEFORE_AFTER_CONTACT_1X.png`, 3× nearest close-up, and a three-way R1→R2→R2+shadow comparison.
- Authored two optional **independent** pixel-crisp contact shadow layers derived only from lower silhouette edges: SHORT=265 pixels, SOFTLONG=506 pixels. Original `GROUND_B.png` bytes and `GROUND_OPAQUE.png` unchanged. Neither shadow has obtained human aesthetic approval.
- Same source-first Scene Manifest world XY/foot anchor still emits separate Ground, PAR Complete, Pixel Owner, actor Y-sort previews and collision. 15/221 cells blocked by house/tree contact, house front tile and soft flora walkable; reference true VX Actor1 32×32 visible 28×32.

## Evidence
- P3 R2 QA 30/30 PASS: owned RGBA exact, removed pixels exactly 6,501, removed underpaint reveals unchanged original Ground, architecture+flora recompose to the same cleaned house, all original non-house pixels identical, no alpha canvas clipping, shadows decoupled from Ground, collision still correct, and negative source/shift regressions.
- Original house SHA256: `4362a04a19f95ea2aec5b3ff1b9a82f5a1f6d7394e58ae5d13181c8cc4944b6b`; cleaned house SHA256: `30f9369e95bc64e354f834dfa3057776de9c85c05cdba03c0b8c6fd38693ccc9`.
- Ground B PNG SHA256: `359581dfc2d9393f040ebca5d2b00d9802de9db8361f52e796fc4a818a0f2aa6`. R2 compiled main composite PNG SHA256 `745ace89729305430ee5a12d4e421e29b706130ed8f995308075d294e101dd0b`.
- **Cold independent extraction:** 58 hashed source/output files verified; then full repair/compile/shadow/QA rerun (30/30), identical compiled composite SHA.
- Private ZIP: **11,879,435 bytes**, SHA256 `a03126c3df18ebd0ca0c72609c6c9b81bd33ab30e2e9a403f01d375e0d93f268`.
- [Private Google Drive ZIP](https://drive.google.com/file/d/1JTpWzknqWIWTjHT0ESc4iciMXAfhQOnC/view). Windows G: Desktop Drive and the connected Drive connector independently verified ZIP size; connector-downloaded ZIP SHA also matches.
- [Google Drive visual comparison document (three embedded images)](https://docs.google.com/document/d/1Y1kj5heEH7ou6HfONArPr2_PW1f8e4wBO3sGZG6v88A/edit).
- Reproducible code: `tools/fs_map_v6/repair_house_contact_semantic_r2.py`, `tools/fs_map_v6/compile_p3_r2_source_scene.py`, `tools/fs_map_v6/build_contact_shadow_candidate_r2.py`, `tools/fs_map_v6/qa_p3_r2_contact_regression.py`.
- Local isolated workspace: `E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026\P3_R2_CLEAN_HOUSE_CONTACT_20261026`. R2 cold verification in sibling `P3_R2_COLD_VERIFY_20261026`. Run `RUN_QA.cmd` on Windows.

## Defect classification and fail-closed gates
- **FS-ART-106 HOUSE BAKED UNDERPAINT**: remediation removes 6,501 background pixels without altering underlying Ground or original kept RGBA. Now candidate; remaining polygon/clipped fine stems and foliage-to-Ground transitions may still be visibly artificial. Do not write ART PASS.
- **FS-ART-107 CONTACT EDGE**: preserving full house props and removing source grass can leave a high-contrast flower/step boundary. Two separate source-anchored shadow prototypes are review-only; no blur or screen-space image-patching.
- **FS-ART-105 SOFT FLORA SEGMENTATION**: previously extracted GrabCut alpha for standalone flower cluster needs final pixel ownership and human review, separate from house flora and ground.
- **FS-ANIM/VX RUN**: native Game.exe, RGSS2 event sprites, camera scroll, real foot collision and runtime memory are NOT RUN; any claiming PASS from static image masks is invalid.
- No mutation of F1R1 A04 sealed, FS Scripts.rvdata or the other map-development conversation.

## Next action
P3 R3: refine flower bed/stem edge under 1× and 4× visual comparison, choose if any contact shadow visually helps. After full source art human review, proceed to user-authorized/native FS manifest compiler and true Game.exe walk/depth/camera check. Do not scale this 17×13 scene to 40×29 by repeated stamping.

V6 overarching style authority: https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit