# A12 motion quality analyzer. Independent authored QA, not generated from an upstream source file.
from pathlib import Path
from PIL import Image
import numpy as np, json, hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
dest=root/"A12_ANIMATION_RESEARCH"
cases={"T1_forest_scout":"human_sword","T2_moss_antler":"quadruped_charge"}
runs={}
for case,kind in cases.items():
  for phase,base in [("A10",root/"A10_ONE_MASTER_RIG"/case/"rig"/"frames"),("A11",root/"A11_LAYERED_RIG"/case/"frames")]:
    pngs=sorted(base.glob("attack_*.png"))
    assert len(pngs)==8,(case,phase,len(pngs))
    imgs=[np.asarray(Image.open(x).convert("RGBA"),dtype=np.int16) for x in pngs]
    H,W=imgs[0].shape[:2]
    assert all(a.shape==(H,W,4) for a in imgs)
    alpha=[a[:,:,3]>127 for a in imgs]
    frames=[]
    for i,(arr,mask) in enumerate(zip(imgs,alpha)):
      ys,xs=np.nonzero(mask)
      assert len(xs)>0
      bbox=[int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1]
      hits=sum([int(mask[0,:].sum()),int(mask[-1,:].sum()),int(mask[:,0].sum()),int(mask[:,-1].sum())])
      rgb=arr[:,:,:3][mask].astype(np.uint8)
      colors={tuple(c) for c in rgb.tolist()}
      frames.append({"frame":i,"opaque_pixels":int(mask.sum()),"bbox":bbox,
        "centroid":[round(float(xs.mean()),3),round(float(ys.mean()),3)],
        "border_touches":hits,"colors":len(colors),
        "rgba_sha256":hashlib.sha256(arr.astype(np.uint8).tobytes()).hexdigest()})
    rgba_changes=[int(np.any(imgs[0]!=a,axis=2).sum()) for a in imgs]
    alpha_changes=[int((alpha[0]^m).sum()) for m in alpha]
    temporal_changes=[int(np.any(imgs[i]!=imgs[i+1],axis=2).sum()) for i in range(7)]
    row={
      "case":case,"sequence":phase,"intended_kind":kind,
      "frame_size":[W,H],"frames":frames,"distinct_frame_count":len({f["rgba_sha256"] for f in frames}),
      "total_source_changed_pixels_vs_t0":sum(rgba_changes),
      "mean_RGBA_changed_pixels_vs_t0":round(sum(rgba_changes)/8,3),
      "mean_alpha_changed_pixels_vs_t0":round(sum(alpha_changes)/8,3),
      "max_centroid_shift_px":round(max(((f["centroid"][0]-frames[0]["centroid"][0])**2+(f["centroid"][1]-frames[0]["centroid"][1])**2)**0.5 for f in frames),3),
      "swing_width_span_px":max(f["bbox"][2]-f["bbox"][0] for f in frames)-min(f["bbox"][2]-f["bbox"][0] for f in frames),
      "min_changed_pixels_between_adjacent_frames":min(temporal_changes),
      "total_border_touches":sum(f["border_touches"] for f in frames),
      "numeric_source_valid":all(f["border_touches"]==0 for f in frames),
      "semantic_attack_is_recognizable":"REQUIRES_HUMAN_REVIEW",
      "semantic_foot_contact_timing":"REQUIRES_PART_LABELED_RIG",
      "semantic_held_weapon_contact":"REQUIRES_HAND_AND_WEAPON_MASK",
      "semantic_overlap_refill":"REQUIRES_VISIBLE_PART_MASKS"
    }
    runs[phase+"_"+case]=row
comparisons={}
for case in cases:
 a=runs["A10_"+case];b=runs["A11_"+case]
 comparisons[case]={"A10_avg_changed":a["mean_RGBA_changed_pixels_vs_t0"],
  "A11_avg_changed":b["mean_RGBA_changed_pixels_vs_t0"],
  "change_delta":round(b["mean_RGBA_changed_pixels_vs_t0"]-a["mean_RGBA_changed_pixels_vs_t0"],3),
  "A10_unique_frames":a["distinct_frame_count"],"A11_unique_frames":b["distinct_frame_count"],
  "A10_max_centroid_shift":a["max_centroid_shift_px"],"A11_max_centroid_shift":b["max_centroid_shift_px"],
  "A10_border_touches":a["total_border_touches"],"A11_border_touches":b["total_border_touches"],
  "visual_upgrade_proven":False,
  "notes":"Pixel movement is not a semantic measure of believable attack."}
assert all(v["numeric_source_valid"] for v in runs.values())
report={
 "purpose":"Compare A10 whole-body warp vs A11 selectively layered attack and distinguish numeric movement from anatomy",
 "source_lineage":"Existing private A10/A11 PNG; no files from FS SEALED modified",
 "runs":runs,"comparisons":comparisons,
 "acceptance_rules":{"automatic_gates":["all images readable","nonzero alpha","no edge clip","all expected frames exist","at least two distinct frames"],
 "human_gates":["readable anticipation","hand grips unsheathed weapon","clear contact pose with weight","impact hold and follow through","unambiguous recovery","quadruped four-paw timing"],
 "no_false_pass":"Never infer human art PASS from large frame diffs, silhouette IoU, palette fidelity, or GPU pixel equality."}}
(dest/"A12_MOTION_DIAGNOSTIC.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"comparisons":comparisons,"cases":len(runs),"semantic":"PENDING"},ensure_ascii=False,indent=2))