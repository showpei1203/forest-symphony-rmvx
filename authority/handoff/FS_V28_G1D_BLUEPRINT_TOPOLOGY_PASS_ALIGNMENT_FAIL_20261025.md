# FS v2.8 G1D semantic route Blueprint | 2026-10-25

The original G1B 544x416 Ground art remains unchanged, SHA256 `1c6cfc72368b4f2d7ffff9f21d56192aa91eb30244ac641e9baac881c50be053`.

G1C color segmentation was rejected. G1D authored explicit 32px-grid route lines independently of pixel color, with five world-edge entrances. The 17x13 candidate passage mask has 96 traversable cells, all 96 reachable from north by four-neighbor BFS. All five entrances connected. Deliberate mutation adding an isolated passage cell was detected (1 unreachable).

**Mechanical topology PASS, visual road registration FAIL**. Reviewing overlay on actual Ground shows blue mask covering patches of grass/shrub instead of natural dirt path. Therefore mask is NOT accepted for Collision/Navigation, no VX compilation, and release BLOCKED. User geometry acceptance pending. G2 Ground visual review also pending.

Next: adjust centerlines/road widths to visible route using a reviewed Blueprint overlay; rerun adjacency, all entrances, anti-island negative test and native passability only after visual alignment approval. Preserve negative witness and all sealed baselines.

Drive Handoff: https://docs.google.com/document/d/1ivLGG50x_81orY5Nir5IVVCqpP95vevEmWia5mLc7YQ/edit
Private evidence ZIP available in user conversation (not public repo), SHA256 `892b210ae08483144a18c916ffcfb49b454a5698c89f1ba5d0461c7be836740b`.