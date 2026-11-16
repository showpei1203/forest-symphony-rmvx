# Forest Symphony | A43 Cloud & Cold-Start Receipt | 2026-11-15

**ART HOLD; full migrated FS ATB/damage combat integration NOT RUN.**

## Durable sources
- GitHub implementation branch: feat/fs-asset-factory-v1-20261107.
- Code/asset commit: b5e91566331ec49061b300626e964bb3746bafca.
- GitHub current handoff: docs/asset_factory/CURRENT_HANDOFF.md.
- Owner-only Google Drive release ZIP: https://drive.google.com/file/d/1OFNZml1SpbENma0QWn3U0EFtLc9PGa76/view
- Owner-only A43 WIP Handoff: https://drive.google.com/file/d/1IFdX6PVDwg9kP7q0NxaU-Pc097inDTPJ/view

## Release identity
- Name: FS_A43_GODOT_ATTACK_REWRITE_GPU_PASS_ART_HOLD_20261115.zip
- Cloud metadata: 394058 bytes, shared=false, owner-only.
- SHA256: 37d7bb4ffb2274de4ebdf4afaf4835bd670ff1bf42b521572958f7e17a4ba19c.
- 134 archive files, ZIP CRC PASS; manifest revalidated byte-for-byte.

## Independent cold extraction QA
- Extracted ZIP into ephemeral local directory; deleted after run.
- Entire 133-file manifest validation: 0 SHA mismatches.
- New Godot 4.7.2 cold import exit 0.
- Cold native OpenGL AMD Radeon RX 6700 XT QA exit 0.
- Native suite result A43_QA_RESULT PASS. The 12-frame GPU pixel and hitstop tests repeated successfully.
- Raw records in Drive qa/A43_COLDQA_RESULT.json, qa/A43_COLD_GODOT_IMPORT_LOG.txt and qa/A43_COLD_NATIVE_GPU_LOG.txt.
- Cold F6 screenshot in qa/output/a43_cold/A43_COLD_F06.png.

## Quality gates
- Engine: PASS (standalone animation).
- Art: HOLD for final human 1x inspection.
- Formal full FS migrated combat: NOT RUN.
