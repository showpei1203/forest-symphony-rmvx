# FS T-A R24 | Real Bone2D slash motion contract | 2026-11-24

CURRENT STATUS: M1 FULL SKELETON MECHANICAL CANDIDATE PASS / M2 ORIGINAL GODOT 4.7.2 GPU PASS / M3 INVALID REST FIXED / M4 SECOND FULL SLASH PASS. A62 BODY ART and source underpaint HOLD. Full migrated FS Battle NOT_RUN.

## User instruction conflict, resolved on authority
- Latest owner feedback: attack amplitude too small, looks like holding an object rather than SLASHING; owner authorized continuing prior assistant's proposed BIG WEAPON SWING. For this NEW isolated R24 profile, ARMED SLASH overrides older R16-R23 UNARMED prototype assumption. Do NOT silently replace pre-existing default combat type in main or overwrite legacy unarmed results. One independent weapon-equipped slash mode is staged. Existing RPGVX Tankentai split weapon layer is respected.
- R23 seven layer ORA are VISIBLE-PARTITION masks from flattened A52 Body, NOT original poseable LPC costume layers. Those cannot be independently rotated without underpaint. No new body pixels or fake rotating flat belly.

## Actual construction and sources
- Godot 4.7.2 compatible isolated project contains actual Skeleton2D with EIGHT registered Bone2D: pelvis root, chest twist, near upper-arm shoulder, near forearm elbow, near wrist grip, far guard upper arm, lead and rear leg.
- Real AnimationPlayer drives pelvis/chest, upper arm, forearm, wrist and far guard Bone2D rotations at TWELVE source animation times 0.0..0.98 sec. Analytic two-bone IK aims original game-space hand target. A52 original 7x21 sword crop from independent Weapon frame1 is a Sprite2D child of Wrist Grip Bone. Sword frame crop [38,24,45,45]; pivot crop-local [3,19]. Source 256x192 weapon SHA 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b. Approved A62 full-body F0 SHA 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e remains byte-identical and STATIC in the preview.
- Overhead swing uses high guard, drive and followthrough 278 degrees; diagonal swing 250 degrees. F4-to-F7 sword tip movement 55.14 / 55.62 pixels; impact-to-F9 followthrough 35.65 / 28.34 pixels. The artifact canvas is 128px to avoid cutting off the independently extended weapon; source character is still 64px. No forced 64px weapon cropping.
- F7 mechanical contact via signal EXACT 0.630s; animation actually pauses approx 70ms with Hitstop started/resumed. Both animation families were played through with real AnimationPlayer and actual moving sword tests, not manually reordering source sprite frames.

## M2/M3/M4, independent native evidence
- Actual official Godot 4.7.2.stable.official.ed1daf0bf in isolated Linux Xvfb / Mesa llvmpipe OpenGL. 24 native PNG 128x128 screenshots from two 12-key motions. 128 recorded assertions PASS, two real AnimationPlayer timelines complete, each single F7 event and hitstop signals. Actual first run fixed registration of partial/rest-zero Bone2D hierarchy (det==0 and no Bone2D children warnings); construct complete detached bone hierarchy and explicit rest transform before adding to SceneTree. Final run no Godot script/matrix errors. Mesa cannot change VSync; sound dummy to avoid sandbox ALSA.
- Byte-verified source rehydration from original PRIVATE A52 ZIP. Reconstructed A52 7x21 sword crop from actual atlas and A62 F0 true source. Deliberately mutate one sword pixel and one A62 body pixel in disposable copy; SHA validator rejects both. No original source mutation.
- M4 second variant DIAGONAL uses same Bone2D chain but distinct key targets, 12 actual native captures and full playback. This is repeatability of ENGINE/IK, not ART production repeatability.

## Critical HOLD and forbidden claims
- The static full-body A62 image is an identity reference and NOT rig-skinned. Debug arm bone lines and moving original sword are MECHANICAL visualization only. It may still look like a sword detached from character's static arm; no artist acceptance, no independently painted hidden sleeve or torso / hand connection. Do not confuse Bone2D motion with true finished paper doll animation.
- No complete original source-native 45degree LPC hidden outfit layer/underpaint. No real animated source body/torso, no approved 1x art, no slash FX art. Do not submit or merge into main. Main FS Battle ACT/ATB/HP integration NOT_RUN. No paid PixelLab work, Codex, Desktop Remote or owner Windows files touched. Godot 4.7.2 only.

## Actual private evidence, source, handoff
- Owner PRIVATE R24 19-item folder: https://drive.google.com/drive/folders/1gvojm4M5eBZOIvskmGJH3FW1SuxKhqYK
- Complete 52-entry Godot isolated runnable source+private A62/A52 art+actual 24 GPU captured PNG pack: https://drive.google.com/file/d/1hy43QLVCDOnf9tsxsrx6xHLMqOl0Lwcm/view ; 144235 bytes SHA256 c206d7ff6dc63f6ad1124247c0e699a839b8189e1ec8389846436970e5c7cdb7 CRC PASS raw Drive readback.
- Actual overhead GIF: https://drive.google.com/file/d/1hPWse6uvw_fvwmmnGVIiCO5EPvIs_cAd/view
- Actual diagonal GIF: https://drive.google.com/file/d/10syXS2BZEGlCyDcI-oXjlYawkslvmX5h/view
- Actual native two-profile F3/F5/F7/F9 compare: https://drive.google.com/file/d/1k3JUU5STDrqqwsrNqfNpqajsXWFFwuK2/view
- Native QA JSON: https://drive.google.com/file/d/1FQEUCZ7t-1Pn1OjMQeh68yLDmbzKprPA/view
- GitHub has source-only scripts, static source/QA manifest, Handoff, Failure Log and CI; original private source images and native screenshot pixels only in private Drive.

## Next complete macro unit
- Use THIS functional R24 articulated skeleton and real source sword as animation infrastructure. Author authentic A62-matching independent body/near/far sleeve/hand/torso underpaint and bind actual source skinning to these Bone2D, or use properly authorized PixelLab/Skeleton source job. Make high guard/real torso torque/contact/followthrough at 1x owner ART Gate, then extend true twelve frames and integrate this F7 signal into actual FS Godot Battle/ATB/damage. No more source-reordering or polygon-made bellies.
