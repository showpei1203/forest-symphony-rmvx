# FS v2.8 G1B — New Continuous Ground Candidate (2026-10-25)

Status: G1 mechanical PASS; Ground source semantics and G2 visual HUMAN PENDING; G3–G9 NOT RUN. Release BLOCKED.

G1-01 and G1-02 failed because AI generated trees/buildings into Ground. This iteration generated a new 1434x1097 **Ground-only oriented** forest meadow with roads, low floral vegetation and stones. Selected a direct 544x416 source crop at pixel `[x420, y300]` at native resolution (no rescaling or blur). No house or tree trunk was observed in crop, but human review is still required for dense flowering vegetation and passability.

- Source SHA256 `a5b9fe9f62bb7d682d1ca91344dd660d2717a8314cb78eb72984015ea18b9f72`.
- Ground crop SHA256 `1c6cfc72368b4f2d7ffff9f21d56192aa91eb30244ac641e9baac881c50be053`.
- Package SHA256 `ac870aa48a55bc49725ce3fdd0cbda9c7747194ced1f85b4b3787d3ff09785cb`, 5,257,312 bytes.
- `verify_g1_source.py`: PASS, confirms source/ground SHA, exact integer crop, 32px world basis.
- `test_negative_g1.py`: expected BLOCK on tampered source pixel.
- Automatic estimated road mask is **CANDIDATE_ONLY** and must not become authoritative collision or path data.

All private art and build scripts included in conversation download ZIP, not GitHub; Drive at present contains handoff documentation, not confirmed raw ZIP bytes. Drive: https://docs.google.com/document/d/1NB98gfRir1-QzU5WTu3EpnrOg-6mfky9iAaE-KtYwpA/edit

Next: G1 human scene semantics + G2 100%/200% ground visual pass, then separate complete transparent PAR source. All sealed FS, v2.1/v2.2/v2.3.3 preserved.