from pathlib import Path
from PIL import Image
import base64,hashlib,json,numpy as np,zlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE")
actions={"T1_hero":["idle","walk","run","attack","hurt","jump"],
         "T2_monster":["idle","walk","attack","hurt","faint"]}
all_q=[]
for case, names in actions.items():
  base=root/case/"r2"
  frames=base/"frames";frames.mkdir(parents=True,exist_ok=True)
  manifest={"schema":"generate2dsprite.animation_clips.v2","frames":[],
            "anchor_px":[24,61] if case=="T1_hero" else [24,45],
            "clips":{},"states":{},"sampling":"nearest","pixel_art":True,
            "art_source":"existing","placeholder":False}
  for action in names:
    pack=json.loads((root/f"transfer_r2_{case}_{action}.json").read_text(encoding="utf-8"))
    w,h=pack["w"],pack["h"]
    assert pack["case"]==case and pack["action"]==action and pack["palette_colors"]==32
    raw=zlib.decompress(base64.b64decode(pack["payload_zlib_b64"]))
    pal=np.frombuffer(raw[:96],dtype=np.uint8).reshape(32,3)
    n=4*w*h
    inds=np.frombuffer(raw[96:96+n],dtype=np.uint8).reshape(4,h,w)
    alpha=np.frombuffer(raw[96+n:],dtype=np.uint8).reshape(4,h,w)
    assert len(raw)==96+n*2 and inds.max()<32
    ids=[]
    for i in range(4):
      rgba=np.concatenate([pal[inds[i]],alpha[i,:,:,None]],axis=2).astype(np.uint8)
      img=Image.fromarray(rgba,"RGBA")
      assert hashlib.sha256(img.tobytes()).hexdigest()==pack["rgba_frame_pixel_sha256"][i],(case,action,i)
      fn=f"{action}_{i:02d}.png"
      img.save(frames/fn)
      assert img.getbbox() is not None
      assert img.getchannel("A").getextrema()==(0,255),case
      ids.append(len(manifest["frames"]))
      manifest["frames"].append({"name":f"{action}-{i}","file":"frames/"+fn})
    isloop=action in ("idle","walk","run")
    manifest["clips"][action]={"frames":ids,"ticks":[10,10,10,10] if isloop else [9,9,9,9],
                               "loop_policy":"cycle" if isloop else "oneshot",
                               "role":"player" if case=="T1_hero" else "enemy"}
    all_q.append({"case":case,"action":action,"count":len(ids),"pixel_sha_match":True})
  manifest["states"]={"idle":"idle","moving":"walk","attacking":"attack"}
  (base/"clips.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
(root/"r2_decode_QA.json").write_text(json.dumps(all_q,indent=2),encoding="utf-8")
print(json.dumps({"decoded":len(all_q),"total_frames":len(all_q)*4,"all_pixel_hashes_verified":True,"cases":actions},indent=2))