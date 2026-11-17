# R14 Art Failure Log | 2026-11-18

1. Previous R13 workstream drift: transfer/save-load/entry gameplay being prioritized over actual art. FIX: R14 stops gameplay scope; only creates new scenery Ground/PAR and art QA.
2. Initial Python source scene regex matched 305 of 310 tree objects because five intentional boundary forest trees have negative x-axis footpoint coordinates. FIX: accept signed coordinates in whole-PAR source scene parser; regenerated and verified all 310 trees.
3. Source 1478×1064 Ground enlarged to 2560×1856 and repeated oak silhouette remain true art bottlenecks. R14 Ground3 clarity pass is a temporary candidate only; does not invent lost native pixels or erase all repetition. Keep ART HOLD.
4. Tree variant alpha integrity: 12 pure color variants retain original full-object alpha; 4 crown silhouette variants change crown alpha but preserve lower 21% foot/root and keep alpha-empty edge columns. Static whole-source checks PASS.
5. Godot 4.7.2 executable available on owner's Desktop during previous R13 run, but Desktop Commander reported OFFLINE during R14 art test. Therefore R14 native Godot GPU/physics has NOT RUN, and CPU screenshot comparison must be explicitly identified as derivative, not original GPU.
6. Ground3 is a separate non-overwriting alternate; if 1x image appears too soft, reject it and use PAR-only R14 scene while authoring a truly native-resolution new Ground source. Never silently replace original R13 Ground or claim ART PASS.
