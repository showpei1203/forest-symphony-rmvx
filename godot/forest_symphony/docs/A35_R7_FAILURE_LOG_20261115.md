# FS A35 R7 Real Shadow | Failure Log | 2026-11-15

**ENGINE PASS / NAV PASS / ACTUAL 2D SHADOW GPU PASS / ART HOLD**

1. **No effective shadow from existing lamps:** Four R3 lanterns are positioned in the village center and most tree roots are >160 pixels away. Their original small radius can yield zero visible tree-shadow difference even if shadows are switched on. R7 adds one isolated test-only light at (260,785) near 25 real trees within 250px; old R3 lights unchanged.
2. **Correct Godot shadow primitives:** 2D shadows require `LightOccluder2D` with `OccluderPolygon2D` and a PointLight2D with `shadow_enabled=true`. Merely adding an atmospheric overlay or background dark blob is not physical light occlusion. Used actual engine primitives; 175 tree child occluders verified in real Godot source QA. Official Godot docs: https://docs.godotengine.org/en/4.6/tutorials/2d/2d_lights_and_shadows.html .
3. **Shadow visible and localized:** Two original GPU 1280×928 frames actually produced in Godot 4.7.2, one with light shadows OFF and one ON. Exact image subtraction: 17,943 changed pixels all within 263px forest light ROI, zero outside. Differencing done from native images, not software-rendered replacements.
4. **Overbroad-cast risk:** R7 simplifies each tree to a small trunk polygon based on existing footprint data; does not trace full foliage alpha. This is intentional prototype geometry, so do NOT claim foliage-shaped shadows or fully realistic dynamic canopy.
5. **No source/physics regression:** 187 existing PAR owner positions/source SHA/CollisionShape2D retained; original R6 scene and Ground unchanged. Real Godot navigation 8/8, all four main routes unchanged. R7 code attaches additive, independent scene nodes.
6. **HD-2D scope:** Only the isolated forest test lamp participates in study shadows; original R3 global lamps still have shadow_enabled=false. No true 3D depth-of-field or volumetric light. Full art still HOLD.
7. **Release packaging:** Complete 343-file R7 source ZIP (176,207,023 bytes, SHA 9e32a559fc40b90c38a573c227106f9f33c6c48a5165ccd55ca96af7f55fb3eb) and 18-file lean R7 original GPU evidence ZIP (5,969,885 bytes, SHA fac653f0e1bca3529cb2fe9bff10038ce681726d6437563d9daf301079aecb81) stored in private Drive mount; use exact provider file IDs after sync. Source-only GitHub text, private PNG source never public.
8. **Continuity:** Previous R6 13-tree conifer art remains ART HOLD and has official native QA. Do not overwrite sealed R2–R6 or parallel A36C.

Next: visual review and performance profiling of trunk shadows in native Godot, then canopy occluder extraction and soft shadow filtering as a separate candidate. Keep A35 R7 shadow study independent until full ART approval.
