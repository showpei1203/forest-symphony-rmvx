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
("VX231","exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb","4065ea4be1bc6fa5c5154034c89d626bc30d29fa",[(175,50),(678,42),(1843,16),(2117,42),(2226,19)]),
("VX377","exported_scripts/377__id65670378__FS_ATB_DynamicResistance_v1.0.0.rb","d14c274006d00f793017e9910d1e390ec5f9aeef",[(34,93),(326,11),(664,111),(816,41)]),
("GD_BATTLE","godot_port/scripts/FSBattle.gd","647fd0bd2bb61bdaddf38bd76948c7f744314c4a",[(971,108),(1112,80),(1211,19)]),
("GD_QUEUE","godot_port/scripts/FSActionQueue.gd","7f32f6e931b75ebfef69dbc0dc8f103ee226452a",[(280,72)]),
("GD_ATB","godot_port/scripts/FSTankentaiATBCore.gd","806bbe2aa5e5f8f3fabaa98935db7d2b833bec5a",[(128,95)]),
("VX406","exported_scripts/406__id23791037__FS_EnemyActionDistribution_FinalAuthority_v1.1.rb","06408e5ae0049fedc52289ff83f30ba091b0e1ef",[(165,90)]),
("VX462","exported_scripts/462__id68170006__FS_ForceAction_Bridge.rb","12659af67fa778134cb6b5d91e1519db126ad08d",[(109,46),(177,42)]),
("GD_RESIST","godot_port/scripts/FSATBResistance.gd","66203fa1898d139cfd2a4d9cc95ce11e7dc1b10d",[(0,114)]),
("VX234","exported_scripts/234__id12422743__Tankentai_Notetags_Add-on_v1.1.rb","b5f8b92bcd5343948fc65061ab43af29b8aba819",[(210,26),(998,26)]),
("VX374","exported_scripts/374__id21601036__FS_ComboCore_v1.1.1_OD.rb","f48fb90e6fa2b6a98953d888f9a3a5115671f137",[(2270,41),(2602,45)]),
("GD_STATE_ATB","godot_port/scripts/FSStateATBAuthority.gd","4240460e536e1b5e74f8731c24d948fd889eaf39",[(0,52)]),
("VX21","exported_scripts/021__id96014404__Game_Troop.rb","d576e3f55071ff875e74a8e0db30cb6dbbcd0e03",[(152,54)]),
("VX28","exported_scripts/028__id89128017__Game_Interpreter.rb","d508227e2e1fff1ab42db94f888f72ae687a5100",[(1630,23)]),
("GD_FORCE","godot_port/scripts/FSForceActionQueue.gd","834eb8cb67267243c84aa3f20debf42ecba9dc52",[(0,245)]),
("GD_TROOP_PAGES","godot_port/scripts/FSTroopForcePages.gd","e25fe7785f7248d4ea886cfd104a726a9bdcaa6b",[(0,127)]),
("VX88","exported_scripts/088__id24767163__Scene_Battle.rb","89bc1a9348f60904d1bf5c7b23d34e3dd7a364f9",[(922,32)]),
("VX411","exported_scripts/411__id61621387__FS_SkillCost_Authority_v2.0.0.rb","05909bf9e154019507969dfc50ff0e5fd50b75ae",[(1816,137)]),
("GD_SKILL_COST","godot_port/scripts/FSSkillCostRules.gd","b315b665af37435d0405deb31d1e748205b0a5fb",[(0,145)]),
("GD_ITEM","godot_port/scripts/FSItemRules.gd","45e33528b1abdd0a7dfb5ded61c6c9efdc646cdf",[(0,69)]),
("GD_EVENT_BRIDGE","godot_port/scripts/FSVXBattleBridge.gd","36a1f5318b8e601fc94663498903cda813e6e3ae",[(0,163)]),
("VX14","exported_scripts/014__id65931833__Game_BattleAction.rb","1a46c60c3aed1f527b108881a3eccc77645b9d33",[(173,29)]),
("VX210","exported_scripts/210__id99918659__FS_AI_DeterministicRandom_v1.0.rb","81211c685361ec328968cd587d88539553d3b6bf",[(28,145)]),
("VX372","exported_scripts/372__id96885223__FS_RandomTarget_Authority_v1.2｜TargetPriority___Provoke.rb","5115a1ab2d6ddb81cfa0beb38c61b1fffd3f8cd2",[(489,201)]),
("GD_TARGET","godot_port/scripts/FSTargetPriority.gd","9ae06fb1a36012f16bafdadb7b9fd2213d3bd23d",[(0,144)]),
("GD_AI_RNG","godot_port/scripts/FSAIRandom.gd","344866d5541433e7cbb79e9e599bdb9c373a8c48",[(0,41)]),
("GD_SCREEN","godot_port/scripts/FSScreen.gd","12bb9d807651dcb1b2bb20a52c134fa60f9d2a3b",[(256,37),(918,78),(1177,47),(1257,77)]),
("GD_PRESENTER","godot_port/scripts/ui/FSBattleActor01Presenter.gd","4bc83b2fd61ae6ef0ea5c45f944ababe35cd0086",[(0,141)]),
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
        ps="$ErrorActionPreference='Stop'; try { Import-Module (Join-Path $PSHOME 'Modules\\Microsoft.PowerShell.Security\\Microsoft.PowerShell.Security.psd1') -ErrorAction Stop; $s=Microsoft.PowerShell.Security\\Get-AuthenticodeSignature -LiteralPath $env:CRAFT_FIXED_SIGNATURE_PATH; $thumb='NONE'; if ($null -ne $s.SignerCertificate) { $thumb=$s.SignerCertificate.Thumbprint }; [Console]::WriteLine(([string]$s.Status)+'|'+$thumb) } catch { [Console]::WriteLine('SIGNATURE_QUERY_ERROR|'+$_.Exception.GetType().Name); exit 2 }"
        import base64
        encoded=base64.b64encode(ps.encode("utf-16-le")).decode("ascii")
        proc=subprocess.run(["powershell.exe","-NoProfile","-NonInteractive","-EncodedCommand",encoded],cwd=root,env=env,capture_output=True,timeout=30)
        status=proc.stdout.decode("ascii","replace").strip()
        safe=status if re.fullmatch(r"(?:Valid|NotSigned|HashMismatch|NotTrusted|UnknownError|NotSupportedFileFormat|Incompatible|SIGNATURE_QUERY_ERROR)\|[A-Za-z0-9_]{1,100}",status) else "UNCLASSIFIED"
        print("CRAFT_CLOUD_SIGNATURE; Role="+("CLI" if p==cli else "GUI")+"; Status="+safe+"; Exit="+str(proc.returncode),flush=True)
        check(proc.returncode==0 and status=="Valid|"+THUMB,"signature")
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
        print("CRAFT_FS_SOURCE_PASS; Files="+str(len(CASES))+"; Pages="+str(len(receipts))+"; OriginalRuntimeExecuted=False; GodotExecuted=False",flush=True)
if __name__=="__main__":main()
