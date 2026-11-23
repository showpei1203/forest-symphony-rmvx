#!/usr/bin/env python3
"""Public GitHub CI receipt checker, NOT a substitute for private original-pixel GPU QA."""
from pathlib import Path
import argparse,json,hashlib

def verify(record:dict):
 assert record['engine']=='4.7.2.stable.official.ed1daf0bf'
 assert record['native_mode']=='isolated Linux Xvfb Mesa llvmpipe OpenGL'
 assert record['actual_Bone2D_chain'] and record['actual_AnimationPlayer']
 assert record['bone_count']>=8 and record['native_screenshots']==24
 assert record['source_A62_full_body_sha256']=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
 assert record['source_sword_atlas_sha256']=='6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b'
 assert len(record['profiles'])==2
 for p in record['profiles']:
  assert p['native_frames']==12 and p['actual_animated_bone_playback']
  assert p['angular_sweep_degrees']>=200
  assert p['tip_windup_to_contact_px']>=40 and p['tip_contact_to_followthrough_px']>=20
  assert p['real_hit_event_once'] and p['event_at_seconds']==0.630
  assert p['hitstop_events_pass']
 assert record['real_70ms_hitstop_elapsed_ms']>=60
 assert record['underpaint']== 'MISSING'
 assert record['body_currently_skeletal_skinned']==False
 assert record['visually_approved']==False
 assert record['full_FS_Battle_ATB_integration']=='NOT_RUN'
 assert record['new_paid_PixelLab_job']=='NOT_RUN'
 return True
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('receipt',type=Path);args=ap.parse_args()
 r=json.loads(args.receipt.read_text(encoding='utf-8'));verify(r)
 print('R24_PUBLIC_METADATA_GATE_PASS; REAL M2 GPU EVIDENCE OWNER PRIVATE DRIVE; ART HOLD')
