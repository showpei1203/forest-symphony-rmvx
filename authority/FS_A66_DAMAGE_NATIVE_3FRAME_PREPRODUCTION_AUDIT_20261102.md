# FS A66 Damage native 3-frame source audit | 2026-11-02

**Status:** Source/structural audit, **not** an actor visual candidate. A65 Magi Skill Use C2 is still pending user art approval.

## Verified original input
- Actual image: FS original 06_Damage_REFERENCE_3POSE.png, native 96x32, three 32x32 frames.
- SHA256: d18c360e34dede68892fece049db436f6e19f594bdbd0c51840259c34a8a553f
- Native three frame alpha bboxes: F0 (0,0)-(27,32); F1 (2,1)-(31,32); F2 (1,1)-(30,32).
- Head horizontal alpha centroid: F0 15.3012; F1 17.6735; F2 16.6735. F0->F1 +2.3723px; F0->F2 +1.3723px.
- Shoulder/chest centroids x: F0 13.6866; F1 16.4604; F2 15.4604.
- Pelvis/feet centroids x: F0 16.2143; F1 16.9929; F2 15.9929.
- Native F0/F1 changed pixels by ROI head 269, torso/arm 237, pelvis/feet 141; F0/F2 changed pixels head 268, torso/arm 226, pelvis/feet 140.
- Therefore **Damage must not be generated as Waiting sideways idle or Magi Skill Use effect**. It is a SEQUENTIAL three-pose hit reaction with changed body silhouette. Playback order/animation time must follow FS Tankentai conventions, not an invented idle loop.

## Reusable baseline, continue from current work
- A62 Moving to Close Attack USER PASS; A63-W3B Waiting technical/human pending; A64-C3 Critical Damaged technical/human pending; A65-C2 Magi Skill Use technical/human pending.
- New candidate must retain approved A62 character identity and 45-degree battle view, no hidden weapons/FX, three real frames and human GIF review before VX.
- Source reference libraries remain:
  - https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
  - https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe
- Source library index: authority/FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json. Metadata inventory is not an exhaustive motion interpretation.

**No paid generation, no VX changes, and no A66 art PASS claimed.**
