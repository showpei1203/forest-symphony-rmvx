A44-F01: Godot runtime-created CollisionShape2D was unnamed. Functional HP/duplicate/cancel/speed tests passed but QA get_node assertion failed. Set shape_node.name explicitly; rerun native QA.
A44-F02: identified a re-entrancy ghost-damage risk: attack_hit.emit before attack_contact_anchor.emit could deliver blade contact after an attack_hit listener switched state. Guard active motion and attack serial; native QA now tests cancel inside callback.
A44-F03: First foot-placement redraw produced an excessively wide stance (F6 feet x22..49). Visual inspection caught unnatural split silhouette; retargeted to x25..46 and reran 12-frame art/GPU QA. ART HOLD until human approval.
A44-F04: A43 legacy manifest layering metadata pointed to A42 atlases while runtime loaded A43. A44 repaired layering metadata to exact 3 A44 atlas resources and a44_attack_anchors.json.
A44-F05: Initial art generator assumed one private Drive directory; replaced with project-local Path(__file__).resolve().parents[1], cold-extract reproducibility SHA PASS.
A44-F06: Older standalone contact anchor was fixed at (28,11) while actual F6 blade tip local (29,9). A44 now uses 12-frame position keys on same AnimationPlayer and covers world coordinate conversion in native test.
A44-F07: New demo main scene F5 launch was not initially the default from A42; updated project.godot to A44 contact scene and verified Godot headless main-scene smoke exit 0.
Status: engine/GPU/contact DEMO PASS; ART human approval HOLD; formal FS port ATB integration NOT_RUN.
