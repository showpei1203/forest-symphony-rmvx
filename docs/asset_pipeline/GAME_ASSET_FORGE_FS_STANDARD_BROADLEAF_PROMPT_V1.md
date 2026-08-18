# Game Asset Forge Prompt — FS Standard Broadleaf v1

Use this prompt for the next originality benchmark.

Important: this prompt is intentionally text-driven. Do not attach a single legacy tree sprite as the dominant shape reference for the first pass.

## Prompt

```text
Create one NEW original pixel-art Master Object for Forest Symphony.

Asset family: standard broadleaf forest tree.
Role: normal reusable production tree for forest maps.

This tree must feel native to the Forest Symphony world, but it must be a new individual design rather than a redraw or near-copy of any existing tree.

STYLE DNA

Overall silhouette:
- medium-sized broadleaf forest tree
- compact, readable outline
- rounded / irregular oval / mildly teardrop canopy tendency
- moderate asymmetry
- moderate width, not a giant spreading landmark tree
- one cohesive canopy mass with organic edge breakup
- trunk must remain visually discoverable

Foliage:
- chunky pixel-cluster foliage
- organize the crown into approximately 3–5 major foliage masses at the macro level
- use secondary breakup inside those masses without turning into tiny-leaf noise
- dark interior pockets for depth
- restrained highlight clusters
- avoid evenly scattered sparkling leaf highlights
- avoid repetitive identical round puff clusters

Trunk and branches:
- sturdy central or near-central trunk
- medium thickness with natural taper
- modest organic irregularity, not an exaggerated fantasy twist
- a small number of readable primary branches, roughly 3–5 main structural directions
- some branches may disappear into foliage, but the trunk/branch logic should still be understandable
- bark should use crisp pixel clusters in warm brown, tan, muted beige and darker groove tones

Root and base:
- modest natural root flare
- short visible roots with slightly irregular spread
- clear ground-contact point beneath the trunk
- small integrated grass / moss / low plants are allowed, but keep them minimal
- do not create sprawling fantasy roots or a decorative mini-scene at the base

Palette and lighting:
- natural forest greens
- dark forest-green interior shadow
- mid-green primary foliage mass
- restrained yellow-green highlights
- natural saturation, no neon green
- simple upper-left or upper-side lighting bias
- broad light / mid / shadow grouping
- no bloom, no glow, no cinematic rim light

Pixel-art language:
- crisp pixel edges
- clean discrete clusters
- limited cohesive palette
- no blur
- no painterly softness
- no photographic detail
- no high-resolution painted illustration disguised as pixel art
- suitable for RPG Maker VX map readability

Production requirements:
- single isolated tree only
- transparent background
- full tree visible
- no sky
- no scene background
- no tile background
- no characters
- no text
- no UI
- no extra props outside the integrated root/base treatment

Originality requirements:
- invent a new canopy outline
- invent a new left/right foliage balance
- invent a new trunk gesture
- invent a new primary branch layout
- invent a new root arrangement
- do not recreate the silhouette or structure of any specific existing Forest Symphony tree

Engineering requirements:
The natural structure must remain easy to interpret later for semantic depth planning:
- D1 = root / ground-contact region should be visually clear
- D3 = trunk / primary occluder structure should be visually readable
- D4 = canopy / high foliage should be visually coherent

Do NOT artificially divide the tree into horizontal layers. Keep it as one natural complete Master Object.

Final target:
A clean, original, reusable Forest Symphony standard broadleaf tree that looks like it belongs to the same game world as the existing assets, while clearly being a new tree design suitable for future sibling variants and the Master Object -> Depth -> Render Policy pipeline.
```

## Negative / avoid block

```text
Avoid:
ancient sacred tree, giant landmark tree, conifer silhouette, dead tree, glowing fantasy tree, perfect topiary sphere, triangular crown, giant horizontal branch spread, extreme trunk lean, dramatic S-curve trunk, sprawling tentacle roots, excessive micro-leaf noise, starburst highlight noise, repeated identical puff-ball foliage, painterly blur, soft airbrush shading, neon palette, cinematic glow, background scenery, multiple trees, characters, text, UI, rocks or unrelated props.
```

## Reference policy for this run

Recommended first pass:
- NO single legacy tree sprite as direct conditioning image.
- If world context is needed, use a full-map FS screenshot only as low-priority environmental context.
- If palette control is available, prefer a palette swatch over a full legacy sprite.

After generation, compare the candidate against legacy FS references manually. The reference images are for acceptance, not for copying geometry.

## Acceptance questions

1. Does it look like it belongs in Forest Symphony?
2. Is it clearly a normal standard broadleaf tree rather than a landmark tree?
3. Is its silhouette materially different from the existing source trees?
4. Can the same family generate several distinct sibling trees?
5. Are root, trunk, and canopy structures readable for D1/D3/D4 authoring?
6. Does it remain readable at actual RMVX map scale?
