# T-A｜ACTOR01 RUN12 / ATTACK12 candidate motion manifest

## R3 actual private GPU visual source proof

- SOURCE: all 6 private 256×192 original/candidate atlases, Body/Weapon/FX independent in true Godot SubViewport 64×64.
- ENGINE: official Godot 4.7.2 stable, OpenGL 4.5 Mesa llvmpipe (software GPU), process EXIT 0.
- RENDER: 12 RUN + 12 ATTACK, 24/24 private source frames saved (NOT synthetic).
- PIXEL QA: RUN all 12 frames exactly identical to original RGBA composite; ATTACK all alpha values identical with only 59 RGB pixel differences (5 frames during FX blend). See owner-private QA JSON in ZIP.
- Full native 24 frames and GIFs incl QA log: https://drive.google.com/file/d/1iNuBTTvC0Zyfs3yHp1Lovobu8vnMU0CF/view
- 1× RUN / ATTACK: https://drive.google.com/file/d/13M9gUrwemvWTbYEQTXRKUEajZ_CJTTcl/view and https://drive.google.com/file/d/1k4U4YffBJCeeGAC4fU6a4UGwqr6hb7KH/view
- 4× montage: https://drive.google.com/file/d/1qBH5X8t5zUY8gMxkqn1-xcnMpGCsK-9K/view
- Reproducible Godot native capture script: godot_port/tests/capture_ta_actor01_private_source.gd, private files must be supplied in res://assets/ta_actor01. No private PNG committed.
- Rig timing 0.63sec + hitstop metadata previously validated in synthetic native CI, not full live original private gameplay. **ART HOLD** (A35 F6/F7) and PixelLab v3 not run. Avoid falsely marking overall T-A complete.

---

## R2 最新 RUN12 真實持劍候選

R1 的空白 Weapon 僅是歷史紀錄；最新 R2 新增完整 12 幀分離 Weapon，原圖由 A52 真實 PixelLab sword F5 平移而來，完全沒有新生成 job。12 個 weapon frame 全部含原 sword 像素、均與人物 overlap、無剪裁。

- Body SHA256: fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb
- A52 原 Weapon SHA256: 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b
- R2 Weapon SHA256: ff3be6c132da2d8ac285ef60db48be195549b155f22ea5ac490c86a85f120eb7
- R2 FX SHA256: ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7
- Hand anchors F0..F11: (38,48),(37,49),(37,49),(42,41),(42,42),(38,47),(37,47),(38,48),(39,49),(40,48),(38,49),(38,49)
- Reproducible tool: godot_port/tools/ta_actor01_run_weapon.py, locks both original source SHA.
- New weapon: https://drive.google.com/file/d/1zSNUKTpGR5FXd8ni1RXtdLmspILHD-cU/view
- New 1×/3× QA: https://drive.google.com/file/d/1y1qXJeLuzaS6dGSOcbDRE5iVHZuBuOzB/view and https://drive.google.com/file/d/1xplRRIJtrTkDUtwiMLzKIK7Tjr4KMBYt/view
- Godot 4.7.2 synthetic native CI PASS: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44833193171
- Real original private art Godot GPU NOT RUN; ART HOLD, old A35 F6/F7 unrepaired. No new PixelLab v3 model job; zero new units.

---

- Date: 2026-11-21 (Asia/Taipei)
- State: **ART HOLD; not fresh PixelLab v3 art**.
- Actor identity: original A62 white-haired Actor01, 45-degree 3/4 battle.
- Grid: 4×3; cell 64×64 RGBA; atlas 256×192; 12 frames per action.
- Layers: Body + independent Weapon + independent FX.
- Private output folder (readback verified): https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT

## RUN (12 actual different frames)

Source was REAL PixelLab-derived A35 run, originally **8 frames** at 256×128. The candidate uses 4 OpenCV optical-flow in-between frames; *not* PixelLab Text v3 or Skeleton v3 generation. Sequence by original frame indices:
`0, 1, midpoint(1→2), 2, 3, midpoint(3→4), 4, 5, midpoint(5→6), 6, 7, midpoint(7→0)`.
- RUN Body: https://drive.google.com/file/d/1_iP5j4LRtPXyd-VKpmDiotmlr-Z7_ziX/view
- RUN Weapon: https://drive.google.com/file/d/1377yLyqjLh8a5T8jnmhWIxrVdX3HbLLs/view **TRANSPARENT PLACEHOLDER, NOT APPROVED**.
- RUN FX: https://drive.google.com/file/d/1p2878CC0FXnHQSR8exER_YJPVwgKH5k9/view **TRANSPARENT PLACEHOLDER, NOT APPROVED**.
- Keyframe QA comparison: https://drive.google.com/file/d/1tmdxXfHbt5gPyROa48kXrTWgu2PhmWfF/view
- Existing A35 frame F6/F7 ART HOLD persists; new in-between frames need motion inspection. Not 12 independently generated PixelLab poses.

## ATTACK (12 existing A52 original frames, reused without modification)

Previous original PixelLab Skeleton v3 job `094a45f9-c279-4c06-94e4-a1708a13daac`; prior cost 3.0 generation units. No new paid submissions in this turn.
- Body original: https://drive.google.com/file/d/1OORgztbxZAuALp2LG8jVHy-qP3Zt5T5Z/view
- Weapon original: https://drive.google.com/file/d/1t62jhGB42Tbn_MKVM2cCNCxEQhGg0iQa/view
- FX original: https://drive.google.com/file/d/1mNTMIdQmqxJVOMWus5t4StndgZSSXzVd/view
- Original A52 animation timing: `[0,.100,.190,.275,.350,.455,.560,.620,.735,.830,.910,.980]`.
- Presentation contact: **F7, t=0.630s**, 70ms hitstop metadata. Preserve game damage authority separately (prior anchor JSON stores `event.time_sec=0.55`); do not silently alter ATB gameplay.
- Previous A52 source: https://docs.google.com/document/d/1D1n1NSHW4xQS_vhkq79BkxMZr_V5xvKe/edit

## SHA256 (raw PNG bytes, locally verified in isolated execution container)

| Source | SHA256 |
| --- | --- |
| approved A62 64×64 | `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e` |
| A35 original RUN 8 | `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b` |
| T-A RUN 12 candidate | `fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb` |
| RUN Weapon / FX placeholder | `4000e6498556cafd7d63e3369c1449a94f03bcdb11c5606bd2b0a67ae42f0327` |
| A52 Body original | `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f` |
| A52 Weapon original | `6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b` |
| A52 FX original | `46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c` |
| T-A 2× QA strip | `df1a9a1f517360700ca320de002e4828766d9112c49419c68dfeceef64886ca0` |

## Godot 4.7.2 private test staging

For an actual private-asset GPU preview in an isolated authorized Godot checkout, add the following six source files under `godot_port/assets/ta_actor01/` and **never commit them to public GitHub**:
- `run_body.png` = uploaded T-A RUN candidate
- `run_weapon.png` = transparent RUN weapon placeholder (must be replaced before ART PASS)
- `run_fx.png` = transparent RUN FX placeholder
- `attack_body.png`, `attack_weapon.png`, `attack_fx.png` = unchanged original A52 files

Launch `res://scenes/ta_actor01/TAActor01Preview.tscn` (isolated scene, not default game Boot); press R=RUN, A=ATTACK, SPACE=cancel. The scene reports asset missing instead of inventing character art.

The public Godot 4.7.2 CI uses **synthetic in-memory test textures only**, to prove native atlas indices and timing without leaking licensed source. This is **not private original GPU render**. Separate source/format and runtime-engineer tests from ART acceptance.
