# FS Ground-only v2 Stage3 | 2026-10-30
State: ENGINEERING_PASS / GROUND_ART_FAIL / PAR_NOT_STARTED / FORMAL_SEAL_NO.

Actual execution:
- Original A2_VSCliff 512x384 FS Tileset sampled pixel-exact at 1x, with per-pixel X/Y source ownership TIFF.
- Seven 128x128 experiments N01-N07: N04 demonstrates 32px interrupted road from dirt-block copying, N06 builds continuous FS-native dirt path, N07 adds low flower pixels.
- Two 544x416 expansion smoke images R12A/R12B reused original Stage0 eight masks and verified Road/Root constraints.
- 58/58 independent native-pixel ownership/source whitelist/dimension/hash/topology/negative tamper QA PASS.
- Isolated ZIP cold rebuilt all nine Ground PNGs: 9/9 exact SHA repeat, 58/58 independent QA PASS.

Critical Art failure:
- R12 nonroad grass has 178821 world pixels but only 4107 distinct original Tileset addresses: source pixel reuse 43.54x. Visible 64px periodic striping.
- Roads too pale/straight; flower pixels too sparse; not comparable to approved ground3. No user artistic approval.
- These are engineering proofs and NOT formal Ground. No PAR has been attempted. Sealed K4 map/script/collision/passability unchanged.

Exact SHA:
- A2_VSCliff.png = 1007b0245b9ca1235c2ad7b37474bd0b232fe75a1255f83c9fb4c9e5c5e1669b.
- correct ground3 (1).png style reference = ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13.
- SCENE21 style reference = 4414db2f8d0be840a336679b44d74e5a549c0ad693d1e165250cc0d2f660e730.
- R12A = 070c2fc62e09bf54b2515211479b5afb63d144a2ee1c7c572d795889eefbe27b.
- R12B = e9a338edf7212072ddf00a8fe059f5bedf748a24a604f8c1b357de1d6e40eadd.
- Private ZIP 4664164 bytes, 65 entries, SHA eed286922835409443ec1aae36f88cfb254da54abcc604512f5a885ce012e430; CRC PASS.

Cloud binary (PRIVATE; verified Drive upload/readback):
https://drive.google.com/file/d/1e8GY_Go7isaPorPsn3ldbwbD0-FuTlZO/view

NEXT: Keep existing masks & code; design richer source-consistent green ground-only 1x art bank (not one 64x64 repeat), a less diagrammatic dirt path and low flora at approved 32px character scale. Human 128x128 Art PASS must precede production 544x416 or any PAR.