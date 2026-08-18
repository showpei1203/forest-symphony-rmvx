# Game Asset Forge Prompt — FS Standard Broadleaf v2

Purpose: regenerate `FS_Tree_Standard_Broadleaf_01` after the v1 candidate failed because it became too fantasy / landmark-like.

This version prioritizes **ordinary production-tree role** over expressive originality.

Do not attach a single legacy tree sprite as the dominant shape reference for the first pass.

## Main Prompt

```text
Create one NEW original pixel-art Master Object for Forest Symphony.

ASSET ROLE

Asset family: standard broadleaf forest tree.
This must be a NORMAL reusable background/environment tree for ordinary forest maps.
It is not a landmark, sacred tree, hero tree, quest tree, ancient tree, magical tree, boss-area tree, or decorative showcase tree.

The most important requirement is ROLE DISCIPLINE:
This tree should look visually ordinary enough that several related trees could appear repeatedly across one forest map without drawing special attention.

Originality must come from subtle natural variation, NOT from fantasy exaggeration, dramatic anatomy, giant roots, twisted bark, unusual ornaments, or cinematic silhouette design.

VISUAL SALIENCE

Target low-to-moderate visual salience.
The canopy should be the dominant visual mass.
The trunk should be readable but should NOT become the visual centerpiece.
The roots should clearly ground the object but should NOT become a major design feature.
The base should be simple and quiet.

If the result looks like a tree that deserves a unique name, a quest marker, a shrine, or a story event, the design is too special.

OVERALL FORM

- medium-sized standard broadleaf tree
- compact RPG map-object proportions
- ordinary believable broadleaf anatomy
- rounded / irregular oval canopy
- mild natural asymmetry only
- moderate width
- no huge horizontal spread
- no dramatic lean
- no iconic or emblem-like silhouette
- one cohesive canopy body rather than many separate decorative crowns

CANOPY

- dense standard broadleaf foliage
- use broad, chunky pixel foliage groups
- approximately 3–5 macro foliage masses that visually merge into one crown
- secondary texture inside the crown should remain simple
- lower foliage may partially hide branches
- dark inner foliage pockets for depth
- moderate highlights grouped into broad areas
- natural unevenness, but no theatrical composition
- avoid many isolated circular puff-balls
- avoid starburst leaf effects
- avoid excessive micro-leaf detail
- avoid giant separated crown lobes

The crown should look useful for repeated map placement, not designed as a standalone illustration.

TRUNK

- central or near-central trunk
- medium thickness
- mostly upright
- gentle natural irregularity only
- simple readable taper
- avoid strong S-curves
- avoid braided / spiraling / twisting trunk designs
- avoid strongly crossing trunk sections
- avoid exposed trunk patterns that become ornamental
- bark detail should remain secondary to the whole tree

BRANCHES

- only a few clear structural branches
- roughly 3–5 main branch directions
- simple natural forks
- most branch complexity may disappear into foliage
- branches should support the crown, not form a dramatic silhouette
- no symmetrical decorative forks
- no huge sweeping limbs
- no tangled branch network

ROOTS / BASE

- small natural root flare
- short exposed roots only
- root spread should stay close to the trunk base
- roots should NOT dominate the lower part of the sprite
- no giant root arms
- no tentacle roots
- no braided or crossing root composition
- no ancient-tree buttress roots
- no roots extending dramatically sideways

Use very little base decoration.
At most, add a few small simple grass or moss clusters close to the trunk contact point.
Do not add vines, bright leaves climbing the trunk, flowers, rocks, mushrooms, decorative foliage arrangements, or story-like environmental details.

PIXEL STYLE

- clean RPG pixel art
- crisp pixel clusters
- limited cohesive palette
- readable at RPG Maker VX map scale
- no blur
- no painterly softness
- no photographic texture
- no smooth high-resolution digital painting disguised as pixel art
- restrained anti-aliasing

PALETTE

Foliage:
- deep forest-green interior shadows
- natural mid greens as the majority
- restrained yellow-green highlights
- no neon green
- no glowing foliage

Bark:
- natural warm brown / muted tan
- modest beige highlights
- dark grooves
- restrained contrast
- no glowing orange wood
- no polished fantasy wood appearance

LIGHTING

- simple environmental light
- mild upper-left / upper-side bias
- broad light / mid / dark grouping
- no rim light
- no bloom
- no magical glow
- no cinematic spotlight

MASTER OBJECT OUTPUT

- one complete tree only
- isolated transparent background
- full tree visible
- centered with reasonable transparent margin
- no ground tile
- no full scene
- no sky
- no other trees
- no character
- no text
- no UI
- no unrelated props

ORIGINALITY

Create a new individual tree, but keep originality subtle.
Do not copy the exact silhouette, trunk, branches, canopy geometry, or roots of an existing Forest Symphony tree.
However, do NOT compensate for originality by making the tree dramatic or exotic.

Think:
"another normal tree from the same forest"
NOT:
"a special new fantasy tree design"

ENGINEERING READABILITY

The tree should naturally support later semantic depth authoring:
- D1 root / ground contact can be identified clearly
- D3 trunk / main occluding structure can be identified clearly
- D4 canopy / high foliage is coherent

Do not draw artificial horizontal depth bands.
Do not sacrifice the normal-tree role merely to make masks easier.

FINAL TARGET

A clean, restrained, production-friendly Forest Symphony standard broadleaf tree.
It should look believable as one of many ordinary trees used repeatedly across an RPG forest map.
It should visually belong to the game without resembling a copied legacy tree and without looking important, magical, ancient, heroic, or unique.
```

## Strong Negative Block

```text
DO NOT generate:
ancient tree,
sacred tree,
legendary tree,
hero tree,
quest tree,
magic tree,
fantasy centerpiece,
landmark tree,
giant tree,
gnarled ancient trunk,
strongly twisted trunk,
spiral trunk,
braided trunk,
dramatic S-curve trunk,
giants roots,
sprawling roots,
tentacle roots,
buttress roots,
crossed decorative roots,
large exposed root network,
vines climbing trunk,
bright leaves attached to trunk,
flowers,
mushrooms,
rocks,
ornamental base,
multiple separated tree crowns,
starburst foliage,
excessive leaf detail,
neon green,
glow,
bloom,
rim lighting,
cinematic lighting,
painterly rendering,
soft blur,
background scene,
multiple trees,
characters,
text,
UI.
```

## Reference Policy

For this v2 benchmark:

- Do NOT provide `tree variation.png` as a direct shape-conditioning image.
- Do NOT provide a cropped individual tree from `Trees1.png` as direct shape conditioning.
- If Game Asset Forge needs visual context, use a broad real FS forest-map screenshot only, at low influence, to communicate map-scale and world context.
- Palette swatches are preferred over legacy individual-tree images.
- Legacy tree sprites are used AFTER generation for acceptance comparison.

## Visual Acceptance Gate

Immediate FAIL if any of the following is true:

- reads as ancient / sacred / fantasy / quest tree
- trunk is the dominant decorative feature
- roots dominate the lower silhouette
- trunk visibly twists / braids / spirals as a design motif
- base contains decorative storytelling details
- tree looks intentionally iconic or unique
- repeated copies would make a forest visually exhausting

PASS candidate should instead read as:

> "a good normal forest tree that happens to belong in Forest Symphony."
