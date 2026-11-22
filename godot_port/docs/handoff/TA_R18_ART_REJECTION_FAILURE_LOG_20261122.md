# FS T-A R18 retrospective Failure Log — 2026-11-22
- R16/R17 previous iterative procedural pose passes were reviewed and owner rejected art categorically. Corrected from "ART HOLD" to **ART REJECTED**.
- R18 first version: automated F0==F11 assertion failed due a back-foot offset linked to `i<5`. Repaired with guard cycle equivalence `i<5 or i>=10`. Recorded; not silently treated as pass.
- R18A produced 12 individually-keyed source pixel poses with unchanged original A62 head. After 1×/4× review, legs/boots resembled simplified stiff polygons and chest weight shift unconvincing. **REJECTED**.
- R18B second attempt adjusted F6-8 near-arm/fist and body at contact; still looked like diagonal segmented bar and lacked whole-body punch mechanics. **REJECTED**. Stop further procedural microfixes; next source must use five independently drawn key silhouettes.
- Correct Godot Windows official 4.7.2 real GPU 73/73 at 60Hz, 12/12 source vs capture 0 mismatch, visual contact once: ENGINE PASS only, NOT art acceptance.
- Private rejected QA ZIP 208826 bytes, 92 files, CRC PASS, SHA `f82235e2251467dda54b9e20e9831619811f2feaa904269c698bcebc2cd6120e`. 13 files confirmed via authenticated Drive server; shared=false.
- Live original FSBattle NOT RUN. PixelLab provider job NOT RUN, no new fee. No merge/no A52 overwrite. Original A62 identity preserved.
