from pathlib import Path
import urllib.request,hashlib,json,struct
root=Path(__file__).resolve().parent
assets=root/'source_raw'
sources={
 'medieval_timber_small':{
  'cdn':'https://cdn.3dassets.dev/assets/28757/v1/model.glb',
  'source_page':'https://3dassets.dev/assets/medieval-mmo-starter-realm-timber-house-small-25223f49',
  'license':'CC0 1.0 Universal'},
 'medieval_thatch_cottage':{
  'cdn':'https://cdn.3dassets.dev/assets/28762/v1/model.glb',
  'source_page':'https://3dassets.dev/assets/medieval-mmo-starter-realm-thatched-cottage-3921d162',
  'license':'CC0 1.0 Universal'},
 'witch_cottage':{
  'cdn':'https://cdn.3dassets.dev/assets/32485/v1/model.glb',
  'source_page':'https://3dassets.dev/assets/witch-cottage-and-apothecary-hedge-witch-25562947-starter-scene',
  'license':'CC0 1.0 Universal'}
}
for name,info in sources.items():
 p=assets/(name+'.glb')
 try:
  data=urllib.request.urlopen(urllib.request.Request(info['cdn'],headers={'User-Agent':'Mozilla/5.0'}),timeout=40).read()
  assert data[:4]==b'glTF' and len(data)>10000,('invalid GLB',name,data[:100])
  p.write_bytes(data)
  jlen,typ=struct.unpack_from('<II',data,12)
  header=json.loads(data[20:20+jlen])
  info.update(bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),glb_version=int(struct.unpack_from('<I',data,4)[0]),mesh_count=len(header.get('meshes',[])),material_count=len(header.get('materials',[])),texture_count=len(header.get('textures',[])),extensions=header.get('extensionsUsed',[]))
  print('VERIFIED',name,len(data),'materials',info['material_count'],'meshes',info['mesh_count'],flush=True)
 except Exception as e:
  print('ERROR',name,str(e),flush=True)
  info['error']=str(e)
(root/'STAGE7_SOURCE_PROVENANCE.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2),encoding='utf-8')