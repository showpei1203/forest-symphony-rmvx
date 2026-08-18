# Forest Symphony — Background Execution Authority

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
