from pathlib import Path
import json,sys,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
sys.path.insert(0,str(r/"pydeps"))
from playwright.sync_api import sync_playwright
from PIL import Image
a=r.parent/"benchmarks"/"monster_32.png"
out=r/"outputs"/"browser_tools";out.mkdir(exist_ok=True)
rep={"tool":"SpriteLab Web","license":"OPEN_SOURCE_UNVERIFIED"}
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True,executable_path=r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",args=["--no-sandbox","--disable-gpu"])
 context=browser.new_context(accept_downloads=True,viewport={"width":1250,"height":900})
 page=context.new_page()
 response=page.goto("https://spritelab.dev/tools/normal-map-generator",wait_until="domcontentloaded",timeout=35000)
 page.locator('input[type="file"]').first.set_input_files(str(a))
 page.wait_for_timeout(1400)
 with page.expect_download(timeout=15000) as d:
  page.get_by_role("button",name="DOWNLOAD PNG").click()
 dl=d.value
 dest=out/"spritelab_normal_download.png"
 dl.save_as(str(dest))
 im=Image.open(dest).convert("RGBA")
 orig=Image.open(a).convert("RGBA")
 alpha_ok=im.getchannel("A").tobytes()==orig.getchannel("A").tobytes()
 rep.update({"http_status":response.status,"file":str(dest),"size":im.size,"alpha_exact":alpha_ok,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest()})
 rep["status"]="BROWSER_DOWNLOAD_PASS" if (im.size==orig.size and alpha_ok) else "FAIL"
 context.close();browser.close()
(r/"reports"/"T06_SPRITELAB_WEB.json").write_text(json.dumps(rep,ensure_ascii=False,indent=2),encoding="utf8")
print("T06_SPRITELAB",rep["status"],rep["size"],"alpha",rep["alpha_exact"])
if rep["status"]!="BROWSER_DOWNLOAD_PASS":raise SystemExit(2)
