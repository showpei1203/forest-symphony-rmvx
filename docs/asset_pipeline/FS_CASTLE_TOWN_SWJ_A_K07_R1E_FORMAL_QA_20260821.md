# FS Castle Town SWJ Child A K07 R1E Formal QA — 2026-08-21

## Result

**SWJ Child A | K07 Tower / Immediate Junction = FORMAL CHILD PASS / SEALED WITHIN OPEN SWJ PARENT**

The SW Junction parent is not sealed yet. Child A is now canonical and must not be modified unless Child B/C dependency revalidation proves a specific ownership transfer is required.

## Geometry

- parent: `SW Junction / K07 Perimeter Turn`
- bbox: `[200,640,305,770]`
- workcell: `105×130`
- placement: `(200,640)`
- opaque: `3,352 px`
- local alpha bbox: `[20,8,70,121]`

## Mechanical gates

- alpha values: `{0,255}`
- partial alpha: `0`
- Master-exact RGB mismatch on opaque pixels: `0`
- no resize / redraw
- connected owner components: `1`
- strong-green selected pixels after R1E cleanup: `0`

Opaque pixels on workcell boundaries:
- top: `0`
- bottom: `0`
- left: `0`
- right: `0`

## Semantic / purity gate

Child A owns only the visible K07 tower and its immediate structural junction masonry.

The jagged lower silhouette is intentional. Foreground vegetation visibly occludes the lower tower/body in the Master, therefore those vegetation pixels remain transparent and are not converted into tower ownership.

R1D -> R1E removed exactly `5 px` of verified green/background edge leakage near the roof/right edge. No remaining strong-green leakage is selected.

Working Ground contains no Master-identical pixels on the accepted Child A owner footprint, so no Ground-remnant cleanup or Ground restoration is required for this child.

## Dependency gates

- upstream sealed West Mid R1C overlap: `0 px`
- Child A does not consume the west `y=625` seam connector, which remains Child B responsibility
- Child A does not consume the outgoing diagonal wall beyond immediate junction masonry, which remains Child C responsibility

## Canonical Drive artifacts

- `FS_CASTLE_TOWN_SWJ_A_K07_R1E_EXTRACTED_PAR_105x130.png`
  - Drive ID `1wP4ISo884APxgWvUKGEJI2OAeWPXjzKO`
  - SHA-256 `ed12f847c36860bbb0afc6ccc71d8a360d7bea738d5234fbd670a9465cb690c2`
- `FS_CASTLE_TOWN_SWJ_A_K07_R1E_BINARY_MASK_105x130.png`
  - Drive ID `1UOWEk5NOMdYqWqHBIG62b7zYs-slwb79`
  - SHA-256 `c2fe4b347d195b7b5dfbd9457977d3a2a1bafe5314329436999b26653f000b62`
- `FS_CASTLE_TOWN_SWJ_A_K07_R1E_CHECKER_5X.png`
  - Drive ID `1bKQ-k_VqBBgIUYT_TgQpD0lASliDx_Cp`
  - SHA-256 `76750e949e975b8c2cc7474fde01356a77b368a35837a4f54a1b6f52913203ae`
- `FS_CASTLE_TOWN_SWJ_A_K07_R1E_QA_OVERLAY_5X.png`
  - Drive ID `1iiQ3p23IEHpBTRANdXl-IK8Clb4pZm3V`
  - SHA-256 `2fed1efa1a5f768dff6d4661c86ac3588fce5a759f6fc9d7922eb45e0c967c8d`
- `FS_CASTLE_TOWN_SWJ_A_K07_R1E_QA_REPORT.json`
  - Drive ID `1yEMFeDeJoosi7Px-U1I7u0yPVk3zIlt7`

## Next legal step

Proceed to **SWJ Child B | West Seam Connector** using staging bbox `[155,625,230,700]`.

Child B must prove row `624/625` visual continuity with sealed West Mid while preserving `0 px` ownership overlap with West Mid and Child A.
