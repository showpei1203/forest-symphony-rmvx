# Forest Symphony Standard Broadleaf — Style DNA v1.1

- Project: Forest Symphony
- Asset family: `standard_broadleaf`
- Purpose: define the visual language for generating NEW tree assets without copying legacy silhouettes
- Authority date: 2026-08-18
- Related issue: `SHO-34 | FS Parallax Master Object Benchmark I`

## 1. Why this document exists

Legacy Forest Symphony tree images are **analysis references**, not shape templates.

The generation pipeline must learn the family-level visual language from existing FS assets, then create new original tree individuals. A generated tree should feel native to Forest Symphony without reproducing the silhouette, canopy arrangement, trunk pose, branch layout, or root spread of any source tree.

Core rule:

> Learn the family DNA. Do not copy the individual.

A second core rule was added after the first text-only generation failed by drifting into a fantasy / landmark tree:

> Standard trees must be visually ordinary enough to repeat across a forest.

Originality is required, but **originality must not be achieved by increasing spectacle, fantasy, root drama, trunk twisting, or decorative complexity**.

## 2. Evidence used to derive the family

Current observations were derived from the uploaded Forest Symphony references, including:

- `tree variation.png` — strongest standard / production broadleaf direction
- `Trees1.png` — secondary reference for foliage clustering, bark texture, and broader legacy broadleaf language
- `Hanzo-VSTrees03.png` — conifer contrast reference; explicitly excluded from the standard broadleaf silhouette
- real FS map / parallax references such as `SCENE21`, `groundXX`, and `parXX` — used to judge in-map scale, repetition tolerance, grounding, and occlusion behavior

These references are used to derive rules below. They should not all be supplied directly to the image generator as shape-conditioning images.

## 3. Role / gameplay function

`standard_broadleaf` is a normal reusable forest tree family.

It is NOT:

- a sacred / ancient landmark tree
- a boss-arena centerpiece
- a cinematic hero tree
- a quest tree
- a visually unique story prop
- a conifer
- a dead tree
- a seasonal special variant

The family must tolerate repeated placement across forest maps without every tree demanding visual attention.

### Visual salience authority

A standard tree should feel like **environmental vocabulary**, not a visual exclamation mark.

Preferred:

- low-to-moderate visual salience
- ordinary believable forest-tree anatomy
- restrained asymmetry
- restrained bark drama
- restrained root spread
- restrained base decoration
- enough individuality to avoid cloning, but not enough to imply special gameplay significance

Avoid:

- tree that appears sacred, magical, ancient, unique, named, quest-relevant, boss-related, or cinematic
- elaborate trunk twists that become the visual focus
- giant roots that dominate the lower third
- vine / moss / leaf ornaments climbing the trunk unless extremely subtle
- intentionally theatrical branch gestures

## 4. Silhouette DNA

Target silhouette:

- medium visual scale
- broadleaf crown
- compact, readable outer contour
- generally rounded / irregular oval / mild teardrop tendency
- moderate asymmetry, not perfect bilateral symmetry
- moderate width; avoid huge horizontal spread
- one cohesive canopy mass rather than many disconnected floating puff clusters
- trunk must remain visually discoverable
- silhouette should look plausible for a normal reusable forest tree

Avoid:

- giant ancient-tree spread
- perfectly spherical topiary shape
- conifer triangle
- highly theatrical S-curve trunk
- extreme leaning composition
- oversized roots dominating the sprite
- deliberately iconic / emblematic silhouette

## 5. Foliage DNA

Foliage should read as grouped pixel masses, not individual-leaf noise.

Preferred:

- chunky cluster grouping
- approximately 3–5 major canopy masses at a macro level
- secondary breakup inside those masses
- dark interior pockets to create depth
- clear highlight groups rather than evenly distributed sparkle
- restrained edge protrusions
- good readability at RPG Maker VX map scale
- canopy remains visually dominant over trunk ornamentation

Avoid:

- hundreds of tiny starburst highlights
- fuzzy / painterly leaf texture
- excessive micro-noise
- cloud-puff repetition where every cluster has the same round shape
- neon highlight coverage over the entire crown
- unusually dramatic isolated crown lobes that make the tree look designed as a centerpiece

## 6. Value / palette DNA

General foliage palette behavior:

- dark forest green interior shadow
- mid green primary mass
- lighter yellow-green highlight groups
- highlights concentrated rather than uniformly scattered
- natural saturation, not neon

General bark palette behavior:

- warm brown / tan / muted beige family
- dark bark grooves
- readable mid-tone planes
- limited lighter highlights

The goal is **clear value grouping first**, hue variety second.

## 7. Lighting DNA

Preferred lighting:

- simple upper-left or upper-side bias
- broad cluster-level shading
- readable light / mid / shadow organization
- no cinematic rim light
- no bloom
- no glow
- no painterly soft gradient dependence

The tree should remain readable when placed among other FS map objects.

## 8. Trunk / branch DNA

Trunk:

- central or near-central
- medium thickness
- sturdy enough to read at map scale
- naturally tapered
- modest organic variation
- should remain partly visible beneath / through the lower canopy
- should support the canopy rather than become the main decorative subject

Branches:

- a small number of main structural branches
- approximately 3–5 readable primary branch directions is a useful baseline
- branches can disappear into foliage, but the structural logic should remain understandable
- avoid tangled branch webs
- avoid decorative symmetrical forks
- avoid sweeping heroic branch gestures

Bark texture:

- pixel-clustered grooves / planes
- enough texture to read as FS-style bark
- not ornate enough to become a landmark asset
- avoid glowing strips, strong spiral bands, braided / twisted rope-like bark, or exaggerated carved appearance

## 9. Root / ground-contact DNA

Root base should communicate contact with the map floor.

Preferred:

- modest root flare
- short visible roots
- slightly irregular spread
- limited integrated grass / moss / low foliage if needed
- clear anchor area at trunk center / bottom contact
- roots remain subordinate to the overall tree silhouette

Avoid:

- sprawling fantasy roots
- large root tentacles
- root system wider than the normal canopy logic requires
- decorative base becoming a separate scene
- roots that occupy a large fraction of the sprite height
- roots crossing / braiding into a dramatic emblem

## 10. Pixel language

Target:

- crisp pixel edges
- discrete pixel clusters
- restrained anti-aliasing
- no blur
- no painterly interpolation
- no photographic bark / leaf treatment
- no high-resolution illustration pretending to be pixel art

The generated asset may later be downsampled / cleaned in Aseprite, but its source structure must already be compatible with clean pixel treatment.

## 11. Production / repetition DNA

A standard family asset must be easy to vary.

Future siblings should be able to change:

- canopy width
- canopy height
- left/right mass balance
- trunk gesture
- branch layout
- root spread
- highlight distribution

while retaining:

- family palette behavior
- foliage cluster language
- bark language
- visual scale
- grounding logic
- RMVX readability
- low-to-moderate visual salience

If every sibling looks like the same tree with recolored leaves, the family generation process has failed.

If every sibling looks like a different legendary tree, the family generation process has also failed.

## 12. Depth-planning compatibility

The Master Object must remain suitable for semantic depth planning:

- D1: root / ground-contact semantics clearly discoverable
- D3: trunk / primary occluder structure visually readable
- D4: canopy / high foliage visually coherent

This does NOT mean the generator should draw three artificial horizontal bands. It means the natural structure should make later mask authoring practical.

Engineering readability is secondary to correct family role. A visibly wrong landmark tree does not become acceptable merely because its masks would be easy to draw.

## 13. Reference-use policy

For generation of new standard trees:

### Allowed

- this Style DNA text
- broad FS map screenshots for world / scale context
- palette swatches derived from FS assets
- abstract pixel-art quality constraints

### Discouraged for the first originality benchmark

- supplying a single legacy standard tree as the dominant image-conditioning reference
- asking to match the exact canopy structure or trunk proportions of one reference

### Prohibited generation intent

- redraw
- trace
- near-copy
- silhouette recreation
- branch-layout recreation
- root-layout recreation

## 14. Benchmark success definition

A generated tree passes the Style DNA benchmark only when:

1. It visually belongs in Forest Symphony.
2. It is recognizably a `standard_broadleaf` family member.
3. It is clearly a NEW individual rather than a near-copy of a legacy tree.
4. It is repeatable / production-friendly rather than a showcase illustration.
5. It has low-to-moderate visual salience and does not imply special gameplay significance.
6. Trunk, roots, and canopy remain readable enough for D1/D3/D4 planning.
7. It can plausibly produce multiple sibling variants without silhouette cloning.
8. Its roots, trunk twisting, foliage ornamentation, and base detail remain restrained enough for ordinary forest repetition.

## 15. Failure learned from Generation v1

The first Style-DNA-only candidate was visually rejected because it drifted too far from the standard production role:

- trunk became highly twisted / decorative
- exposed roots became too large and theatrical
- foliage / trunk relationship felt like a special fantasy tree
- base vegetation and trunk greenery increased story / landmark salience
- overall asset read as a unique tree rather than normal reusable map vocabulary

This is classified as:

`FAIL_FAMILY_ROLE_MISMATCH / FAIL_EXCESSIVE_VISUAL_SALIENCE`

The correction is NOT to copy legacy geometry more closely. The correction is to tighten the standard-production role constraints.

## 16. Current generation strategy

For the next benchmark:

1. Do **not** use a legacy tree sprite as the primary conditioning image.
2. Generate from Style DNA + Standard Production Constraints.
3. Favor ordinary, restrained, reusable anatomy over expressive originality.
4. If world context is needed, use a full-map FS screenshot at low influence rather than a single-tree reference.
5. After an original candidate exists, compare against legacy FS references as an acceptance step rather than using them as the answer key during generation.
