from pathlib import Path
R3=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
s=(R3/"a36g_capture_native_r3b.py").read_text("utf8")
s=s.replace(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104\R3B_VX_CAPTURES",
            r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104\R4_VX_CAPTURES")
s=s.replace(r"E:\FS_STAGE16_A36G_PIXELLAB_R3B_VX_NATIVE_20261104",
            r"E:\FS_STAGE16_A36G_R4_VX_NATIVE_20261104")
s=s.replace("MAP_OBJECTS count=418","MAP_OBJECTS count=189")
assert "MAP_OBJECTS count=189" in s
assert r"E:\FS_STAGE16_A36G_R4_VX_NATIVE_20261104" in s
(R4/"R4_VX_CAPTURES").mkdir(exist_ok=True)
(R4/"r4_capture_native.py").write_text(s,"utf8")
print("R4_NATIVE_CAPTURER_READY")
