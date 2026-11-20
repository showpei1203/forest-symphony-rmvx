# Forest Symphony｜Godot P537B A52 12 幀戰鬥角色接線 Handoff
Date: 2026-11-21, Godot 4.7.2 only. Source branch feature/fs-godot-phase1, first code commit 852f8962b01029eba7f3a9b4e126c3f6207aed01.

## Correct owner priority
BATTLE 系統＋原版美術 > MENU/各頁 UI > A35 森林地圖。續接 P536 原版 UI GPU、P537 原版 2x2 戰鬥指令及完整 P532 真 ACT/事件可玩切片，不倒退 VX。

## Cross-branch source authority
T-A branch feat/fs-pixellab-ta-actor-20261121 latest checked HEAD 072db87eaa415691a5a9cfbb71b699ae7974404d.
T-A motion Handoff godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md and manifest TA_ACTOR01_MOTION_CANDIDATE_MANIFEST_20261121.md. ATTACK12 uses source-exact A52 real PixelLab Skeleton V3 already paid and validated earlier; not a new PixelLab generation. 45° 3/4, each 64x64, 12 frames in 4×3 256x192 atlas, independent Body/Weapon/FX, F7 t=0.630s visual contact, animation end=1.060s, 70ms hitstop is metadata only. T-A RUN12 is ART HOLD due run weapon placeholder and F6/F7 defects and is NOT merged as a battle-ready asset.
- Owner-only A52 original attack sources: Body https://drive.google.com/file/d/1OORgztbxZAuALp2LG8jVHy-qP3Zt5T5Z/view SHA a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f; Weapon https://drive.google.com/file/d/1t62jhGB42Tbn_MKVM2cCNCxEQhGg0iQa/view SHA 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b; FX https://drive.google.com/file/d/1mNTMIdQmqxJVOMWus5t4StndgZSSXzVd/view SHA 46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c.

## Real implementation
1. Copied/extended T-A approved public scripts/animation/FSTAActorMotionRig.gd into battle code. Supports ATTACK-only configuration without fake RUN weapon; exact 12x64 frame region, 3-layer animation and contact signal preserved. T-A branch remains untouched.
2. Added scripts/ui/FSBattleActor01Presenter.gd. At runtime loads 3 exact A52 source SHA256/size 256x192 private PNG from res://assets/ta_actor01, refuses empty/wrong/unknown or source mismatches. Hidden if absent, no fake actor art; only visually handles Actor ID 1, not arbitrary party slot. Tracks actual FSActionQueue pending serial, displays once when ACT attack queued, emits 0.63s F7 cosmetic contact. NO changes to FSBattle damage/MP/cooldowns/actual hitstop/Enemy AI, avoids conflating visual contact with action resolution.
3. FSScreen.gd adds compact independent upper-right 100x96 transparent overlay on original 544x416 layout (does not consume action menu/grid height), syncs after actual queue and in battle refresh, cancels when leaving MENU.
4. tools/stage_private_actor01_attack_537b.py reads the 3 existing original A52 PNG files and stages exact source bytes only into explicitly private ignored res://assets/ta_actor01 within authorized ephemeral workspace after hash/256x192 gates; no original binary in public GitHub.
5. Added Python synthetic archive/PNG header/stage/no-overwrite tests and Godot original rig native ACT queue F7 test to existing full fs-godot-phase1.yml workflow. Public test texture is SYNTHETIC, always flagged, and cannot be called private source image QA.

## Verification & limitations
First Godot code run: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44832343980 . Verify final workflow status before calling full PASS. New stage and native rig tests already passed when observed in tool results.
Native test assert: 3 independent Sprite2D layers, F7 contact at 0.630 sec exactly once, actual FSBattle source ATB queued attack triggers presenter once per serial and does not change HP/MP before game resolves. No original production GDScript timing or math altered.
NOT RUN: actual owner-private A52 PNGs staged into main Godot and original attack rendering 544x416/1088x832; real character swing visually aligned with source ATB damage; real scene enemy Battlers/BattleScape; original post-Apply 11 DB / 505 RGSS last-wins authority.
Important mismatch: A52 visual contact=0.630 sec is NOT bound to game ACT resolution timing (source ACT can be shorter); this is presentation-only synchronization. Do NOT use signal to apply damage until source timing contract and native source witnesses are completed. Therefore still ART HOLD and Phase1 SEAL NO.

## Next macro unit
P537C: Stage verified owner-only A52 Body/Weapon/FX PNG into PRIVATE Godot assembly, capture three native OpenGL phases (startup/F7/finish) at 544x416 and 1088x832, inspect 45° identity and weapon/FX. Work with T-A upstream rather than overwriting RUN ART HOLD. Add actual enemy Battler texture/backdrop only after source SHA and Godot collision/anchor/scene checks. Then synchronize hitstop and ACT visual timing to real charge without mutating combat rules. P538 MENU originals afterwards; A35 map postponed.
GitHub code + Handoff/Failure Log only; Drive stores original PNG and private visual QA. Original E: VX remains read-only.
