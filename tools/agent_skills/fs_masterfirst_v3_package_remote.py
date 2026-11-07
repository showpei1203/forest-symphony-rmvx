"""FS Master-first V3: exhaustive evidence packaging from real isolated native Game.exe.
No modifications of R5 / A36H or upstream FS files. This archive is private study only.
"""
from pathlib import Path
import json,hashlib,shutil,zipfile
import numpy as np
from PIL import Image,ImageDraw

D=Path('G:/我的雲端硬碟/FS_MASTER_FIRST_V3_NATIVE_20261107')
P=Path(r'E:\FS_AGENT_SKILLS_PILOT_20261106')
N=P/'FS_MASTER_FIRST_V3_NATIVE_R1_20261107'
V=N/'VX_NATIVE_MASTER_FIRST_V3'
Q=json.loads((N/'M3_NATIVE_QA_REPORT.json').read_text('utf8'))
PLAN=json.loads((D/'FS_MASTER_FIRST_V3_PROBE_PLAN_QA.json').read_text('utf8'))
assert Q['native_grid_GATE']=='PASS' and Q['native_canopy_dynamic_GATE']=='PASS'
assert Q['native_grid_checked_tiles']==1160 and Q['native_grid_checked_edges']==4502
assert Q['native_grid_error_count']==0 and Q['completed_all_cases']
assert all(Q['original_test_engine_file_shas_unchanged'].values())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
M=np.asarray(Image.open(D/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png').convert('RGB'))
PAR=np.asarray(Image.open(D/'VX_RUNTIME_4OBJECT_PAR_C2_SOURCE_RGB_UNVERIFIED.png').convert('RGBA'))
assert sha(D/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png')==PLAN['source_master_sha256']
assert np.array_equal(PAR[PAR[:,:,3]>0,:3],M[PAR[:,:,3]>0,:3])
g=np.asarray(Image.open(D/'AUTHORING_GROUND_ONLY_AI_UNDERPAINT_DRAFT.png').convert('RGBA'))
a=np.asarray(Image.open(D/'AUTHORING_COMPLETE_PAR_SOURCE_MASTER_MASK_DRAFT.png').convert('RGBA'))
base=Image.fromarray(g,'RGBA');base.alpha_composite(Image.fromarray(a,'RGBA'))
author_err=int(np.count_nonzero(np.any(np.asarray(base.convert('RGB'))!=M,axis=2)))
assert author_err==0,author_err
keys=['LEFT_HOUSE_ROOF','RIGHT_HOUSE_ROOF','LEFT_TREE_CANOPY','LOWER_RIGHT_TREE_CANOPY']
ms=[np.asarray(Image.open(D/(key+'_ALPHA_GRABCUT_REFINED_DRAFT.png')).convert('L')) for key in keys]
union=np.maximum.reduce(ms)
assert np.array_equal(union,PAR[:,:,3]),'union masks must reproduce runtime partial PAR alpha'
assert int(np.count_nonzero(union))==118425

R=P/'FS_MASTER_FIRST_V3_DELIVERY_20261107'
if R.exists():raise SystemExit('FAIL-CLOSED: R already exists')
R.mkdir(parents=True)
registry=[]
def cp(source,sub):
 target=R/sub;target.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(source,target)
 assert sha(source)==sha(target)
 registry.append({'path':target.relative_to(R).as_posix(),'bytes':target.stat().st_size,'sha256':sha(target)})
for name in ['VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png','VX_RUNTIME_4OBJECT_PAR_C2_SOURCE_RGB_UNVERIFIED.png',
             'AUTHORING_GROUND_ONLY_AI_UNDERPAINT_DRAFT.png','AUTHORING_COMPLETE_PAR_SOURCE_MASTER_MASK_DRAFT.png']:
 cp(D/name,'SOURCE_LAYERED/'+name)
for name in keys:cp(D/(name+'_ALPHA_GRABCUT_REFINED_DRAFT.png'),'SOURCE_MASKS/'+name+'_ALPHA_GRABCUT_REFINED_DRAFT.png')
for name in ['FS_MASTER_FIRST_V3_COLLISION_GRID_29x40.json','FS_MASTER_FIRST_V3_PROBE_PLAN_QA.json']:
 cp(D/name,'QA/'+name)
for name in ['fs_masterfirst_v3_native_engine_R1.py','fs_masterfirst_v3_native_engine.py','build_masterfirst_v3.py']:
 if (D/name).exists():cp(D/name,'REBUILD/'+name)
cp(N/'M3_NATIVE_QA_REPORT.json','QA/M3_NATIVE_QA_REPORT.json')
cp(V/'Data/Map050.rvdata','ISOLATED_VX_PATCH/Data/Map050.rvdata')
cp(V/'Data/Scripts.rvdata','ISOLATED_VX_PATCH/Data/Scripts.rvdata')
for file in sorted(N.glob('M3_*.png')):cp(file,'REAL_VX_GAMEEXE_SCREENSHOTS/'+file.name)
if (D/'V3_CANDIDATE_32PX_ROOF_BLOCKS_AND_CANOPY_EXITS_1X.png').exists():
 cp(D/'V3_CANDIDATE_32PX_ROOF_BLOCKS_AND_CANOPY_EXITS_1X.png','QA/V3_CANDIDATE_32PX_ROOF_BLOCKS_AND_CANOPY_EXITS_1X.png')
# Add explicit actor 203 screenshot positive and negative 2-column 2-case contacts.
montage=Image.new('RGB',(1088,416*3+38*3),(30,31,35));draw=ImageDraw.Draw(montage)
for i,key in enumerate(['LEFT_TREE_EXIT','LOWER_RIGHT_TREE_EXIT','CLEAR_NEGATIVE']):
 o=Image.open(N/(f'M3_{key}_OFF.png')).convert('RGB')
 p=Image.open(N/(f'M3_{key}_ON.png')).convert('RGB')
 montage.paste(o,(0,i*454+38));montage.paste(p,(544,i*454+38))
 change=int(np.count_nonzero(np.any(np.asarray(o)!=np.asarray(p),axis=2)))
 draw.text((6,i*454+12),f'REAL VX Game.exe: {key} | OFF / ON | {change} changed px',fill='white')
mcp=R/'REAL_VX_3_VALID_WALKABLE_CONTROLS_OFF_ON.png';montage.save(mcp)
registry.append({'path':mcp.relative_to(R).as_posix(),'bytes':mcp.stat().st_size,'sha256':sha(mcp)})

h='''# Forest Symphony Master-first V3 | RPG Maker VX native gate handoff | 2026-11-07

## 本次實際成果
這一輪沒有另外生成美術圖，也沒有覆寫舊 A36F/A36G/A36H。將先前凍結的 1280×928 MASTER，同源 4 件 C2 局部遮擋 PAR 真正匯入 VX RGSS2 孤立 Game.exe test clone，並重新編譯獨立 `Data/Map050.rvdata` 原生 tile table。

### 重要碰撞誤判與更正
V2 手繪碰撞草案 333 blocked/827 walkable，誤把 37 個「屋頂」格當可通行。V3 依實際屋頂來源 Alpha/house footprint 排除，變成 370 blocked、790 walkable。此格線**仍只是美術語意草案，尚未通過整張地圖地形可走性人工驗收**。對本次草案，真實 VX 原生 `passable?` 1160/1160 判斷一致；`move_passable?` 4502/4502 界內有向相鄰方向一致，差異 0。這是 Game.exe 真驗證，不是 monkeypatch。

### Game.exe：同一張新 MASTER + source RGB PAR，真正開關 203
- `LEFT_TREE_EXIT`: tile (10,16) -> (10,17)，`move_down` 真移動 PASS；OFF/ON 人物局部差 627px -> 161px，鏡頭同組固定。
- `LOWER_RIGHT_TREE_EXIT`: tile (33,24) -> (32,24)，`move_left` 真移動 PASS；627px -> 8px，鏡頭同組固定。
- `CLEAR_NEGATIVE`: (20,15) -> (20,16) 真移動 PASS；兩個位置 OFF/ON 均 0px。
- 房屋屋頂 tile (6,5) / (27,5) 屬 V3 BLOCKED：真 `Game.exe` 203 畫面可切換（627px），**僅 ENGINE_ONLY，不能當成玩家在可走格的屋簷遮擋**。
- 此遊戲中人物 OFF/ON 直接取實際 544×416 原生視窗截圖，並非 Python 人物模擬或 AI 美術示意。

### 分層與可重跑證據
- SOURCE MASTER: `SOURCE_LAYERED/VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png` (Frozen artwork exact SHA)。
- SOURCE C2 SEMANTIC: four `SOURCE_MASKS` each 1280×928, before art review. No separately AI-redrawn PAR RGB.
- RUNTIME PARTIAL PAR: `SOURCE_LAYERED/VX_RUNTIME_4OBJECT_PAR_C2_SOURCE_RGB_UNVERIFIED.png`，118425 不透明 alpha，完全取自 MASTER 同座標 RGB。
- AUTHORING GROUND: `AUTHORING_GROUND_ONLY_AI_UNDERPAINT_DRAFT.png`，母圖可見地表+被遮物 AI inpaint。
- AUTHORING COMPLETE PAR: `AUTHORING_COMPLETE_PAR_SOURCE_MASTER_MASK_DRAFT.png`，AI broad alpha proposal＋母圖真 RGB。注意不是人物覆蓋層。
- 上述兩種合成方式與 MASTER 皆為 **RGB 0 像素差（建構式）**；只能證明 RGB 同源，不證明 alpha 遮擋語意。
- `ISOLATED_VX_PATCH/Data/Map050.rvdata`，保留真正 V3 改寫後的 tile 表；`Scripts.rvdata` 僅為專用測試腳本，內建來源版本不同請勿直接覆蓋正式工程。
- `REBUILD` 存原版 Python、第二次修正過的 R1 script；第一輪 script 的 `NameError: w` 在 R1 修復並成功重跑，失敗紀錄保留在源路徑與文本檔。完整演算法可以離線重跑。

### 未通過項目（Fail-closed）
- 兩屋屋頂目前全部落在 BLOCKED，**沒有合法玩家可走的屋簷遮擋正面測試點**，此項 PARTIAL/SEMANTICS UNVERIFIED。
- 兩棵樹冠的分割雖通過兩個實機走位樣本，**整棵樹的逐葉自然邊緣、美術觀感與其餘樹群的所有遮擋皆未驗收**。
- 作者層 `Authoring_CompletePAR` 的所有物件 Mask（所有房屋/橋/水/草/亭/石碑等）尚未全數語意檢查；本次成功只涵蓋局部 4 件 Runtime PAR。
- 全圖 collision 的 370 格阻擋，只是草案在引擎內逐格可重現，未獨立驗證每格物件/地形/橋的可通行合理性。
- 整張圖 1280×928 仍為高細節**繪圖風格**，對 FS 原版 Ground3 的 **1× 像素顆粒與32px格完整美術風格** 尚未獲得 User Art PASS。
- 正式遊戲事件、全圖 Godot 渲染、敵人戰鬥動作本輪 NOT TESTED。
- `Formal Seal=NO`。絕不將本階段工程性 PASS 宣稱整張地圖美術分層完成。

## 下一階段
下一步應逐件處理**真正會與玩家腳位交會**的屋頂突出檐口、橋欄、樹冠/樹幹等（含 source-mask depth witness），並把可行走的合法路徑從中央道路、兩棟屋門前、橋面、溪流/石壁逐格視覺比對。別再花時間把精準同源 RGB 跑一百次當成美術改善。
'''
hfile=R/'CURRENT_HANDOFF_FS_MASTERFIRST_V3_NATIVE_20261107.md'
hfile.write_text(h,encoding='utf8')
registry.append({'path':hfile.relative_to(R).as_posix(),'bytes':hfile.stat().st_size,'sha256':sha(hfile)})
index={
 'stage':'FS_MASTER_FIRST_V3_NATIVE_ACTOR_COLLISION_SOURCE_REGISTERED',
 'master_sha':sha(D/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png'),
 'native_new_master_gameexe':True,
 'native_cloned_engine_original_file_SHA_unchanged':all(Q['original_test_engine_file_shas_unchanged'].values()),
 'native_map050_rebuilt_grid_40x29':True,'native_tiles':'1160/1160 PASS','native_edges':'4502/4502 PASS',
 'canopy_walkable_real_native_dynamic':'2/2 PASS',
 'clear_negative_native':'1/1 PASS',
 'roof_native':'2 ENGINE_ONLY, positions blocked; not actor game semantic PASS',
 'runtime_exact_master_pixels':True,'authoring_exact_master_pixels':True,
 'runtime_mask_opaque_px':118425,'draft_collision_blocked':370,
 'new_source_art_generated':False,'full_semantic_mask_gate':'FAIL_CLOSED',
 'human_art_approved':False,'formal_seal':'NO',
 'files':registry}
idx=R/'DELIVERY_SHA256_MANIFEST.json';idx.write_text(json.dumps(index,ensure_ascii=False,indent=2),encoding='utf8')
zipf=P/'FS_MASTERFIRST_V3_NATIVE_GROUND_PAR_COLLISION_QA_20261107.zip'
if zipf.exists():raise SystemExit('Archive pre-existing')
files=sorted([z for z in R.rglob('*') if z.is_file()])
with zipfile.ZipFile(zipf,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as f:
 for file in files:f.write(file,file.relative_to(R).as_posix())
with zipfile.ZipFile(zipf) as f:assert f.testzip() is None and len(f.namelist())==len(files)
for z in files:
 rel=z.relative_to(R).as_posix()
 if rel in {a['path'] for a in registry}:
  assert any(a['path']==rel and sha(z)==a['sha256'] for a in registry)
# Upload public user-facing evidence to private Google Drive mount, verify bytes after sync.
upload=[zipf,idx,hfile,mcp,N/'M3_NATIVE_5_CASES_OFF_ON_544x416_CONTACT.png',N/'M3_NATIVE_QA_REPORT.json',V/'Data/Map050.rvdata']
results=[]
for p in upload:
 target=D/p.name
 if target.exists():raise RuntimeError('Refused overwrite '+target.name)
 shutil.copy2(p,target)
 results.append({'name':p.name,'bytes':p.stat().st_size,'sha_ok':sha(p)==sha(target)})
assert all(x['sha_ok'] for x in results)
print(json.dumps({'member_count':len(files),'zip_bytes':zipf.stat().st_size,'CRC':'PASS','native':'2 dynamic + 1 negative PASS','drive_uploads':results},ensure_ascii=False,indent=2),flush=True)