# A34 R1 | Source audit and failure log | 2026-11-15

## Actual input
Owner-only A33 ZIP fetched from Drive ID `1mIJVMUsdHJu0oVUqBbVqvGhhJ582o7zl`, 61,517,282 bytes. This report is about the **A33 1280x928 village**, not the separate A36C large forest.

## Executed source audit
- ZIP CRC: PASS
- A33 ground SHA vs embedded manifest: PASS `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`
- Both house SHA vs manifest: PASS
- Both house sizes vs manifest: PASS
- Both transparent source alpha bounds: nonempty PASS
- Both house source paths referenced by Godot scene: PASS
- House A annex: 254x252, alpha bbox (10,34,241,244), alpha coverage 0.5469, scene position (285,406)
- House B moss roof: 214x252, alpha bbox (11,36,203,244), alpha coverage 0.5660, scene position (1046,419)
- Godot native run: NOT_RUN. Physical collision verification: NOT_RUN. New art: NOT_CREATED. ART HOLD.

## Art findings and failure log
- Left annex roof/wall material and silhouette do not read as one coherent construction with its main cottage. Avoid editing roof fragments in isolation.
- Right cottage is a better visual style reference, not proof of acceptance.
- Existing source images remain untouched. Ground SHA remains baseline.
- Next implementation: whole-house new left source, then right source consistency pass, independent PAR replacement, native Godot 1x A/B and ROI pixel-difference gates.

## Reproduction
`python tools/a34_house_source_audit.py /path/to/private_A33.zip --out A34_house_source_audit.json`
Do not commit private A33 ZIP, house PNG, or private screenshots.
