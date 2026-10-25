# F2_R3 + P3_R2 | 2026-10-26 Source-First Production Handoff

## Rejected and accepted
- F1R1 A04 forest benchmark remains USER_ACCEPTED / frozen, SHA256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`.
- Earlier F2 plain geometric cottage / wrong house source **ART FAIL**; P2R1 geometric creature **ART FAIL**; P3 slight tint **ART FAIL**. None are promoted. Preserve prior archives unchanged.
- F2_R3/P3_R2 both **human visual gate pending**, separate from technical checks.

## F2_R3_ELF_VILLAGE_STYLE
- Actual visual authority: user's uploaded `SCENE21(2).png` elf-village concept, dense forest foliage/flowers, hand-carved organic cottage, moss roof, stones, arch details.
- New richly detailed, 1448×1086 static elf cottage forest illustration already generated in conversation, isolated as `F2_R3_ELF_VILLAGE_STYLE_CONCEPT.png`. Its original RGB SHA256 `0686cc3a9cd9e59f4032c58fdfd917cebce36ce33b94fe9db5da8cf6e7`.
- Delivered user-conversation downloadable [F2_R3 concept ZIP](sandbox:/mnt/data/F2_R3_ELF_VILLAGE_STYLE_CONCEPT_HANDOFF_20261026.zip) 5,587,720 bytes, SHA256 `4f99eeadb426c746f8527fd6adaccde23c80868f2d902a6f58b59dee8bf0330b`, includes original concept, user's reference, source-cropped house detail, comparative board, conceptual door annotation, rule update, manifest, runnable static QA, handoff.
- **Important:** static illustration is a fantasy-diorama perspective concept. Not a 544×416 VX tile-ready master, not independent Ground/PAR, no 32px real collisions, no native VX run, no user Human PASS.
- Door semantics: the closed door BLOCKS and the immediate square outside is WALKABLE. Isometric illustration annotations are not native tile coordinates. Real Ground is walkable by default except water/holes; only prop contact shapes block.
- Files with F2 binary image assets are shared as direct conversation artifacts, **not uploaded to Drive** this turn. Google Drive holds corresponding text Handoff and rules; do not misrepresent Drive availability.
- Next after user visual approval: create full source-based 32px scene blueprint matching this artwork, make independent Ground and PAR/house/tree masks (do not fake separation by dividing flattened generated art); test roof/passability in real VX.

## P3_R2_PMD0001_VISIBLE_SPECIES_CHANGE
- Found original resource `PMDCollab/SpriteCollab/master/sprite/0001`: 103 original files including `AnimData.xml` plus 34 individual action triplets. XML has 36 action names (2 alias `CopyOf`), source GIF anim data with varying frame dimensions, counts and direction rows.
- Actual derivative: **Stoneback 0001**, rock-gray body, angular stone-boulder facets in original back-seed regions, amber eyes, changed RGB in **227,747 source action pixels** across **1,123 directional frame cells**.
- Every source action full atlas pixel dimensions and per-frame alpha occupancy unchanged; every original `AnimData.xml`, `-Offsets.png`, `-Shadow.png` file SHA256 identical to upstream. Thus source structure/metadata compatible without editing XML; **actual PMD or VX runtime import NOT YET TESTED**.
- First source script incorrectly assumed all actions have 8 direction rows. E.g. Sleep has one. That attempt **FAIL** archived, corrected by reading original image height / XML FrameHeight per action.
- Actual private [P3 source + derivative + XML + GIF previews + QA ZIP](https://drive.google.com/file/d/1xYGzoiMUf_CNfYKc_1NxoG9ZJRNUz4t3/view?usp=drivesdk), 530,590 bytes / 218 files / SHA256 `3a8b400e440cd80ca8f779c54d02f206b442d851d8da6bf278352c33cc546855`. Independent cold extraction of every SHA, ZIP CRC PASS.
- [Original vs modified action directions](https://drive.google.com/file/d/1cgCHrTy_iiDhJ_8pdtaDwifDrO0SNzSA/view?usp=drivesdk).
- PMD community resource has credit/contributor requirements; mixed original/fan asset, commercial redistribution must be separately authorized. No paid API credits used.

## Binding rules
1. Style authority = user's supplied image and source textures; visual richness/detail prior to compiling. Never pass generic geometry on palette resemblance.
2. Door itself blocked unless explicit transfer event; immediately ahead walkable. Ground walkable except water/hole and prop footprints.
3. PMD official 0001 data uses one native XML + action-specific -Anim/-Offsets/-Shadow. Never make up global frame sheet grid. All actions and directions must be handled and visually significant species mutations.
4. XML structural match != verified runtime import. All new user-art acceptance needs explicit user.
5. Deliver ZIP + quick QA + full source + logs + latest Handoff; Drive + GitHub Authority + Linear update; preserve immutable F1R1 baseline, sealed FS/P1G.
