# FS AI Asset Factory CURRENT_HANDOFF — A08 (2026-11-08)

**ACTIVE** cross-chat entrypoint for BOTH Sprite Sheet and Master-first Ground/PAR. STOP A06 railing-pixel tweaks and old "more CI instead of finished art" loops. This supersedes A06 active execution order while all historical A01-A07 evidence remains intact. Nothing was merged into main.

## 1. Source & authority order
- Global FS P0 cloud-only, FS main authority index P1-P5, latest P6 [dual-lane production rule](../../authority/FS_ASSET_FACTORY_BOTH_LANES_RULES_V1_20261108.md).
- User supplied a 22-page PDF: 遊戲資源量產化研究報告：以 PixelLab 為核心，建立 FS Sprite Sheet 與 ground/par 分層地圖產線. Exact source original PDF 2,670,903 bytes, SHA256 6440b756303c1647a89f5de3de9ab19c441579609eac8c72a19f696218097101, saved in restricted owner-only Google Drive FS_AI_ASSET_FACTORY_Restricted_Rules. **Do not post private source PDF or binary Drive URLs in public GitHub.**
- Full page mapping [A08 report audit](A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md).
- [Sprite Factory SOP](FS_SPRITE_FACTORY_SOP_V1_20261108.md), [Ground/PAR Map Factory SOP](FS_MAP_FACTORY_SOP_V1_20261108.md), [A08-A12 execution queue](A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md).
- All 4 full documents + separate Drive Handoff mirrored in owner-only Restricted_Rules folder (Google Docs titles start FS_A08_..., available from user's private FS authority Drive index).

## 2. The production method you MUST follow
Spec from actual FS + approved references -> Style Bible -> archetype/semantic map family -> saved skeleton or connected tile vocabulary -> canonical asset+manifest -> bounded batch generation -> automatic QA -> ONLY exceptional failures are repaired -> native FS exporter -> 1x user art approval / native Game.exe -> cloud SHA & Handoff.
- Sprite: use A25 lava appearance reference ONLY when real binary SHA recovered and source approval verified. A26 five-frame Idle/Walk candidates were NOT user approved nor native XML. Reusable A62 Actor 48px run has 3 key poses and known 0,1,0,2 playback; original Town 32x32 is distinct. Real native PMD0001 Idle3/Walk6/Attack11, PMD0002 Idle4/Walk4/Attack9, PMD0003 Idle4/Walk4/Attack11, each authentic XML per-action width/height/duration and 1 or 8 rows with Anim/Offsets/Shadow. No universal three-native-frames.
- Map: actual FS Master-first 4-layer source, not hypothetical PDF parallax model. A coherent frozen Master supplies Runtime FullGround; semantic object IDs and object-only full+foreground masks must be created with the object/source recipe BEFORE mask export. A front bridge railing is NOT wood-colored deck pixels; do not use GrabCut as primary semantic classifier. Decor via Wang 32px/seeded family rules and semantic paths; native PAR only eligible actor-foreground pixels with correct footpoint predicate.
- If same error repeats in two assets or a localized exception repair fails once, STOP and fix the archetype/semantic source template, not V0→V1→V2 manual patches.

## 3. Actual A08 files committed to feature branch
PR #15: https://github.com/showpei1203/forest-symphony-rmvx/pull/15, branch feat/fs-asset-factory-v1-20261107, Draft/Open/unmerged.
Source docs: A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md; FS_SPRITE_FACTORY_SOP_V1_20261108.md; FS_MAP_FACTORY_SOP_V1_20261108.md; A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md; authority/FS_ASSET_FACTORY_BOTH_LANES_RULES_V1_20261108.md; this Handoff.
Machine config: config/asset_factory/FS_STYLE_BIBLE_V1.json, FS_SPRITE_ARCHETYPES_V1.json, FS_MAP_SEMANTIC_FAMILIES_V1.json, FS_A08_PILOT_JOBS_V1.json.
Runnable: tools/asset_factory/production_gate.py, run_a08_pilot.py.
New tests: tests/test_a08_production_gate.py (16 cases), tests/test_a08_pilot_manifests.py (8 cases). CI now runs 4 actual metadata pilot dry-runs automatically on any change to config/asset_factory/** as well as source code. No API/secrets/binary images.

## 4. Real input and pilot outcomes (do not misrepresent)
A01-A06 synthetic 63 + A08 24 = 87 tests. CI at workflow update commit 41ef52c19ddaa49e637d4de84b393397e642aaaf: actual run 42422502851 completed success, 87/87, logs include A08 4-job dry-run, total paid generation calls zero. **After this new Handoff or other docs commits, check latest PR HEAD CI again.**
- S-P1 Actor A62 source: original 48px F0 and three-pose 144x48 source proven, historical specific run look approved; full new Actor native/weapon anchor still HOLD.
- S-P2 PMD0001: real original 0001 native XML and SHA proven; A25 new lava concept binary not located, 8-direction new lava art not approved => ART_SOURCE_HOLD. Idle3/Walk6 schema verified, not generated native new art.
- M-P1 elf village V3 1280x928 real Master source metadata; scene-level 1x art and legal rooftop footpoints not approved; full Authoring object ownership incomplete.
- M-P2 forest bridge is a DIFFERENT scene proposal, explicitly has no new frozen Master source. A06 bridge mask candidate is art FAIL and not falsely promoted. Bridge deck classified ground and must never enter foreground near-rail PAR.
All 4 dry runs correctly return HOLD, no hard failures. They are **metadata contract tests, NOT four generated assets**.

## 5. Operational gates / danger blockers
- Art approved look, palette HEX and Ground3 exact source style needs private SHA + human review. The PDF's 64px, 8–12FPS, USD 0.45 etc are illustrative/not guaranteed actual FS account costs.
- PixelLab official tools (8 directional / reusable skeleton / tileset / overlap selection) researched. This session does not have a proven direct PixelLab provider connection/paid authorization; **no calls made**, default hard cap zero. Do not invent live provider availability.
- Orca historical reviews exist; NEW independent Sprite S1 and Map M1 agents NOT STARTED until read-only approval policy genuinely verified; don't claim delegation otherwise.
- Windows Game.exe new native test requires separately explicitly approved PC temp scope+cleanup. A08 NATIVE_NOT_RUN.
- Public GitHub source/docs only; protected images, original PDF and real PNG/ZIP in owner-only private Drive, shared=false, owner-only metadata checked.
- No new user-PC persistent files, no main merge; no new real sprite/art assets generated in A08. FORMAL_SEAL NO.

## 6. Exact next work, no restarting report study
1. Choose actual approved A62 run and source of A25 lava look; lock their visual/authoring files and palette or mark missing. Obtain explicit bounded PixelLab budget only for genuine generation after source lock.
2. Sprite: use reusable archetype skeleton for Actor 3-key run; independently test PMD0001 native Idle3/Walk6 and eight genuine distinct views; generate a small series then auto-check frame/pivot/silhouette and exceptions; not micro-edit each frame.
3. Map: build coherent semantic bridge/tree/house object families and 32px Wang/path/seeded decor vocabulary from approved FS style; use same scene recipe on TWO genuinely different full Masters; generate object art + object-only alpha together (before Master foreground export), not post-GrapCut color sampling.
4. Export both lanes to true native FS with their existing adapters; native Game.exe only after authorization, capture 1x user visual verdict, compare first-pass acceptance and exception counts. No volume until 2 sprites and 2 maps actually pass.
5. Always append latest GitHub run/commit, Google Drive source ID/SHA, unresolved source/Art/Native gates and new full Handoff. The current A08 authoritative SOPs are persistent across chats.

## 7. Rollback
Revert only these feature-branch policy/schema/manifest code commits if any regression occurs. A06 real private candidate files remain evidence only; V3 original, A62 approved runs and formal main remain sealed.
