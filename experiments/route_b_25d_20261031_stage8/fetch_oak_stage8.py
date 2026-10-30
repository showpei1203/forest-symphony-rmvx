from pathlib import Path
import hashlib,json,urllib.request,struct
r=Path(__file__).resolve().parent
u='https://www.innerscene.com/api/library/oak-street-tree-detailed-leaves-a273fef9/download'
p=r/'source_raw'/'oak_detailed_innerscene.glb'
p.parent.mkdir(exist_ok=True)
request=urllib.request.Request(u,headers={'User-Agent':'Mozilla/5.0'})
response=urllib.request.urlopen(request,timeout=50)
data=response.read()
assert data[:4]==b'glTF',f'invalid source {data[:30]!r}'
p.write_bytes(data)
n=struct.unpack_from('<I',data,12)[0]
g=json.loads(data[20:20+n])
manifest={'source_page':'https://www.innerscene.com/tools/library/3d-parts/oak-street-tree-detailed-leaves-a273fef9','download_url':u,'publisher':'Innerscene','license_as_stated_by_publisher':'CC0','bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'mesh_count':len(g.get('meshes',[])),'material_count':len(g.get('materials',[])),'extensions_used':g.get('extensionsUsed',[]),'nodes':len(g.get('nodes',[])),'textures':len(g.get('textures',[]))}
(r/'STAGE8_OAK_SOURCE_MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(manifest,indent=2),flush=True)