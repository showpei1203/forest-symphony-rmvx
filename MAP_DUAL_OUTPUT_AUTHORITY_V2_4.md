# Shared Map Layered Generation Authority v2.4

Effective: 2026-08-19
Scope: Forest Symphony / PMD AutoChess Proto / CG Pet Battle Prototype

This document extends v2.3 and is mandatory for AI-generated layered maps/parallax environments intended for runtime authoring.

## Core update
Ground-first alone is not sufficient. After Ground geometry is accepted, every major PAR structure must bind to an explicit Placement Anchor Contract before PAR generation.

## Placement Anchor Contract
For each major house/building/bridge/landmark/market/treehouse/central structure, record a unique ID and target Ground footprint/region plus required path/water/entry relationship. Similar Ground plots require unique IDs; objects may not silently swap plots.

A house merely being in the correct quadrant is not acceptable. It must materially occupy its assigned plot and connect to its intended local path where the layout implies one. Bridges must span their declared crossing. Fountain/shrine stone structures must register around their declared Ground water/pad anchor.

## PAR generation
Generate `COMPLETE PAR` only after Ground + anchor contract are accepted. Use both as constraints. If a one-pass full-scene PAR generation cannot maintain all anchors, prefer regional/object-group generation tied to locked anchor regions and assemble on the unchanged Ground canvas.

## Placement QA
Composite Ground + PAR and inspect every declared anchor. Any major structure on the wrong plot/path/crossing is FAIL regardless of whole-image attractiveness.

## PAR purity / alpha integrity
PAR may contain only PAR-owned visible structures/objects. Do not include broad semi-transparent Ground copies such as grass, road, flower, riverbank base or water merely to hide mismatch. Normal pixel-art structural alpha should normally prefer 0/255; broad partial-alpha haze, feather halos, AA blur and sub-pixel drift are DRAFT/FAIL evidence unless explicitly approved as a real effect.

## Required workflow
`Shared Authority -> FS Precheck -> Ground only -> Ground geometry QA -> Placement Anchor Contract / unique plot IDs -> PAR from accepted Ground + anchors -> per-anchor placement QA -> PAR purity + pixel-crisp QA -> recomposition/witness QA -> Runtime approval`.