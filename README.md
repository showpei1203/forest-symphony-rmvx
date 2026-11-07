# Forest Symphony — RGSS2 Source Authority

## P0 現行儲存／新地圖規則（2026-11-07）
[FS 現行規則總索引](authority/FS_CURRENT_RULES_INDEX_20261107.md) 是所有新對話、Agent 和施工的第一入口，舊封版測試資料保持原樣。

所有需保留的藝術素材、原始檔、工程/二進位、ZIP、截圖、QA、Handoff 保存 **Google Drive**，可公開程式、規範與版本紀錄保存 **GitHub**。使用者 PC 僅供必要安裝與最短原生 VX 執行暫存；雲端確認後清理；不得再以舊 `E:\` 工作夾或 Git clone 作成果目的地。權威：[P0 雲端規則](docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。
FS 新精靈村以**完整 Master-first** 一張圖為座標與 RGB 權威，Ground-underpaint/物件語意 Mask 作候選，PAR 從同圖原 XY 擷取；作者層 GroundOnly/CompletePAR 與執行層 FullGround/OcclusionPAR 不可混淆。RGB 相同不代表物件邊界或通行已驗證，實際 VX 與人工作圖 Gate 需獨立通過。
*此處以下 Phase49J/K5 是 2026-08 的原始封版歷史，不能覆蓋 2026-11 的現行工作方式。*

This repository is the text-source counterpart of the Forest Symphony RPG Maker VX project.

## Authority split
- Google Drive stores runnable/binary authority, SEALED builds, `Scripts.rvdata`, logs and large assets.
- GitHub stores exported Ruby/RGSS source and reviewable version history.
- Linear stores roadmap, issues, test state and acceptance state.

## Runtime safety
The repository does not redefine RPG Maker VX script order. `authority/SCRIPT_INDEX.*` records the canonical 505-entry order, Script ID, Script Name and content hash.

## Branch policy
- `main`: latest real-machine PASS / SEALED source authority. Staged baseline is Phase49J.
- `develop`: current candidate. Staged candidate is Phase49K5, unverified on real hardware.
- `phase/*`, `fix/*`, `feature/*`: optional high-risk work branches.

A candidate is never promoted to `main` because it merely compiles or looks correct. Real RPG Maker VX PASS evidence is required.

## Binary policy
Do not commit `.rvdata`, large Graphics/Audio, or full game ZIPs here. They belong in Google Drive Binary Authority.
