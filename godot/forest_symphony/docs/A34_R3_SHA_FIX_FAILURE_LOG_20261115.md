# A34 R3 | Critical scene source SHA fix | 2026-11-15

## Actual bug found
The A34 R2 candidate scene changed `source_file` to `res://private_assets/independent_par/a34_cottage_a_full_rebuild_candidate.png` but retained the original house `source_sha256` (`535f71fb4c581c3af28d933c790d850c1449ee68c8dc7b6417506bdd8f0d0a55`). This is an invalid source-lock pair and was missed in R2.

## Actual repair (private candidate only)
Replaced the single old source hash in `scenes/a34_r2_house_candidate.tscn` with the candidate PNG SHA256 `17025ce677dbe1ae18ad59acfa33b0cce6136eaf3d2ad2098ce65ca680709456`.
Repacked private 157-member candidate as `FS_A34_R3_HOUSE_SHA_FIXED_PRIVATE.zip` (61,614,438 bytes; SHA256 `cfc3a0f4510700cdb5061abc66edd6196c511aa33c16a56053532f15faf1b339`). ZIP CRC PASS; SHA binding PASS. A33 baseline untouched.

## Gates
- Source hash mismatch: FIXED
- ZIP CRC: PASS
- New whole-house pixel-art quality: ART HOLD (resized concept, not 1x approved)
- Godot native render and gameplay collision: NOT_RUN
- Private Drive upload: NOT_DONE; file exists as conversation artifact only
- No claim of A34 completion

## Prevent recurrence
Every asset substitution must update both `source_file` and `source_sha256`, then run an exact hash-binding assertion before packaging or native run. Do not accept a ZIP as engineering-ready from CRC alone.
