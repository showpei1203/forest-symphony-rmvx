# FS 大型地圖 1280x928 Gate v1 (2026-11-01)
ACTIVE. Mission: complete LARGE maps, not infinite iterations of 544x416 probes.

Baseline reference Ground3 is true 1280x928 RGB (40x29 32px VX tile grid), original is visual reference only, never copy flattened Ground3 into new Ground/PAR. A34 actual new opaque full-size Ground and separate full RGBA PAR, compiled from 210 individually owned source images (104 trees, 96 shrubs, 10 landmarks) with provenance, alpha, x/y/foot, collision. Native new forest is not a complete finished village.

A34 collision: 104 blocked native foot cells, 1056/1056 passable cells BFS reachable. There are five connected road routes, thirteen habitat zones. No environmental shadow or light in PAR, these are separate future render layers. No gratuitous black elevation lines. Source A32B/A33F preserved.

Actual RPG Maker VX Game.exe Map050 40x29, viewport 544x416 scrolling corners, center, edges, 210 individual sprite assets loaded, 11 cases/22 screenshots. After scene title fade, camera cases 2..10 maximum pixel RGB channel mismatch 3 compared to correct source crop; initial two camera cases have title overlay artifact and FAIL strict pixel-parity. Real tree block move (15,10)->(15,10), real road (20,14)->(21,14). Godot 4.7.2 RX6700XT OpenGL full 1280x928 6 frames plus 6 actual viewport crops, independent PIL composite delta max1 RGB and 0>1. 3626/3626 cold native VX source SHA same, actual cold Game.exe boots with 210 assets and 0 RGSS modal.

Engineering prototype passes, user aesthetic PENDING, production BattleRegression test-only bypass unresolved, Formal Seal NO.
NEXT A35 must add real source-first standalone buildings, cliffs/terraces, roof and wall occlusion, collision and clear entryways on SAME 1280x928 grid; NOT return to small 544x416 as final output. Building/cliff materials are private and license must be assessed before publication.