#!/usr/bin/env python3
"""R17 fail-closed image canvas/alpha gate; does not approve image art or provenance."""
import argparse,hashlib,json,sys
from pathlib import Path
from PIL import Image
import numpy as np

SIZES={(544,416),(1280,928)}
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def verify(gpath,ppath,manifest=None):
 g=Image.open(gpath);p=Image.open(ppath)
 ga=np.asarray(g.convert("RGBA"))[:,:,3]; pa=np.asarray(p.convert("RGBA"))[:,:,3]
 positive=pa>0; border={"top":int((pa[0,:]>0).sum()),"bottom":int((pa[-1,:]>0).sum()),"left":int((pa[:,0]>0).sum()),"right":int((pa[:,-1]>0).sum())}
 checks={"PNG":g.format=="PNG" and p.format=="PNG",
  "Ground_opaque":g.mode in ("RGB","RGBA") and bool((ga==255).all()),
  "PAR_real_RGBA":p.mode=="RGBA" and bool((pa==0).any()) and bool(positive.any()),
  "same_canvas":g.size==p.size,
  "approved_native_canvas":g.size==p.size and g.size in SIZES,
  "32_grid":all(d%32==0 for d in (*g.size,*p.size)),
  "PAR_clean_borders":all(v==0 for v in border.values()),
  "PAR_solid_interior":int((pa==255).sum())/max(1,int(positive.sum()))>=.6}
 lineage="UNVERIFIED_NO_MANIFEST"
 if manifest:
  m=json.loads(Path(manifest).read_text(encoding="utf8"))
  a=m.get("ground",{});b=m.get("par",{})
  agree=(m.get("source_mode")=="independent_direct_layers" and a.get("sha256")==sha(gpath) and b.get("sha256")==sha(ppath) and a.get("scene_blueprint_id")==b.get("scene_blueprint_id") and a.get("world_origin_xy")==b.get("world_origin_xy")==[0,0])
  checks["manifest_consistent"]=agree
  lineage="DECLARED_ONLY_NOT_AUTHENTICATED" if agree else "FAIL"
 status="TECH_CANDIDATE_ONLY_ART_HOLD" if all(checks.values()) else "FAIL_CLOSED_TECH"
 return {"status":status,"checks":checks,"ground":{"size":list(g.size),"sha256":sha(gpath)},"par":{"size":list(p.size),"sha256":sha(ppath),"alpha0":int((pa==0).sum()),"alpha255":int((pa==255).sum()),"alpha_nonzero":int(positive.sum()),"alpha_edges":border},"source_provenance":lineage,"human_art":"NOT_CHECKED_BY_SCRIPT","formal_seal":"NO"}
if __name__=="__main__":
 ap=argparse.ArgumentParser();ap.add_argument("--ground",required=True);ap.add_argument("--par",required=True);ap.add_argument("--manifest");ap.add_argument("--report")
 a=ap.parse_args()
 try:r=verify(a.ground,a.par,a.manifest)
 except Exception as e:print("FAIL_CLOSED:",repr(e));sys.exit(2)
 if a.report:Path(a.report).write_text(json.dumps(r,indent=2,ensure_ascii=False),encoding="utf8")
 print(json.dumps(r,ensure_ascii=False));sys.exit(0 if r["status"]=="TECH_CANDIDATE_ONLY_ART_HOLD" else 2)
