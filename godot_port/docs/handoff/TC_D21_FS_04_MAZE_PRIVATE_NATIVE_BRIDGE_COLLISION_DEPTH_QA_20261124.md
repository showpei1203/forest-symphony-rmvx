# Forest Symphony｜T-C D21｜D18／D19 真私人圖片原生雙向跨橋及橋面繪製層級測試｜2026-11-24

**正式狀態：Native provisional bridge physics PASS（D18/D19），角色完整 PAR 遮蔽 FAIL／橋面臨時 z-index 修正 TECH PASS；真正 ACTOR01、正式圖塊碰撞／熔岩安全及完整 FS 遊戲整合仍 NOT_RUN；ART 0/12 HOLD。**

## 本輪可驗證產物
- [**D21 32 檔私人原圖＋真 Godot 截圖＋物理日誌＋全 QA ZIP**](https://drive.google.com/file/d/1ojoEcCcZ2lndkR8JOEl4G18qys-HC4vW/view)：**50,695,229 bytes，32 entries，CRC PASS**，SHA256 `5f884d72f81dcef15fcbb529a43c686113a3b3bc90b276dc33f6b72b44f91a3e`。
- [D18／D19 兩版原生橋面與欄杆碰撞四圖 QA](https://drive.google.com/file/d/1AnnshQIzgvl1XeyVHV7eCqnCQLvvPgjl/view)。
- [角色在整張 PAR 之下／之上的真 Godot 截圖對照](https://drive.google.com/file/d/1HShCa_attT1UXI4kIBNcQkiqH6lXVeqz/view)。
- [兩條暫定橋欄杆碰撞範圍 QA（非美術來源）](https://drive.google.com/file/d/18Vy0YUcaJq969F1-ASBeAUjTk4S8QIVh/view)。
- [完整物理數據與來源 SHA JSON](https://drive.google.com/file/d/1ka5u3-sTD3y5s9NMjOi7HOlJbtXpZ7I3/view)。
- 新 Godot 原生可重用腳本 `godot_port/tc_factory/native_bridge_walk_probe.gd`，採雙源 SHA、真本機 `CharacterBody2D.move_and_collide()` 與 `StaticBody2D`。
- Google Drive 私人檔案未放公開 GitHub，需 READBACK；不修改 D17 Ground 及 D18/D19 PAR。

## 核心反例
正式畫布 1280×928：在橋中點（979,500），若測試角色 `z=1`、完整不透明 PAR `z=2`，**角色被整個橋面遮住**，原生 SHA 與無角色 baseline 完全相同，視覺不同像素 **0**。臨時將角色在橋面範圍提升至 `z=3`，則可見不同像素 **225**（D18 和 D19 均成立）。正式製程仍 Ground FIRST → 所有非地表 ONE PAR，不需要重製圖層；這只是限定區域 runtime depth 原型，**尚未解決正式前側欄杆遮擋**。

## 重要的物理驗證邊界
橋面原生走位雙向各 74 個物理影格零碰撞，兩條人工暫定欄杆均真正碰撞阻擋；臨時橋中心線 y=500、角色半徑 7、橋邊界 [788,461,363,21] / [788,518,363,25]，全部是**人工暫定 QA**，不是遊戲正式場景碰撞、不是玩家正式 ACTOR01，也不能保證角色不能從別處走入熔岩、事件功能或跨橋兩端正式路徑。

---

# Forest Symphony | T-C D21 | Actual PRIVATE D18/D19 Bridge Physics and Depth Smoke

Date: 2026-11-24 Asia/Taipei. Engine: official Godot 4.7.2 stable ed1daf0bf, Linux Xvfb/Mesa llvmpipe OpenGL. Branch: `feat/fs-tc-d12-chroma-par-20261122`; no writes to original E: project.

## Real result and strict scope

Using TRUE owner-private D17 Ground and owner-private D18/D19 intact CompletePAR as independent Sprite2D at the same origin, D21 executed REAL native Godot CharacterBody2D `move_and_collide` physics with TWO hand-authored temporary bridge-rail StaticBody2D collision rectangles. This is a **provisional isolated local bridge physics test only**, NOT the canonical FS map collision system, real ACTOR01 controller, whole gameplay integration, lava damage, world collision, event system, ATB or user ART approval. Official 12-map ART PASS remains 0/12.

SHA-locked source: D17 Ground `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`; D18 PAR `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e`; D19 PAR `cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1`. No art regenerated, resized, cropped or uploaded to public GitHub.

## Native physical actions (both D18 and D19 PASS)

- Provisional bridge deck centerline y=500; WEST=(810,500), EAST=(1108,500). CharacterBody2D with temporary radius=7px and a bright cyan SURROGATE actor marker. It is **not an approved player sprite**.
- West-to-East: 74 native physics frames, final (1106,500) within 2px of target, **zero collisions**.
- East-to-West: 74 native physics frames, final (812,500) within 2px of target, **zero collisions**.
- North out-of-bounds attempt from (986,500) to (986,440): returns actual `KinematicCollision2D` against `QA_UPPER_BRIDGE_RAIL`.
- South out-of-bounds attempt from (986,500) to (986,590): returns actual `KinematicCollision2D` against `QA_LOWER_BRIDGE_RAIL`.
- Upper/Lower rail QA rectangles: [788,461,363,21] and [788,518,363,25]. These are **manually annotated approximate rails**, not derived from alpha and not yet approved for world gameplay. No collision outside these two rail rectangles has been authored.
- Native screenshots captured at baseline, actor-under-PAR, actor-raised-on-deck, east arrival, west return and both rail blocks; two variant native QA JSONs and stdout logs archived.

## Critical renderer defect discovered and isolated

Across bridge deck x=820..1110 and y=505..567, most CompletePAR pixels are opaque. At bridge center x=979,y=500, rendering actor at z=1 **under** CompletePAR z=2 gives literally the **same native 1280x928 screenshot SHA256** as rendering with NO actor: **0 different pixels** for both D18 and D19. Thus a character walking behind the single all-non-ground PAR is invisible on the bridge.

Putting a QA actor above the PAR at z=3 within a provisional deck area makes it visible (225 changed pixels). This is a **demonstrated scoped runtime depth workaround**, NOT a finalized global actor z-sort / decorative railing occlusion system, and NOT a change to the approved Ground-first/one CompletePAR art pipeline.

## Failure and repair log

1. D21 R1 smoke corridor at y=530: Godot collisions passed but the actor overlapped the **front railing graphics**, so **VISUAL FAIL** despite valid physics. Rejected as final QA alignment, correctly relocated provisional deck lane to y=500. Both native variants rerun successfully.
2. D21 R2: East-West and West-East traversal, north/south physical guard, double SHA lock and real PRIVATE PNG native renderer **PASS under provisional bridge geometry**.
3. D21 rendering failure: player z below a fully opaque CompletePAR becomes completely invisible. Scoped `bridge deck` z raise permits visibility, but actor in front of railings would require author-approved runtime depth design; do not call full actor/bridge integration complete.
4. Negative cases **real Godot rejection exit 2**: mislabeled D19 PAR as D18; incorrect D17 Ground. No QA screenshot/JSON generated.
5. No official scene collision map or authored lava/footpoint boundary exists in current T-C art source. This test only blocks two manually drawn bridge rails and does NOT prove that the player cannot walk on lava elsewhere or that the town paths are fully connected.
6. Full original Forest Symphony gameplay project, existing ACTOR01 art rig, events, quests, battle/ATB, save/load and user ART **NOT_RUN**; do not inherit earlier generic Godot CI as this scene's integration proof.

## M1/M2/M3/M4

M1 D17 Ground/D18-D19 PAR sha and 1280x928 mode: PASS.
M2 True private art native Godot 4.7.2 1x renderer: PASS (carried D20 and rerendered D21); actual two-way bridge 2D physics QA on temporary rail geometry: PASS both D18/D19.
M3 New actor-below-PAR **render occlusion FAIL**, bridgedeck z raise **isolated prototype PASS**; canonical bridge collision and art review **HOLD**.
M4 Second sample FS_04_MAZE is an experimental engineering sample; canonical ART still **0/12 HOLD**.

## Next complete engineering unit

Use the proven native 2D physics probe to introduce a **formally authored** bridge walk lane, guard rails and lava/exposed-slope collision in the existing FS Godot map system (not in one-off generated art); import real ACTOR01 and test transitions off both ends of bridge while applying correct actor bridge z-order, run story/collision integration smoke and human ART acceptance. Do not export provisional QA collision rectangles into production without comparing to authentic 32px world geometry and intended path grid. Keep code and handoff in GitHub, private art, screenshots and full QA evidence in owner-only Drive.
