# FS Ground Exclusive Ownership｜V1 Mandatory Authority（2026-10-27）
**Priority: MUST / FAIL-CLOSED.** The user's new hard rule overrides former R1–R3 approaches allowing original grassy bases beneath houses. Applies to buildings, trees, rocks, props, wells, flowers, fences and all non-Ground PAR objects.

> **2026-11-07 現行優先權：本頁「Ground 只能有地面」規則限定 `Authoring_GroundOnly`。** FS 新地圖改為完整 Master-first，`Runtime_FullGround` 必須保留完整母圖（包含房屋樹木），而 `Runtime_OcclusionPAR` 只放需要遮住角色的局部同 RGB 物件；不准把此頁舊 Authoring 分工誤套到原生 VX Runtime FullGround。兩種分層用途不同，仍保留世界 XY、foot、碰撞與權利 QA。資產/證據雲端留存，PC 不存新工作資料：[P0](../../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)／[Rule Index](../FS_CURRENT_RULES_INDEX_20261107.md)。

## Ground exclusive rule
Natural horizontal terrain grass, soil, paths, sand, pavement, surface flowers and transitions belong ONLY in Ground. Objects MUST NOT carry any independent patch of original ground, even if an alpha silhouette is otherwise complete. Ground should continue beneath placed objects. No blurred seams, stamped donor tiles or renaming ground as decoration.

## Only exception: physically attached extensions
Allow wall moss, climbing ivy, attached vines, roots and plants emerging directly from a pot/structural base only if visibly connected to that object. Every attachment must have a SOURCE-FAITHFUL ATTACHED_GROWTH mask and pass visual review. Independent lawn clumps are forbidden. Contact shadows must be independent effect layers, never baked old earth.

## Strict precompilation gate
Manifest requires BODY, ATTACHED_GROWTH, FORBIDDEN_GROUND, UNCERTAIN, CONTACT_FOOT and OCCLUSION masks, per-image SHA, alpha exact provenance and layer/world positioning. Forbidden-ground count within object alpha must equal zero. Any UNCERTAIN object pixel must remain ART_HOLD until reviewed. A mask produced by the same AI algorithm must NOT self-certify source semantic compliance. Run deliberate original-grass injection negative test, attachment connectivity checks and 1×/4× human visual audit before promotion. Ground defaults walkable except explicitly designated water/holes/void.

If background dirt/grass cannot be reliably separated without cutting house steps/barrels or plants, REJECT that source and find/create a complete clean house source instead of hiding defects.

## Retroactive authority / defect classes
R1 house baked original grass: FAIL. R2 cropped 6501px but still mixed original ground semantics: NOT ACCEPTED. R3 removed 21 stray px and reclassified 367 roof-side green pixels as a fragment: not enough to demonstrate source ground exclusion or true attached vegetation. R3 house must not be used in formal FS PAR until new rule passes.
FS-ART-109 OBJECT_GROUND_DUPLICATION = FAIL.
FS-ART-110 MISCLASSIFIED_ATTACHMENT = FAIL.
FS-ART-111 SEMANTIC_MASK_SELF_CERTIFICATION = FAIL.
FS-ART-112 UNCERTAIN_BACKGROUND_OR_ATTACHMENT = ART_HOLD.

## Production sequence
1. Ground-only remains a continuous pixel-crisp terrain; inspect object from original source before composing.
2. Separate complete body and physically attached ornament; zero standalone ground. Keep original source, masks, rejected candidates and provenance.
3. Negative patch injection must fail; assert owner exclusivity, contact/foot collision, occlusion, exact RGBA of kept pixels, actor scale and 1× source edge check.
4. User visual approval then isolated Game.exe native validation. No sealed FS changes.

Drive Authority: https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit