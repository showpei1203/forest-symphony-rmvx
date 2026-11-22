"""Synthetic CI checks of D14 white-object-plate to transparent CompletePAR converter."""
import tempfile
from pathlib import Path
from PIL import Image, ImageDraw
from fs_tc_white_plate_to_complete_par import convert, sha


def rejects(fn, phrase):
    try:
        fn()
    except ValueError as error:
        assert phrase in str(error), str(error)
    else:
        raise AssertionError("Invalid source was accepted: "+phrase)


def main():
    with tempfile.TemporaryDirectory(prefix="tc_d14_white_") as tmp:
        root=Path(tmp)
        ground=root/"locked_ground.png"
        plate=root/"independent_non_ground_white_plate.png"
        Image.new("RGB",(1280,928),(54,51,62)).save(ground)
        lock=sha(ground)
        src=Image.new("RGB",(1280,928),(254,254,254))
        brush=ImageDraw.Draw(src)
        brush.rectangle((60,120,450,420),fill=(74,68,84))
        brush.rectangle((770,160,1150,490),fill=(97,82,103))
        brush.rectangle((550,550,920,800),fill=(165,84,36))
        # Enclosed WHITE detail is NOT connected to canvas exterior and should remain visible.
        brush.ellipse((100,175,145,220),fill=(252,252,252))
        src.save(plate)
        v=convert(ground,plate,root/"native",lock,make_technical_preview=True)
        native=Image.open(root/"native/PAR_ALL_NON_GROUND_WHITE_KEY_SOURCE_NATIVE_SIZE.png")
        assert native.size==(1280,928)
        assert native.mode=="RGBA" and native.getpixel((0,0))[3]==0
        assert native.getpixel((80,140))[3]==255
        assert native.getpixel((122,192))[3]==255, "Protected white highlights were deleted"
        assert native.getpixel((600,620))[3]==255
        assert v["original_native_1280x928"] is True and v["formal_ART_GATE"]=="HOLD"
        assert v["resampled_source_not_native_1x"] is False
        assert sha(ground)==lock
        # Native source MUST NOT be claimed when a larger 1474x1067 source was scaled.
        large=src.resize((1474,1067),Image.Resampling.NEAREST)
        large.save(plate)
        non_native=convert(ground,plate,root/"non_native",lock,make_technical_preview=True)
        assert non_native["source_size"]==[1474,1067]
        assert non_native["original_native_1280x928"] is False
        assert non_native["resampled_source_not_native_1x"] is True
        assert Image.open(root/"non_native/PAR_RESAMPLED_TECH_ONLY_NOT_NATIVE_1X.png").size==(1280,928)
        # A full-color 'Master' cannot be misclassified as a foreground plate.
        Image.new("RGB",(1280,928),(45,43,48)).save(plate)
        rejects(lambda:convert(ground,plate,root/"bad_master",lock),"opaque Master")
        Image.new("RGB",(1280,928),(254,254,254)).save(plate)
        rejects(lambda:convert(ground,plate,root/"blank",lock),"almost blank")
        src.putpixel((0,0),(25,25,25));src.save(plate)
        rejects(lambda:convert(ground,plate,root/"corner",lock),"opaque corner")
        src.save(plate)
        rejects(lambda:convert(ground,plate,root/"sha_failure","0"*64),"SHA lock mismatch")
        src.save(plate)
        # Never overwrite originals or mutate the user's Ground.
        assert sha(ground)==lock
    print("D14 white key PASS synthetic: alpha, enclosed white, Master/blank/corner rejects, SHA lock, exact-vs-resampled labeling, Art HOLD")


if __name__=="__main__":
    main()
