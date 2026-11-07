# Shared Map Layered Generation Authority v2.5

## 2026-11-07 P0 + FS Master-first 專案別覆寫（生效）
本 v2.5 為**跨專案的一般 Ground-first/Anchor-based 產線**，不可再當作 FS 目前新精靈村的「先 Ground 後在另一張圖生 PAR」指令。FS 新地圖先凍結完整美術 MASTER，AI 當作 Ground hidden underpainting / object mask **提案者**，所有 PAR RGB 只能從該 MASTER 相同 XY 取，維持相同 Source/Scene Manifest，分開 Authoring GroundOnly/CompletePAR 與 Runtime FullGround/OcclusionPAR。仍需像素、可走格、VX Game.exe 203 真實角色與視覺 Gate；影像 0 差是必要非充分條件。其他 PMD／CG 專案未明確切換者仍可採原 v2.5 Ground-first 流程。
**所有需要保存的產物／備份只能上 Google Drive/GitHub**。使用者 PC 可做必要軟體安裝及原生執行的最小暫存，雲端驗證後必須清理。高優先：[P0](docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)；FS [Master-first QA](experiments/agent_skills_20261107/MASTER_FIRST_GROUND_PAR_QA_V1.md)。下方 v2.5 舊通用順序僅供當時與其他相容分支。

Effective: 2026-08-19
Scope: Forest Symphony / PMD AutoChess Proto / CG Pet Battle Prototype

This extends v2.4 and is mandatory when exact PAR placement / runtime registration matters.

## 1. Generative placement boundary
Image generation is not final coordinate/canvas authority. Tests showed that even explicit workcell-size requests can return unrelated dimensions and broad partial-alpha output. After Ground + Placement Anchor Contract are locked, the generator may create source-object appearance but must not control final global PAR position, final canvas size, or final registration.

## 2. Source-asset role
Generated building/bridge/tower/prop art is SOURCE ASSET only until deterministic placement QA passes. Generate one object or tightly related object group at a time whenever precise placement matters. Source generation must not reinterpret Ground geometry, roads, water, plot boundaries, neighboring accepted objects, or the full scene layout.

## 3. Deterministic assembly
The final PAR canvas is created at the exact approved Ground dimensions. Each accepted source asset is trimmed to its true alpha bounds, checked against its declared target bbox, and placed at integer x/y coordinates from the Placement Anchor Contract / deterministic assembly plan. No sub-pixel placement or model-controlled full-scene layout is permitted after anchors are locked.

## 4. Scale viability gate
Calculate source-to-target fit before placement. Default viable scale band: `0.75–1.25` unless a project-specific benchmark overrides it. Larger changes mean the source asset is at the wrong production scale and must be regenerated/re-authored, not forced into place. Nearest Neighbor only for allowed pixel-art resize. Large reductions such as ~15% of source size are automatic FAIL evidence for runtime pixel fidelity.

## 5. Alpha / pixel integrity gate
Source assets must have real transparency and meaningful opaque structure. Broad partial-alpha is not acceptable for normal pixel-art structures unless an approved effect requires it. Default warning/fail profile: partial-alpha coverage `>=20%`, zero meaningful opaque structure, blurred/feathered silhouette, or halo contamination.

## 6. Per-object progression gate
Each object/group must pass alpha, scale, bbox containment, entrance/path/water relationship, and pixel-crisp QA before the next object/group proceeds. A failed object does not authorize moving its Ground anchor or altering accepted neighbors.

## 7. Required production order v2.5 (GENERAL/LEGACY; FS NEW MAP USES MASTER-FIRST OVERRIDE ABOVE)
`Shared Authority -> Project Precheck -> Ground -> Ground QA -> Placement Anchor Contract -> per-object source generation -> source alpha/scale QA -> deterministic integer-coordinate assembly -> per-object placement QA -> regional PAR QA -> final recomposition/witness QA -> Runtime approval`

If the current image generator cannot produce viable runtime-scale source assets, switch to extraction/pixel-authoring/approved asset-generation tooling instead of repeatedly forcing unsuitable generative output.
