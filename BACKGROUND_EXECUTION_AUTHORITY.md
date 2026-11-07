# Forest Symphony — Background Execution Authority

## P0 雲端儲存覆寫（2026-11-07）
本文件的「背景可運行」只代表視窗失焦仍可執行，**不代表可在使用者 PC 背景長期儲存專案或常駐寫入工作檔**。所有新成果、Log、截圖、交接及備份以 Google Drive/GitHub 為唯一正式保存。必要軟體/Runtime 安裝保留；非得本機跑 VX 只能最小暫存，雲端檢核 SHA 後清理。詳見 [P0 規則](docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。

Version: 2026-08-19

This repository inherits the shared Google Drive authority `SHARED_BACKGROUND_EXECUTION_AUTHORITY` (Drive file ID `1OMLXIcw9MU0Vi3RW4THN0nHQ7ZiDt16LjpODMjq5V7M`).

## Permanent rule
- Runtime, AutoRegression, validators, generators, compilers and long-running tooling must be background-capable: losing foreground focus must not unnecessarily stop progression.
- Automated runs should proceed autonomously after launch and emit machine-readable status / LOG evidence.
- Foreground-only work is allowed only for explicitly visual/manual acceptance.
- Background execution does **not** authorize unsafe threads. Existing rule remains: no `Thread.new` touching `$game_*`, Scene, Sprite, Bitmap, or Viewport.
- Prefer normal-loop state machines, staged jobs, detached/offline validators and external tooling.
- Do not reopen SEALED runtime merely to retrofit this policy; new/touched infrastructure must comply without regression.

## Acceptance
A new infrastructure/harness path is not acceptance-complete if it unnecessarily stops just because another application becomes active.
