# Forest Symphony — RGSS2 Source Authority

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
