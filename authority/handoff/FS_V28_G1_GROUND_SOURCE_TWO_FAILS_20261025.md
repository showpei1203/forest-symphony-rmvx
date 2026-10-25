# FS v2.8 Ground-only Gate G1 — Two candidates rejected

Date: 2026-10-25. User-approved process requires source-only artifacts to pass before any Ground/PAR compilation.

- G1-01: 1434x1097 RGB, SHA256 `8a6ad0d6db6e0618e8289345b651afea8b564a71f2c5ea6970cd0a2c111cb271`. Pleasant organic soil paths, but vertical trunks, shrubs, foliage, and rocks contaminate Ground. **FAIL**.
- G1-02: 1434x1097 RGB, SHA256 `8b51d81ab455d18ef94af94d8818715457afb83c5f2c2bcadccc764b7f66dc37`. The generated scene contains a full cottage, roof, barrels, fence and large trees. **FAIL**.

Both may only serve as style concepts, not valid Ground Source; absolutely no reverse extraction as a default. This confirms that prompting a full-scene generator not to create objects is insufficient.

Next controlled test: generate separate grass/dirt and flat decal surface materials, create deterministic road geometry masks, compose Ground and inspect Ground-only at 100%/200%. Ground stage must pass before any object is added. Native VX and G2–G9 were NOT RUN. Retain negative examples and current v2.4/v2.5 visual fails as regression fixtures. Formal sealed FS, v2.1/v2.2/v2.3.3 unchanged.

Drive handoff: https://docs.google.com/document/d/1EF41jKqy4FHnNQllLs1D_UXPKbx6mGU10L4_B4Pg09c/edit
