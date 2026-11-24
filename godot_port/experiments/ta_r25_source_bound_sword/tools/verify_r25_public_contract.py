#!/usr/bin/env python3
"""R25 PUBLIC/CI metadata gate ONLY; original sprite pixels + native render evidence remain PRIVATE Drive."""
from pathlib import Path
import argparse,json
def main():
    a=argparse.ArgumentParser()
    a.add_argument("qa",type=Path)
    a.add_argument("source",type=Path)
    q=a.parse_args()
    n=json.loads(q.qa.read_text(encoding="utf-8"))
    s=json.loads(q.source.read_text(encoding="utf-8"))
    assert n["engine"]=="4.7.2.stable.official.ed1daf0bf"
    assert "Xvfb" in n["native_mode"]
    assert n["bone_count"]==8 and n["source_bone_attached_visible_regions"]==9
    assert n["native_profiles"]==2 and n["frames_per_profile"]==12
    assert n["native_png_total"]==32 and n["native_assertions_pass"]>=190
    assert n["original_F0_GPU_source_rgba_diff_px"]==0
    assert n["delete_real_torso_source_coat_native_diff_px"]==85
    assert n["restored_coat_GPU_mismatch_px"]==0
    assert n["source_only_F3_to_F7_actual_body_change_pixels"]["overhead_arched_slash"]>=600
    assert n["source_only_F3_to_F7_actual_body_change_pixels"]["diagonal_slash"]>=600
    assert n["rig_torso_attached_to_chest"] and n["rig_near_upper_to_shoulder"]
    assert n["rig_near_forearm_to_elbow"] and n["rig_near_hand_to_wrist"]
    assert n["rig_far_arm_to_guard"] and n["original_F0_exact_RGB_source"]
    assert n["contact_seconds"]==0.63 and n["hitstop_spec_seconds"]==0.07
    assert n["first_timing_observation_ms"]==54 and n["retry_timing_observation_ms"]==70
    assert n["initial_manual_pose_skin_visibility_failure"]=="FIXED_AND_RETESTED"
    assert n["actual_new_art_frames"]==0 and n["original_source_rgba_new_pixels"]==0
    assert n["original_LPC_modular_paperdoll_source_verified"] is False
    assert n["full_FSBattle_ATB"]=="NOT_RUN"
    assert "HOLD" in n["visual_art"]
    assert s["approved_A62_sha256"]=="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
    assert s["A52_body_sha256"]=="a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f"
    assert s["source_F0_recombined_exact_rgba"] and s["source_F0_opaque_pixels"]==576
    assert s["donor_source_frames"]==[4,5] and len(s["chips"])==6
    assert s["chips"]["F04_hand"]["visible_pixels"]==1
    assert s["chips"]["F05_hand"]["visible_pixels"]==8
    assert s["new_art_pixels"]==0 and s["art_approved"] is False
    assert s["source_native_LPC_hidden_underpaint"]=="MISSING"
    print("R25_PUBLIC_QA_METADATA_PASS / original real Godot GPU held in PRIVATE Drive / ART_HOLD")
if __name__=="__main__":main()
