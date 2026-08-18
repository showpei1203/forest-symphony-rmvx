# Forest Symphony Forward Roadmap — after Phase49K4

## P0 — Phase49K5 Cross-Suite Frame Invariant Fix
目的：把唯一 TEST-only mismatch 收斂。
- Formal delta 0。
- page478 only。
- stable guard keys exact。
- Graphics.frame_count 改 monotonic non-decreasing。
- 成功目標 1854/0/0。
- PASS 後 SEALED Phase49K。

## P1 — Final Integrated Soak XI
以同一 Scripts hash、fresh process 分開跑：
1. Nonbattle 411/0/0
2. Battle 1388/0/0
3. Cross-Suite 1854/0/0
理由：已證明 RGSS2 32-bit native/resource ceiling，避免為「壓力」而重新巢狀超載。

## P2 — Release-mode / TEST Isolation Audit
- $TEST=false 無測試快捷鍵副作用。
- TEST observers/probes 全清。
- deterministic RNG OFF。
- temp save files 0。
- synthetic DB slots 0。
- no Thread.new。
- protected scripts exact。

## P3 — Save / Old-Save End-to-End Acceptance
在複本存檔上：
old save load → Scene_Map → Menu/Ring → one battle → map transfer → save-copy write/read。
正式 Save1–9 不改動。

## P4 — Visual Acceptance
人工視覺驗收：
- Battle HUD
- Ring / SoulBook / Menu
- Normal Minimap
- Vehicle/Fog/Overlay
- Scene transitions
- summon sprite cleanup
- 無白屏、殘影、disposed bitmap reuse。

## P5 — Final Authority / Dead Wrapper Audit
確認：
- Setup authority
- AI authority
- Skill Cost / Effect / Damage
- Equipment teaching/passive/combo
- Save compatibility
- RandomDungeon / Minimap
- Shop/Economy
沒有 late duplicate wrapper 重新奪權。

## P6 — Final Release Package
需要使用者當前完整 RPG Maker VX 專案來源。
輸出：
- 完整 runnable ZIP
- Scripts.rvdata
- PASS logs
- Validation
- hashes
- release notes
- final handoff
