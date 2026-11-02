# A62 3D Skeleton Reference Pilot | 2026-11-02

The user asked us to explore 3D motion control instead of expensive incremental pixel animation. The supplied site 3d.internet.dev was unavailable at inspection; this project is an independent Godot 4.7.2 proof of concept, NOT the website's model or technology.

Created and GPU-rendered an actual procedural 3D mannequin rig on the user's RX 6700 XT with fixed orthographic three-quarter camera:
- RED = anatomical character-left limbs, not necessarily screen-left.
- BLUE = anatomical character-right limbs.
- GREEN = head, neck, spine and pelvis.
- Four-phase F0 neutral -> F1 left foot forward/right arm counter-swing -> F0 -> F2 right foot forward/left arm counter-swing.
- Actual GPU screenshots A62_3D_PHASE_0..3.png and four-phase GIF. F0 repeat images are pixel-identical.
- Full code and Godot project included. No PixelLab credits.

LIMITS: purely skeletal geometry, NOT an approved actor, not native VX pixel art, not sufficiently aligned with actual original FS actor01 head proportions, 45-degree viewpoint, silhouette or occlusion. DO NOT send these 3D images directly to paid PixelLab or replace the A62 2D art reference yet. This experiment only demonstrates an independently controllable, fixed-camera 3D action reference.

Next worthwhile test: align 3D camera and character proportions to native FS 32x32 original images, derive PixelLab-compatible 18 projected joints and compare body-part identity / feet/arm positions. Original FS actor and A62 GIF remain visual authorities.