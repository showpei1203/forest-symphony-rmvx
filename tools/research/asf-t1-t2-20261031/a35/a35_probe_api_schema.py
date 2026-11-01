import json,urllib.request
j=json.load(urllib.request.urlopen('https://api.pixellab.ai/v2/openapi.json',timeout=15))
for name in ['InterpolationV2Request','EditAnimationV2Request']:
 s=j['components']['schemas'][name]
 print('\n',name,'REQUIRED',s.get('required'))
 for k,v in s.get('properties',{}).items():
  print(k,json.dumps(v,ensure_ascii=False)[:1100])
for name in ['ImageData','Base64Image']:
 if name in j['components']['schemas']:print(name,json.dumps(j['components']['schemas'][name])[:2000])
