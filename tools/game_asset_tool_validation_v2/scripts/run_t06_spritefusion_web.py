from pathlib import Path
import sys,json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
sys.path.insert(0,str(r/"pydeps"))
from playwright.sync_api import sync_playwright
from PIL import Image
out=r/"outputs"/"browser_tools";out.mkdir(exist_ok=True)
asset=r.parent/"benchmarks"/"monster_32.png"
rec={"tool":"Sprite Fusion Sprite Normals Web","status":"FAIL"}
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True,executable_path=r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",args=["--no-sandbox","--disable-gpu"])
 context=browser.new_context(accept_downloads=True,viewport={"width":1250,"height":900})
 page=context.new_page()
 page.goto("https://www.spritefusion.com/sprite-normals",wait_until="domcontentloaded",timeout=35000)
 page.locator('input[type="file"]').first.set_input_files(str(asset))
 page.wait_for_timeout(3500)
 btn=page.locator('button[aria-label*="Download the normal map"]')
 rec["specific_download_found"]=btn.count()==1
 if btn.count()==1:
  with page.expect_download(timeout=22000) as info:
   btn.click()
  downloaded=info.value
  path=out/"spritefusion_web_monster_32_n.png"
  downloaded.save_as(str(path))
  im=Image.open(path).convert("RGBA")
  a=Image.open(asset).convert("RGBA")
  rec.update({"status":"BROWSER_DOWNLOAD_PASS" if im.size==a.size and im.getchannel("A").tobytes()==a.getchannel("A").tobytes() else "ALPHA_OR_SIZE_FAIL",
       "file":str(path),"bytes":path.stat().st_size,"dimensions":im.size,"alpha_exact":a.getchannel("A").tobytes()==im.getchannel("A").tobytes(),"sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
 context.close();browser.close()
(r/"reports"/"T06B_SPRITEFUSION_WEB.json").write_text(json.dumps(rec,ensure_ascii=False,indent=2),encoding="utf8")
print("T06B_SPRITEFUSION_WEB",rec["status"],rec.get("dimensions"),rec.get("alpha_exact"),flush=True)
if rec["status"]!="BROWSER_DOWNLOAD_PASS":raise SystemExit(2)
