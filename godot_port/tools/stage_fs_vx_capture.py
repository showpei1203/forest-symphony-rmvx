#!/usr/bin/env python3
"""Pinned binary-safe script staging (Ruby 1.8/encoded Marshal 4.8).
Dry-run is default. New isolated-root writes require separate owner consent.
Never launches original VX, never writes input.
"""
import argparse, hashlib, json, re, zlib
from pathlib import Path

RAW_SHA="d398178135c5b41622b0e6da763d58af1fbf770c9d24a360a23508800015809a"
COUNT=505
MAIN_INDEX=482
MAIN_ID=32270711
PROBE_ID=190702761

def sha(data):return hashlib.sha256(data).hexdigest()

class ScriptMarshal:
    def __init__(self,data):
        self.raw=data;self.pos=0;self.objects=[];self.symbols=[]
    def take(self,n):
        if n<0 or self.pos+n>len(self.raw):raise ValueError("truncated Marshal")
        v=self.raw[self.pos:self.pos+n];self.pos+=n;return v
    def integer(self):
        n=int.from_bytes(self.take(1),"little",signed=True)
        if n==0:return 0
        if n>4:return n-5
        if n<-4:return n+5
        return int.from_bytes(self.take(abs(n))+((b"\xff" if n<0 else b"\x00")*(4-abs(n))),"little",signed=True)
    def value(self,depth=0):
        if depth>8:raise ValueError("script nesting")
        t=self.take(1)
        if t==b"i":return self.integer()
        if t==b"T":return True
        if t==b"F":return False
        if t==b"0":return None
        if t==b"[":
            n=self.integer()
            if not 0<=n<=1024:raise ValueError("array size")
            a=[];self.objects.append(a)
            for _ in range(n):a.append(self.value(depth+1))
            return a
        if t==b'"':
            v=self.take(self.integer());self.objects.append(v);return v
        if t==b":":
            v=("sym",self.take(self.integer()));self.symbols.append(v);return v
        if t in (b"@",b";"):
            table=self.objects if t==b"@" else self.symbols
            n=self.integer()
            if not 0<=n<len(table):raise ValueError("bad link")
            return table[n]
        if t==b"I":
            first=len(self.objects)
            v=self.value(depth+1)
            # Only fresh string encoding wrappers, not arbitrary IVAR objects.
            if not isinstance(v,bytes) or len(self.objects)!=first+1:raise ValueError("unsupported IVAR object")
            count=self.integer()
            if not 1<=count<=2:raise ValueError("unsupported encoding attribute count")
            attrs=[]
            for _ in range(count):
                k=self.value(depth+1);val=self.value(depth+1)
                if k==("sym",b"E"):
                    if type(val) is not bool:raise ValueError("invalid encoding flag")
                elif k==("sym",b"encoding"):
                    if not isinstance(val,bytes):raise ValueError("invalid encoding name")
                else:raise ValueError("unsupported string IVAR")
                attrs.append((k,val))
            wrapped=("ivar",v,attrs)
            self.objects[first]=wrapped
            return wrapped
        raise ValueError("unsupported script-table tag "+repr(t))
    def parse(self):
        if self.take(2)!=b"\x04\x08":raise ValueError("not Marshal 4.8")
        v=self.value()
        if self.pos!=len(self.raw):raise ValueError("trailing bytes")
        return v

def enc_int(n):
    if type(n) is not int or not 0<=n<=2147483647:raise ValueError("script integer out of range")
    if n==0:return b"\x00"
    if n<=122:return bytes([n+5])
    size=(n.bit_length()+7)//8
    return bytes([size])+n.to_bytes(size,"little")
def encode(v):
    if v is True:return b"T"
    if v is False:return b"F"
    if v is None:return b"0"
    if type(v) is int:return b"i"+enc_int(v)
    if type(v) is bytes:return b'"'+enc_int(len(v))+v
    if type(v) is list:return b"["+enc_int(len(v))+b"".join(encode(x) for x in v)
    if type(v) is tuple and v[0]=="sym":return b":"+enc_int(len(v[1]))+v[1]
    if type(v) is tuple and v[0]=="ivar":
        return b"I"+encode(v[1])+enc_int(len(v[2]))+b"".join(encode(k)+encode(val) for k,val in v[2])
    raise ValueError("unsupported script value")
def string(v):
    if isinstance(v,bytes):return v
    if isinstance(v,tuple) and v[0]=="ivar" and isinstance(v[1],bytes):return v[1]
    raise ValueError("not a script string")

def build(raw,probe,expected_sha=RAW_SHA,count=COUNT,main_index=MAIN_INDEX):
    if len(raw)>32*1024*1024 or sha(raw)!=expected_sha:raise ValueError("source SHA/size mismatch")
    rows=ScriptMarshal(raw).parse()
    if not isinstance(rows,list) or len(rows)!=count:raise ValueError("script count mismatch")
    for row in rows:
        if not isinstance(row,list) or len(row)!=3 or type(row[0]) is not int:raise ValueError("invalid row")
        string(row[1]);string(row[2])
    if rows[main_index][0]!=MAIN_ID or string(rows[main_index][1])!=b"Main" or any(row[0]==PROBE_ID for row in rows):
        raise ValueError("Main/probe identity mismatch")
    if not 100<=len(probe)<=16384 or b"FS_BOOT_CAPTURE_PROBE" not in probe:raise ValueError("invalid probe")
    inserted=rows[:main_index]+[[PROBE_ID,b"FS_BOOT_CAPTURE_PROBE",zlib.compress(probe)]]+rows[main_index:]
    staged=b"\x04\x08"+encode(inserted)
    parsed=ScriptMarshal(staged).parse()
    if parsed!=inserted or parsed[:main_index]+parsed[main_index+1:]!=rows or zlib.decompress(string(parsed[main_index][2]))!=probe:
        raise ValueError("staged roundtrip mismatch")
    return staged,{"source_sha256":expected_sha,"staged_sha256":sha(staged),"probe_sha256":sha(probe),
        "original_sections":count,"staged_sections":len(parsed),"preserved_original_rows":count,
        "encoded_original_fields":sum(isinstance(v,tuple) for row in rows for v in row[1:]),
        "main_index":main_index,"main_id":MAIN_ID,"original_runtime_executed":False}

def stage(source,probe,root=None,nonce=None):
    source=Path(source)
    if not source.is_file() or source.is_symlink():raise ValueError("source file invalid")
    staged,receipt=build(source.read_bytes(),Path(probe).read_bytes())
    if root is None:
        receipt["writes"]=False;return receipt
    if not nonce or not re.fullmatch(r"[0-9a-f]{32}",nonce):raise ValueError("nonce invalid")
    root=Path(root)
    if root.exists() or root.is_symlink():raise ValueError("staging root must be new")
    root=root.resolve()
    if root.is_relative_to(source.resolve().parent.parent):raise ValueError("staging cannot be inside source project")
    root.mkdir(exist_ok=False)
    (root/"Data").mkdir();(root/"FS_BOOT_CAPTURE").mkdir()
    with (root/"Data/Scripts.rvdata").open("xb") as f:f.write(staged)
    with (root/"FS_BOOT_CAPTURE/SCOPE.txt").open("xb") as f:f.write(("FS_VX_CAPTURE_V1\n"+nonce+"\n").encode())
    if (root/"Data/Scripts.rvdata").read_bytes()!=staged or sha(source.read_bytes())!=RAW_SHA:
        raise ValueError("source or staged readback changed")
    receipt["writes"]=True;return receipt

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("source");p.add_argument("probe");p.add_argument("--new-root");p.add_argument("--nonce")
    a=p.parse_args()
    print(json.dumps(stage(a.source,a.probe,a.new_root,a.nonce),sort_keys=True))
