> **2026-10-25 Native Collision and Final ZIP Update:** True Windows Game.exe was executed on an isolated copy of v3.0 visual engine with v3.1's 14 blocked tile logic. Logs: V31_DOOR_WALK_PASS=true, V31_WALL_BLOCK_PASS=true, V31_NATIVE_COLLISION_GATE_PASS. This proves native collision behavior only, NOT full v3.1 4-PAR artwork or human visual approval. Final conversation ZIP includes the native LOG: 112 entries, 15,778,345 bytes, SHA256 746194458a19eca065df21acfa3a841e7786ce186cacc9393ef1eca89ab0d9b1. Earlier ZIP hash is superseded. Full art G2/G3/G8 remains blocked. Google Drive ZIP binary readback is not confirmed.

# FS v3.1 | Issue Taxonomy and Collision Repair
Date: 2026-10-25. Status: isolated technical candidate; visual FAIL/PENDING; native NOT RUN; release BLOCKED.
Drive full handoff: https://docs.google.com/document/d/14UdQ7mkzwS_Sf0Ue8HKDzfok2snKmLxGB5CvmEmILo4/edit

Six regression categories:
FS-ART-101 Ground clarity and style mismatch: three native-size source contrast A/B/C test versions; style and missing source detail still G2 PENDING.
FS-ART-102 House upper/lower materials: old Source includes baked green ground; destructive matte not a true clean architectural Source. G3 FAIL pending a full standalone house.
FS-ART-103 Front wooden stump cut by matte: standalone sprite restores 114 visible pixels preserved from original RGB; static PASS, human silhouette PENDING.
FS-COL-201 Door-front blocked by overbroad source contact rectangle: new manifest 14 blocked tiles, 292 connected walkable; (5,6) WALKABLE, (5,5) BLOCKED. Static PASS.
FS-RUN-202 Original RGSS2 hardcodes FSRich::BLOCKED; merely changing Collision PNG cannot change the game. Isolated Scripts.rvdata is rebuilt with the same 14 tiles, 4 objects, unique Game.ini title and V31 native door test. Static PASS; native game NOT RUN.
FS-QA-301 Pixel-perfect Master, CRC and SHA are technical-only; Ground/Source/Native/User art gates remain independent and blocked.

Executed proof: 24 technical checks PASS, 3 mutation checks trigger, cold-extract rebuilding source and native scripts reproduces SHA of Master, Collision, independent woodpost and Scripts.rvdata byte-for-byte.
Private conversation ZIP FS_V31_SOURCE_COLLISION_FIX_TECH_CANDIDATE_20261025.zip; 111 files, 15,777,484 bytes, SHA256 82f28cc845dedd8cc64754265a894ca7c759b9400fed09ec5293a4118d8deb9c.
The private source art and binary are not checked into public GitHub. Drive ZIP binary backup/readback is NOT confirmed.
Human art FAIL/PENDING and real Windows Game.exe execution NOT RUN. Preserve prior sealed FS and v2.1/v2.2/v2.3.3 unchanged.
Next: real native door-front movement and Game.exe screenshots, 100% Ground A/B/C art gate, full standalone clean house generation. Never promote v3.1 as formal art pass.