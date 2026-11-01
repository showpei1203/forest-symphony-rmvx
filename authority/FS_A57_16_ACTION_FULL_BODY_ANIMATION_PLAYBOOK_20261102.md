# FS 16 ACTION WHOLE-BODY MOTION CHOREOGRAPHY

## 01 Walking Down
**Mode:** gait | **Facing:** south | **Source frame order:** [1, 0, 2] | **Playback:** [0, 1, 0, 2]

**Pose:** Neutral grounded stance / left foot forward with opposite arm swinging / right foot forward with opposite arm swinging.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Keep front-facing gaze; head bobs subtly with vertical compression. Shoulders counter-rotate to pelvis; left shoulder and right hip work as a chain, arms counter-swing, knees and shoes alternate, cloak hems react a beat later.

## 02 Walking to the Left
**Mode:** gait | **Facing:** west | **Source frame order:** [1, 0, 2] | **Playback:** [0, 1, 0, 2]

**Pose:** Side-facing neutral / left-step / right-step from source strip, with proper original west profile.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Maintain west-facing original view; translate the chest and head slight bounce with steps, alternate hips, knees and ankles, use contralateral elbows and hands; cloth trails behind.

## 03 Walking to the Right
**Mode:** gait | **Facing:** east | **Source frame order:** [1, 0, 2] | **Playback:** [0, 1, 0, 2]

**Pose:** Side-facing neutral / one leg leading / opposite leg leading in exact east direction.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Keep east profile, not a changed camera. Head bob, shoulder counter-swing, wrist and elbows rhythmic; pelvis and boots move as one consistent gait; no sliding feet.

## 04 Walking Up
**Mode:** gait | **Facing:** north | **Source frame order:** [1, 0, 2] | **Playback:** [0, 1, 0, 2]

**Pose:** Back-facing neutral / step with one leg / step with opposite leg.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Preserve back-facing hairstyle and coat. Alternate spine vertical motion and hip lean, move both shoulders and elbows with cadence; visible rear boots change depth.

## 05 Waiting
**Mode:** loop | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2, 1]

**Pose:** Relaxed balanced posture / inhalation with chest expansion and subtle shoulder rise / exhalation with weight shifting then relaxed return.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Keep identity and 3/4 combat direction; allow small organic head and torso movement instead of frozen top half. Elbows/hands follow breathing; hips and feet remain planted; cloth/hair barely move.

## 06 Damage
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Contact and recoil / chest and head recoil with arms instinctively guarding / recover into fighting stance.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Impact travels from shoulders through spine and hips; head briefly recoils, elbows draw in, knees bend and support weight. Do not use running steps; maintain 3/4 facing in all three frames.

## 07 Critical Damaged
**Mode:** loop | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2, 1]

**Pose:** Unsteady weak combat stance / deep strained crouch and head drop with collapsed shoulders / weakened recovery to first posture.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Breathing and trembling involves head, shoulder line, spine, wrists, hips, knees, boots; never convert to a running pose or rotate to face the camera.

## 08 Moving to Close Attack
**Mode:** gait | **Facing:** south-east | **Source frame order:** [1, 0, 2] | **Playback:** [0, 1, 0, 2]

**Pose:** F0 neutral foot recovery (ORIGINAL MIDDLE frame) / F1 left-foot running stride (ORIGINAL LEFT frame) / F2 opposite right-foot running stride (ORIGINAL RIGHT frame).

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Full-body 45-degree 3/4 in-place combat run, not a side-on walk. Each step compresses and rebounds the spine and bobbing head, shoulders counter-rotate against pelvis, elbows and hands counter-swing naturally, both knees flex and boots alternate convincingly, cloak and hair lag behind; root remains at the same x/y location because SBS moves the whole sprite in world space. Never lock shoulders or head to an identical sprite across all frames.

## 09 Victory Pose
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Combat stance / celebratory rising motion / confident arm-raised victory pose held.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Whole body participates: chest expands, chin raises, shoulders and elbows lift, hips shift under raised arm, knees remain balanced, outfit reacts; no added weapon or trophy.

## 10 Dodging
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Readying dodge / body shifts sideways, torso ducks with tilted shoulders / fully evades and regains posture.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Use the real reference frame order 0,1,2. Coherent full-body lean through neck-spine-hips; one knee folds while opposite foot braces; arms guard and trail; no turning 90 degrees, and never interpret first frame as taking damage.

## 11 Nothing
**Mode:** empty | **Facing:** south-east | **Source frame order:** [] | **Playback:** []

**Pose:** No animation. Transparent empty output; create no character frame.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Absolutely no figure and no inferred motion.

## 12 Death
**Mode:** hold | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Terminal fallen body, face/hair/torso/limbs settled on ground / hold / hold.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** The three visible original frames are identical when composited; preserve a still final death silhouette and held frame. Do NOT fabricate standing up, rolling, or repeated death oscillation. A separate falling animation would require different source poses.

## 13 Front Jump / Close Attack
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Anticipation crouch and arm set / body springs upward with knee lift and arm drive / landing or impact stance.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Full-body spring from ankles via knees and hip, spine extends, head rises, arms counterbalance then brace; hair/coat have airborne lag. Character stays inside the 32px cell; SBS world jump displacement is separate.

## 14 Ranged Attack I
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Set shoulders and elbow / pull and aim with head tracking attack direction / release gesture and settle.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Head/neck and torso aim consistently 3/4; shoulder/elbow/hand flex visibly, hip anchors balance, knees make small brace adjustment, loose cloth reacts. No actual drawn weapon, arrow, muzzle flash, or VFX; paper doll layers supply them.

## 15 Close / Ranged Attack
**Mode:** once | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2]

**Pose:** Wind up through hips and shoulders / committed attack with arm extension / recoil and re-center posture.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Power flows boots->knees->hips->torso twist->shoulder->elbow->hand, with counterbalance and head tracking. A full-body attack, not upper-arm only; no baked weapon or effects.

## 16 Magi Skill Use
**Mode:** loop | **Facing:** south-east | **Source frame order:** [0, 1, 2] | **Playback:** [0, 1, 2, 1]

**Pose:** Stable chant / hands rise and chest expands with subtle head lift / hands shift to sustain channeling, then recoil gently.

**Head, shoulders, trunk, elbows, hands, hips, knees, feet, secondary motion:** Looped full-body breathing: head and shoulders move subtly, elbows and palms perform casting, small spine and hip rebound, feet maintain balance, robe/coat hems lag behind. Separate VFX sprite, no magic graphics baked into character.