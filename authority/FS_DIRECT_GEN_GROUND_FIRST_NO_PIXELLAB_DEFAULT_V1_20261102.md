# Forest Symphony Ground-first direct generation | A35 Source-first QA v1

> **2026-11-14 使用者 v1.3 最高優先：已恢復並強制 Ground-first → 獨立完整 PAR → Godot 動態合成 → 1x 最終美術豐富度驗收。** 任何 2026-11-07 的「全圖 Master-first → source crop」均為舊實驗歷史，**不得用作新地圖正式產線**。請先讀 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.3 的 0c；本頁保留可重用的尺寸、alpha/footpoint/碰撞/素材來源和冷驗證方法，但被 0c 覆寫的工序不再有效。

Date: 2026-11-02 Asia/Taipei. ACTIVE workflow, no claim of user final approval.

> **2026-11-07 STATUS：舊版本 Source-first/Ground-first 實測，不是新精靈村的現行生圖順序。** 真正 Ground3 視覺驗收、來源版權、Alpha/Collision Gate 仍有效；新畫面一律完整 MASTER 起步、Mask-only + same-pixel source 上層，不准以色彩對似的另生 Ground/PAR 當對位成功。雲端保管 P0：[Drive/GitHub Only](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。

## Change and evidence
User accepted the aesthetic direction of an assistant-directly-generated forest canyon image featuring lush native grass, irregular dirt paths, authentic ledges/cliff faces, stairs, cave, shoreline. It was generated directly, NOT by PixelLab. PixelLab is now an optional assist for standalone object variations, no longer mandatory or a reason to block Ground-first production. This is **an evidence-based trial**, not proof every next generation will maintain quality.

The original direct-generated image **1473×1068 RGB** was NOT authored at exact 32×32 tile scale. It can be nearest-resampled to **1280×928 = 40×29 ×32** which is a VX-compatible **canvas**, but not automatically grid-aligned on every stair/cliff/path boundary. The A35 reference image must never be falsely labeled native 32px original drawing. Explicit semantic collision, height logic, stair connections, PAR, original VX checks are mandatory.

## A35 actual implementation
- Ground image `A35_GROUND_DIRECT_ART_1280x928.png` SHA256 **478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00**, copied directly from user's assistant-generated high-style reference after nearest conversion. Do not overwrite by procedural grass patch quilting or move to old A34 style.
- Semantic cliff-face classification (source RGB brown/rock) and water category from same source, preserving full Ground RGB. Derive **217 individual independent RGBA PAR source objects** as 64×64 local masks. Full `A35_PAR50_ONLY_CLIFF_OCCLUSION_1280x928.png` SHA **48ec0e4156f085f757542f6e06a9568ab75523d6bb857c773ccf895c05e528a9**; covers 256,218 mask pixels or 99.88% of detected cliff face category. Combined source Ground+PAR visible RGB **exactly 0 changed positions**.
- PAR copies intrinsically shaded pixel cliff faces exactly, not external sunlight/cast SHADOW/LIGHT. Do not bake separate environmental shadow or light into PAR. No trees in A35 Ground; future trees independent later.
- Collision: classified water and cliff unsafe at 32×32 semantic E-layer; conservatively marks 414 blocked and 746 passable tile cells; original 5 candidate staircase corridors explicitly reserved for testing. Only 695 of 746 currently connect in the largest walkable component; separated elevation islands / topology gaps are NOT accepted as finished navigation. Cave blocked pending next map connection. Fix them in A35B by semantic passage graph, native movement and region/height tests, not by falsely lowering collision threshold globally.
- Native VX engine Map050 40×29 actual Game.exe, 217 individual Cache.overlay inputs, 11 scenes/22 real 544×416 screenshots; no RGSS modal. Actor tried step DOWN from (20,14) into blocked (20,15) and stayed; legal grass RIGHT from (21,14) to (22,14) succeeded.
- Native VX actual scrolling coordinate comparison to exact Ground+PAR source: cases 0 and 1 affected by title fade, RGB max 248/250 (FAIL pixel parity). Cases **2..10 full equality ZERO RGB difference**, nine distinct viewport areas and both far corners. Report first two separately.
- Native Godot 4.7.2 AMD RX6700XT OpenGL: 6 real full 1280×928 renders plus 6 544×416 true GPU crops; **native GPU vs independent source composite full image RGB difference exactly ZERO**.
- Separate isolated cold VX copy, **3844/3844 SHA256 identical**, real Game.exe loaded Map050 217 assets and no modal. This is map test harness with preexisting legacy battle-regression bypass, NOT tested formal production integration.
- Original A34, A33F, A32B immutable. Current user art positive for reference direction, but **A35 VX source conversion + gameplay signoff PENDING**, Formal Seal NO.

## Fail-closed next
A35B must correct 32-grid elevation semantics, evaluate stairs/plateau entrances and water edges, perform native VX movement across elevation junctions, build independent tree/house/rock PAR only after geometry passes; do not return to A34 noise-ground. Ultimately deliver complete large 40×29 or larger map with source materials, scene manifest, Ground, PAR, collision and separate SHADOW/LIGHT, plus engine verification. Log user visual discrepancies explicitly.
