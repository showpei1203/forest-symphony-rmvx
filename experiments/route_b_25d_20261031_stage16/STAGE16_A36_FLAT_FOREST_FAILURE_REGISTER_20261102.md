# A36 Flat Forest Failure Log | 2026-11-02

1. Terrain PAR in A35C was an unverified interpretation. Freeze all cliff/elevation PAR construction until original FS Ground/PAR/Paraxell artwork and RGSS2 depth routines are compared. Avoid guessing from cliff silhouettes.
2. Original `Overlays/ground3.png` is NOT actual visual source `Graphics/Parallaxes/ground3.png`: par3 source RGB matches the latter 97.568%, the former ~1.5%. For ground8/par8 visual match 100% and the other ~0.3%. Match source using pixels, not names.
3. A36 Ground builder attempted mutation of read-only numpy `np.asarray(PIL)`. Fixed `.copy()`.
4. A36 radiating road network is too geometric and foliage too regular for final user-approved FS style. Art pending, no formal seal. Elf village buildings not yet installed.
5. First static PAR merged objects with identical footY sorted by id, while Godot used insertion order; max RGB discrepancy170. Fixed original stable ordering at ties; current actual Godot max RGB difference1, delta-over1 zero.
6. Real VX native source pixel audit maximum RGB difference2; do not advertise exact0 across all windows.
7. Native collision verifies one tree blocker and one road movement, not a complete NPC/house gameplay suite. 64 tree-root blocked, 1096 all connected.
8. Original `Paraxell` spelling/location not yet independently confirmed. Do not assume `Parallaxes` is necessarily the same user reference.
9. Original production files untouched. Stage A36 test-only RGSS script should never be substituted for main sealed battle project.
