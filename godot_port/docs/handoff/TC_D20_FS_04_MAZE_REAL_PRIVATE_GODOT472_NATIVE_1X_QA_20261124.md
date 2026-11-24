# Forest Symphony｜T-C D20｜D18+D19 真私人素材 Godot 4.7.2 Native PASS｜2026-11-24

**正式新進度：M2 真私人 Ground+PAR 原生 1× 渲染 PASS（D18、D19），VISUAL ART 仍 HOLD，正式 12 張地圖 ART 0/12，整合 NOT_RUN。** 這次解除了 D19 的「私有圖不能進 Godot」阻斷，不再沿用 synthetic 引擎測試充數。

## 交付、來源與存證
- **[D20 私人完整 ZIP：22 檔、15,378,529 bytes，CRC PASS](https://drive.google.com/file/d/19H-CgMvpgA1iFYODCYpW2PuYTmtJ9EQY/view)**，SHA256 `0307904dc52ee5ca25b52d7c9782a8709950e1e2e7d96ae26bb38645c53cad1f`。內含原 Ground、兩版 PAR、**兩張 Godot 真原生 PNG**、QA JSON、原生 log、三種錯誤拒收、AB 對照、來源/引擎 SHAs、只在隔離環境運作的 Godot 版 QA probe 與比較程式；不含 Godot 可執行檔。
- [**D18 私人真 Godot native 1× 截圖**](https://drive.google.com/file/d/1eDyr2FwOk8Mdv3WEjiOe5isYkiWoU2qA/view) SHA `14cf4bfe3288d6fd7c39c48349a4a24282c13df1620c3280cfd9ea6aea638ede`。
- [**D19 私人真 Godot native 1× 截圖**](https://drive.google.com/file/d/1KsAW1TktV0Weq-gx9u5s-nk5D3y6m8wS/view) SHA `a3d830b550e93ac49c4bdbec3d7c19489e41f7e5cd12a1b3d508350ce18b2e2a`。
- [D18 vs D19 真 Godot 原生 1× 對照](https://drive.google.com/file/d/1XRgnE30gIznle8Ca2EAG7SSbwJTGYoz0/view)、[整合 QA JSON](https://drive.google.com/file/d/18Gs6WeRVPhGJFOSIy1svz9SbCk7_pSgT/view)。
- Google Drive metadata 已 READBACK：`shared=false`、permission owner-only；所有私人 PNG 和 22 檔封包均存 owner-only Drive，**沒有任何 FS 美術圖片進公開 GitHub**。
- [GitHub Actions #45300766962](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45300766962) SUCCESS：僅轉運官方 public Godot 4.7.2 x86_64 執行檔，SHA `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e`，藉 GitHub Connector 實際下載至隔離執行容器，直接跑私有 Ground、PAR。不是雲端 CI 對私人圖片測試；**真正的原生渲染是在隔離工作容器內**。
- 不使用 Windows Bridge 擴權、Desktop Remote（0）、Codex（0），不修改 `E:\遊戲專案開發`、T-A/T-B 或其他 T-C workline。
- 本輪本地 Native QA 依據既有 `godot_port/tc_factory/native_complete_par_probe.gd` 做隔離 runner 版，保留來源驗證/NEAREST/同世界座標/Alpha fail-close；runner 完整原始檔附私有 ZIP，**不是假稱 GitHub 原檔逐 byte 相同**。

---

# FS T-C D20 | Actual private-source Godot 4.7.2 native QA | 2026-11-24

## Actual new result
For the first time in this T-C sequence, both owner-private D18 and D19 CompletePAR PNGs (with the unchanged D17 locked Ground) have actually been rendered to native 1280x928 PNG using official Godot Engine 4.7.2 stable under an isolated Linux x86_64 Xvfb/Mesa llvmpipe OpenGL environment. Both source SHA256 locks passed and the renderer produced separate files and JSON readback. This is a **native renderer PASS**, not an approved in-game scene, collision, travel route, gameplay integration or user ART PASS.

## Previously blocking condition solved
- Container does not resolve github.com DNS and no Godot 4.7.2 executable was preinstalled.
- New GitHub Actions workflow **ONLY downloads official public Godot 4.7.2 x86_64 and uploads that engine binary as temporary artifact**, no Forest Symphony private art ever goes into GitHub. Actions run: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45300766962 (SUCCESS).
- Artifact returned via authorized GitHub connector and was available at private working path, extracted in isolated /mnt/data work area. Official binary version 4.7.2.stable.official.ed1daf0bf, SHA256 8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e, verified. Engine NOT distributed in the private art ZIP; official provenance and SHA included instead.

## Source SHA and immutable world
- D17 RGB Ground 1280x928: 2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e
- D18 RGBA CompletePAR 1280x928: 8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e
- D19 RGBA CompletePAR 1280x928: cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1
- All three source files remain unmodified. Godot render script is a scoped standalone adaptation of tracked godot_port/tc_factory/native_complete_par_probe.gd with dual SHA, true alpha, nearest texture filter and origin 0,0, allowing native files to be produced locally without changing game code.

## Genuine native evidence
- D18 Godot 4.7.2 native screenshot SHA: 14cf4bfe3288d6fd7c39c48349a4a24282c13df1620c3280cfd9ea6aea638ede
- D19 Godot 4.7.2 native screenshot SHA: a3d830b550e93ac49c4bdbec3d7c19489e41f7e5cd12a1b3d508350ce18b2e2a
- Renderer: OpenGL3 / Mesa llvmpipe software; native framebuffer each 1280x928, full Separate Sprite2D nodes at origin zero, nearest filter, original alpha composition.
- Godot-native screenshots vs PIL alpha_composite differ on 15,367 (D18) and 15,372 (D19) pixels at **maximum 1 RGB channel value per pixel** (the rest exact); no evidence of a scale or world-origin shift.
- D18 alpha=0 547,026, D19 alpha=0 547,754; both have >0 visible alpha pixels, and both SHAs were rechecked by Godot.
- Negative native tests, all passed with **exit code 2 and no screenshot**: wrong PAR SHA, all-opaque Master, all-transparent empty PAR.
- Audio ALSA fallback to dummy, VSync unsupported and root process warnings appear on CI-style Xvfb software renderer: nonblocking for this silent, visual-only native test. Do not treat as Windows GPU or sound QA.

## Visual blockers and M3/M4
D19 outer-4px high-opacity border =0 vs D18=250; the cost is overlap 1596 vs 868. D19 has cleaner margin but increased foreground clutter. Bridge anchor is fixed XY(554,334) in both; the exact walkable crossing between both lava banks is not certified as collision/pathing. Smoke near top boundary and large forge crowds remain visible. Keep both native screenshot variants for 1x **human Art HOLD**. Ground-first/independent all-non-ground PAR remains unchanged and neither sprite may be silently replaced. The target art style (32x32 tile/grid, top-down 3/4) has not yet passed expert review.

## Formal gate
- M1 source integrity/independent alpha/1280x928: PASS
- M2 true owner-private native Godot 4.7.2 source rendering: **PASS for D18 and D19**
- M3 dual-source negative QA: PASS; world art/bridge footprint/artifact crop: HOLD
- M4 second scene technical candidate: exists; **formal ART HOLD, 0/12**
- Game integration (map transition, collisions, avatar walking, events, battle, save/load): NOT_RUN
- T-A/T-B/other T-C branch: UNTOUCHED; Windows E: UNTOUCHED; Codex 0; Desktop Remote 0.

## Next full engineering unit
Run an isolated **actor traversal/collision/bridge-footpoint Godot scene** on these **same frozen source SHAs**, with an official game project branch integration smoke test. Only then select D18 vs D19 after actual human 1x art review. For current milestone, the previous inability to run private sources in Godot is NO LONGER a blocker; do not regress to synthetic-only QA.
