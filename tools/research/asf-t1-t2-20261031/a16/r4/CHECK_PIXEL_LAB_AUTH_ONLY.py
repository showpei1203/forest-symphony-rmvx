"""Safe PixelLab authentication diagnostic. Only GET /v2/balance.
NO generate endpoints; NO tokens stored; NO browser cookies read.
"""
import os, urllib.request, urllib.error, json, sys
from pathlib import Path
BASE=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF")
key=os.environ.get("PIXELLAB_API_KEY","").strip()
if not key:
    print("RESULT: MISSING_TOKEN. Nothing sent.");sys.exit(2)
if key.lower().startswith("bearer "):
    print("NOTICE: Token text begins with 'Bearer '; only token is needed.")
    key=key[7:].strip()
if not key or " " in key or "\n" in key:
    print("RESULT: TOKEN_FORMAT_SUSPICIOUS. No request sent.");sys.exit(2)
req=urllib.request.Request("https://api.pixellab.ai/v2/balance",
        headers={"Authorization":"Bearer "+key,"Accept":"application/json"},
        method="GET")
try:
    with urllib.request.urlopen(req,timeout=20) as resp:
        payload=json.loads(resp.read(50000))
    print("RESULT: AUTH_OK. API Token was accepted. HTTP 200.")
    account=payload.get("subscription",{})
    if isinstance(account,dict):
        print("SUBSCRIPTION_STATUS:",account.get("status","unknown"))
        print("GENERATIONS_AVAILABLE:",account.get("generations","unknown"))
    print("NEXT: The original HTTP 400 probably concerns the animation request or PixelLab server; do NOT retry generation yet.")
except urllib.error.HTTPError as e:
    print("RESULT: AUTH_REQUEST_REJECTED. HTTP",e.code)
    if e.code==401:print("NEXT: Token invalid, expired or wrong account. Obtain a new token in PixelLab settings.")
    elif e.code==403:print("NEXT: Account has no API permission.")
    else:print("NEXT: Investigate API response; no animation was submitted.")
    sys.exit(1)
except Exception as e:
    print("RESULT: NETWORK_OR_FORMAT_ERROR:",type(e).__name__)
    sys.exit(1)
finally:
    key=""
