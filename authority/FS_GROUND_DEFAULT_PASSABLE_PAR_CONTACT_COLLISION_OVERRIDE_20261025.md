# FS Ground Passability Authority Override — 2026-10-25

User authority: Ground defaults to **walkable everywhere**. Exceptions only for water, holes/voids, cliff gaps or explicitly marked hazard terrain. Grass, dirt paths, flowers and texture colors do not create movement restrictions. Therefore G1C color-road segmentation and G1D route centerline mask are **retired as Collision gates**; preserve logs as research/negative examples only.

After PAR objects are placed, derive collision blockers from per-object **ground-contact footprints**, not full sprite alpha/canopy/roof bounds. Foreground occlusion stays separate. Final collision = explicitly blocked terrain exceptions UNION PAR ground-contact blockers, with a single Scene Manifest governing all masks. Test actor footbox, reachable spawn, 4-direction movement, blocked entries and under-canopy traversal in native VX. Ground visual quality G1/G2 remains mandatory, but road-mask topology is not a prerequisite. All sealed FS and earlier baselines remain untouched.

Full Drive SOP: https://docs.google.com/document/d/1VZiGrojEKjh0BeB3FMk71swKtvythCu-j-4PtY17ae0/edit