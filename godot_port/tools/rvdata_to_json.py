#!/usr/bin/env python3
"""RPG Maker VX Ruby Marshal 4.8 decoder. Read-only unless --output is explicit.
No third-party packages. Preserve class names, raw note tags and record IDs.
Unknown Ruby user-data payloads remain base64, NEVER silently discarded.
"""
import argparse
import base64
import json
from pathlib import Path
import struct

DATA_NAMES = ("Actors","Classes","Skills","Items","Weapons","Armors",
              "Enemies","States","Troops","System","Animations")

def decode_text(data):
    for coding in ("utf-8","cp950","cp932"):
        try:
            return data.decode(coding)
        except UnicodeDecodeError:
            pass
    return data.decode("latin1")

class RubyMarshal48:
    def __init__(self, data):
        self.data = memoryview(data)
        self.pos = 0
        self.symbols = []
        self.objects = []

    def take(self, n):
        if n < 0 or self.pos + n > len(self.data):
            raise ValueError("Bad Marshal length at byte %d" % self.pos)
        out = self.data[self.pos:self.pos+n].tobytes()
        self.pos += n
        return out

    def byte(self):
        return self.take(1)[0]

    def int8(self):
        x = self.byte()
        return x - 256 if x > 127 else x

    def integer(self):
        c = self.int8()
        if c == 0: return 0
        if c > 4: return c - 5
        if c < -4: return c + 5
        count = abs(c)
        b = self.take(count)
        return int.from_bytes(
            b + ((b"\xff" if c < 0 else b"\x00") * (4-count)),
            byteorder="little", signed=True)

    def payload(self):
        return self.take(self.integer())

    def track(self, value):
        self.objects.append(value)
        return value

    def symbol(self):
        value = self.value()
        if not isinstance(value, str):
            raise ValueError("Expected Ruby symbol")
        return value

    def value(self):
        tag = chr(self.byte())
        if tag == "0": return None
        if tag == "T": return True
        if tag == "F": return False
        if tag == "i": return self.integer()
        if tag == ":":
            s = decode_text(self.payload())
            self.symbols.append(s)
            return s
        if tag == ";": return self.symbols[self.integer()]
        if tag == "@": return self.objects[self.integer()]
        if tag == '"': return self.track(decode_text(self.payload()))
        if tag == "f":
            string = self.payload().decode("ascii")
            return self.track(float(string) if string not in ("nan","inf","-inf") else string)
        if tag == "[":
            result = self.track([])
            result.extend(self.value() for _ in range(self.integer()))
            return result
        if tag in ("{","}"):
            result = self.track({"__ruby_hash_pairs__":[]})
            for _ in range(self.integer()):
                result["__ruby_hash_pairs__"].append([self.value(), self.value()])
            if tag == "}": result["__ruby_default__"] = self.value()
            return result
        if tag == "o":
            result = self.track({"__ruby_class__":self.symbol()})
            for _ in range(self.integer()):
                result[self.symbol().lstrip("@")] = self.value()
            return result
        if tag == "S":
            result = self.track({"__ruby_struct__":self.symbol()})
            for _ in range(self.integer()):
                result[self.symbol()] = self.value()
            return result
        if tag == "I":
            obj = self.value()
            attrs = {self.symbol():self.value() for _ in range(self.integer())}
            if isinstance(obj,dict) and attrs:
                obj.setdefault("__ruby_ivars__",{}).update(attrs)
            return obj
        if tag == "u":
            name = self.symbol()
            data = self.payload()
            result = {"__ruby_user_class__":name,
                      "__raw_base64__":base64.b64encode(data).decode("ascii")}
            if name.endswith("Table") and len(data) >= 20:
                dims,x,y,z,n = struct.unpack_from("<5I",data)
                if 1 <= dims <= 3 and n <= 10000000 and len(data) == 20 + 2*n:
                    result = {"__ruby_user_class__":name,"dimensions":dims,
                              "xsize":x,"ysize":y,"zsize":z,
                              "data_int16":list(struct.unpack_from("<%dh"%n,data,20))}
            return self.track(result)
        if tag == "U":
            result = self.track({"__ruby_marshal_class__":self.symbol()})
            result["value"] = self.value()
            return result
        if tag == "C":
            name = self.symbol()
            return {"__ruby_uclass__":name,"value":self.value()}
        if tag == "e":
            name = self.symbol()
            return {"__ruby_extended__":name,"value":self.value()}
        if tag == "l":
            sign = chr(self.byte())
            n = self.integer()
            x = int.from_bytes(self.take(n*2),"little")
            return self.track(x if sign == "+" else -x)
        if tag == "/":
            pattern = decode_text(self.payload())
            return self.track({"__ruby_regexp__":pattern,"flags":self.byte()})
        if tag in ("c","m","M"):
            return self.track({"__ruby_type__":tag,"name":decode_text(self.payload())})
        raise ValueError("Unsupported Marshal tag %r at byte %d"%(tag,self.pos-1))

    def parse(self):
        if self.take(2) != b"\x04\x08":
            raise ValueError("Expected Ruby Marshal 4.8")
        item = self.value()
        if self.pos != len(self.data):
            raise ValueError("Marshal trailing bytes: %d"%(len(self.data)-self.pos))
        return item

def json_safe(value, stack=None):
    if stack is None: stack = set()
    if isinstance(value,(dict,list)):
        if id(value) in stack:
            return {"__ruby_cycle__":True}
        stack.add(id(value))
        out = ({k:json_safe(v,stack) for k,v in value.items()}
               if isinstance(value,dict)
               else [json_safe(v,stack) for v in value])
        stack.remove(id(value))
        return out
    return value

def audit(source, output=None, names=None):
    source = Path(source)
    report = {}
    for name in (names or DATA_NAMES):
        file = source / (name+".rvdata")
        obj = json_safe(RubyMarshal48(file.read_bytes()).parse())
        report[name] = {
            "source_bytes":file.stat().st_size,
            "records_including_nil":len(obj) if isinstance(obj,list) else 1,
            "non_null_records":sum(x is not None for x in obj) if isinstance(obj,list) else 1,
            "first_class":next((x.get("__ruby_class__") for x in obj if isinstance(x,dict)),None) if isinstance(obj,list) else obj.get("__ruby_class__") if isinstance(obj,dict) else None
        }
        if output is not None:
            target = Path(output) / (name.lower()+".json")
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text(json.dumps(obj,ensure_ascii=False,separators=(",",":")),encoding="utf-8")
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("data_dir")
    p.add_argument("--output",help="Explicit output dir; NEVER on user's PC without prior permission")
    p.add_argument("--datasets",nargs="+",choices=DATA_NAMES)
    args=p.parse_args()
    print(json.dumps(audit(args.data_dir,args.output,args.datasets),ensure_ascii=False,indent=2))

if __name__=="__main__":
    main()
