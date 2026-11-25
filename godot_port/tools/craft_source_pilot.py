"""Cloud-only Craft v0.6.1 read-only source audit. No target code is executed."""
import hashlib,json,os,pathlib,subprocess,tempfile,urllib.request,zipfile,io,stat,re
SHA="bd370fbaa2b44dbc13581db5ffd2bf66924ed40e433c7902212aa17ca781de54"
SIZE=69934191
URL="https://github.com/storytold/craft-anything/releases/download/v0.6.1/craft-anything-0.6.1-windows-x64-portable.zip"
PREFIX="craft-anything-0.6.1-windows-x64-portable"
CLI_SHA="21e01ccd80e3cc3024101dd1f9df56180cdf269868f6024373763845a1b2e086"
GUI_SHA="5937c281c36ddce51370684c3c01383508fc1e014597ace35bc6014a9d529656"
THUMB="CD9016D1FE805AB0B9B35CEF48F21E3049670183"
CASES=[
("VX230","exported_scripts/230__id55188000__ATB_Configurations.rb","3fe73b99012548f9f3e1d3ed3ec76a337be4713d",[(158,63)]),
("VX231","exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb","4065ea4be1bc6fa5c5154034c89d626bc30d29fa",[(175,50),(2117,42),(2226,19)]),
("VX377","exported_scripts/377__id65670378__FS_ATB_DynamicResistance_v1.0.0.rb","d14c274006d00f793017e9910d1e390ec5f9aeef",[(34,93)]),
("GD_BATTLE","godot_port/scripts/FSBattle.gd","60e42f4455c86bdee9d34d030632b88593fc8e1f",[(960,70)]),
("GD_QUEUE","godot_port/scripts/FSActionQueue.gd","876b46507f6f9daf5d88a56c405876cd5ae6438d",[(279,70)]),
("GD_ATB","godot_port/scripts/FSTankentaiATBCore.gd","806bbe2aa5e5f8f3fabaa98935db7d2b833bec5a",[(128,95)]),
]
def sha(x): return hashlib.sha256(x).hexdigest()
def check(ok,reason):
    if not ok: raise RuntimeError(reason)
def run(args,cwd,env=None,timeout=30):
    p=subprocess.run([str(x) for x in args],cwd=cwd,env=env,capture_output=True,timeout=timeout)
    check(p.returncode==0 and len(p.stdout)<4_000_000 and len(p.stderr)<4_000_000,"bounded subprocess failed: "+str(args[0]))
    return p.stdout
def install(root):
    with urllib.request.urlopen(URL,timeout=40) as r: raw=r.read(SIZE+1)
    check(len(raw)==SIZE and sha(raw)==SHA,"official ZIP mismatch")
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        check(len(z.infolist())==23,"archive count")
        names=set()
        for f in z.infolist():
            parts=f.orig_filename.split("/")
            check(len(parts)==2 and parts[0]==PREFIX and re.fullmatch(r"[A-Za-z0-9._-]{1,100}",parts[1]) and parts[1] not in (".",".."),"path")
            check(f.orig_filename.casefold() not in names and not f.is_dir() and stat.S_IFMT(f.external_attr>>16) in (0,stat.S_IFREG) and not(f.external_attr&0x400),"entry")
            names.add(f.orig_filename.casefold())
            check(f.file_size<=150_000_000,"size")
        check(sum(f.file_size for f in z.infolist())==146722948,"expanded size")
        d=root/PREFIX;d.mkdir()
        for f in z.infolist():
            p=root/f.orig_filename
            with p.open("xb") as out:out.write(z.read(f))
        cli=d/"craft-anything-cli.exe";gui=d/"craft-anything.exe"
        check(sha(cli.read_bytes())==CLI_SHA and sha(gui.read_bytes())==GUI_SHA,"exe hash")
    # Native Authenticode trust check on the exact hash-pinned executable.
    for p in (cli,gui):
        env=os.environ.copy();env["CRAFT_FIXED_SIGNATURE_PATH"]=str(p)
        ps="$s=Get-AuthenticodeSignature -LiteralPath $env:CRAFT_FIXED_SIGNATURE_PATH; Write-Output ($s.Status.ToString()+'|'+$s.SignerCertificate.Thumbprint)"
        status=run(["powershell.exe","-NoProfile","-NonInteractive","-Command",ps],root,env).decode().strip()
        check(status=="Valid|"+THUMB,"signature")
    return cli
def source_bytes(repo,path,blob):
    raw=run(["git","cat-file","blob",blob],repo)
    check(hashlib.sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest()==blob,"Git object hash")
    check(run(["git","rev-parse","HEAD:"+path],repo).decode().strip()==blob,"source drift")
    return raw
def rust_lines(raw):
    text=raw.decode("utf-8-sig")
    lines=text.split("\n")
    if lines and lines[-1]=="":lines.pop()
    return [line[:-1] if line.endswith("\r") else line for line in lines]
def main():
    repo=pathlib.Path.cwd()
    with tempfile.TemporaryDirectory(prefix="craft-source-cloud-") as t:
        root=pathlib.Path(t)
        cli=install(root)
        env={k:v for k,v in os.environ.items() if k.upper() in {"SYSTEMROOT","WINDIR","SYSTEMDRIVE","COMSPEC","PROCESSOR_ARCHITECTURE","NUMBER_OF_PROCESSORS"}}
        env["PATH"]=str(pathlib.Path(env["SYSTEMROOT"])/"System32")
        for k in ("TEMP","TMP","USERPROFILE","HOME","APPDATA","LOCALAPPDATA","CRAFT_ANYTHING_CONFIG_DIR"):
            p=root/k.lower();p.mkdir();env[k]=str(p)
        check(run([cli,"--version"],root,env).decode().strip()=="craft-anything-cli 0.6.1","version")
        receipts=[]
        for id,path,blob,pages in CASES:
            raw=source_bytes(repo,path,blob)
            target=root/(id+pathlib.Path(path).suffix)
            target.write_bytes(raw)
            expected=rust_lines(raw)
            for offset,limit in pages:
                args={"path":str(target),"offset":offset,"limit":limit}
                response=run([cli,"--deep","--format","json","core-text-read","--json",json.dumps(args)],root,env)
                evidence=json.loads(response)
                result=evidence["result"]
                wanted="\n".join(expected[offset:offset+limit])+"\n"
                check(result["text"]==wanted and result["offset"]==offset and result["lines"]==len(expected[offset:offset+limit]),"Craft line mismatch "+id)
                check(result["file_size"]==len(raw) and result["replaced_sequences"]==0 and not result["cut_lines"],"Craft coverage mismatch "+id)
                check(evidence.get("confidence")=="observed","confidence")
                receipts.append({"id":id,"source_blob":blob,"source_sha256":sha(raw),"offset":offset,"lines":result["lines"],"text_sha256":sha(result["text"].encode()),"coverage":evidence.get("coverage",{}),"response_sha256":sha(response)})
            check(target.read_bytes()==raw,"source mutation")
        # Only receipts for already-public sources; never expose config, raw code or host paths.
        for r in receipts: print("CRAFT_FS_EVIDENCE; "+json.dumps(r,sort_keys=True),flush=True)
        print("CRAFT_FS_SOURCE_PASS; Files=6; Pages="+str(len(receipts))+"; OriginalRuntimeExecuted=False; GodotExecuted=False",flush=True)
if __name__=="__main__":main()
