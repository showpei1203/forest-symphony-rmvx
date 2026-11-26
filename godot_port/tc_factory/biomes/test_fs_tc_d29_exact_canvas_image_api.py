#!/usr/bin/env python3
"""Offline contract verification; no API requests, tokens, payments, or artwork edits."""
import importlib.util
import io
import os
from pathlib import Path
from types import SimpleNamespace
from tempfile import TemporaryDirectory
import unittest
from PIL import Image

HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('d29',HERE/'fs_tc_d29_exact_canvas_image_api.py')
d29=importlib.util.module_from_spec(spec);spec.loader.exec_module(d29)
class D29Tests(unittest.TestCase):
    def fake_png(self,size=(1280,928),mode='RGBA',color=(0,0,0,0)):
        v=Image.new(mode,size,color)
        if mode=='RGBA':v.putpixel((100,100),(180,90,40,255))
        mem=io.BytesIO();v.save(mem,format='PNG');return mem.getvalue()
    def test_canvas_contract_and_model(self):
        self.assertEqual((1280%16,928%16),(0,0))
        self.assertIn('gpt-image-2.5-sunburst',d29.MODEL)
        self.assertIn('all-non-ground',d29.SCENE_PROMPT)
    def test_exact_native_and_alpha_not_art_pass(self):
        r=d29.source_gate_png_bytes(self.fake_png())
        self.assertEqual(r['source_gate'],'PASS')
        self.assertFalse(r['approved_production_par'])
    def test_wrong_generated_canvas_is_rejected(self):
        r=d29.source_gate_png_bytes(self.fake_png((1473,1068)))
        self.assertIn('SOURCE_NATIVE_CANVAS_FAIL',r['errors'])
    def test_RGB_faux_alpha_rejected(self):
        r=d29.source_gate_png_bytes(self.fake_png(mode='RGB',color=(3,3,3)))
        self.assertIn('SOURCE_NOT_TRUE_RGBA',r['errors'])
        self.assertIn('SOURCE_NO_ALPHA_ZERO',r['errors'])
    def test_nearly_all_opaque_ground_master_rejected(self):
        with TemporaryDirectory() as t:
            a=Image.new('RGBA',(1280,928),(12,12,12,255))
            a.putpixel((1,1),(0,0,0,0))
            io_png=io.BytesIO();a.save(io_png,format='PNG')
            r=d29.source_gate_png_bytes(io_png.getvalue())
            self.assertIn('SOURCE_TRANSPARENCY_TOO_SPARSE_FOR_PAR',r['errors'])
    def test_fully_transparent_empty_par_rejected(self):
        r=d29.source_gate_png_bytes(self._empty())
        self.assertIn('SOURCE_NO_VISIBLE_FOREGROUND',r['errors'])
    def _empty(self):
        a=Image.new('RGBA',(1280,928),(0,0,0,0));out=io.BytesIO();a.save(out,format='PNG');return out.getvalue()
    def test_paid_gate_requires_explicit_owner_authorization(self):
        old=os.environ.pop('FS_TC_D29_PAID_RUN',None)
        try:
            with self.assertRaises(PermissionError):d29.enforce_paid_authorization(SimpleNamespace(execute=True,owner_approved_paid=False))
        finally:
            if old is not None:os.environ['FS_TC_D29_PAID_RUN']=old
    def test_build_request_spec_with_pinned_synthetic_ground_for_CI_only(self):
        with TemporaryDirectory() as t:
            target=Path(t)/'ground.png'
            Image.new('RGB',(1280,928),(55,66,77)).save(target)
            original=d29.GROUND_SHA
            try:
                d29.GROUND_SHA=d29.digest(target)
                spec=d29.build_request_spec(target)
                self.assertEqual(spec['size'],'1280x928')
                self.assertEqual(spec['background'],'transparent')
                self.assertEqual(spec['output_format'],'png')
                self.assertEqual(spec['n'],1)
                self.assertFalse(spec['paid_execution_authorized'])
                self.assertTrue(spec['no_component_operations'])
            finally:
                d29.GROUND_SHA=original
    def test_unsupported_opaque_gpt_image_2_blocked(self):
        with TemporaryDirectory() as t:
            target=Path(t)/'ground.png'
            Image.new('RGB',(1280,928),(55,66,77)).save(target)
            original=d29.GROUND_SHA
            try:
                d29.GROUND_SHA=d29.digest(target)
                with self.assertRaisesRegex(ValueError,'UNVERIFIED_MODEL'):d29.build_request_spec(target,'gpt-image-2')
            finally:
                d29.GROUND_SHA=original
    def test_dry_run_requires_valid_source_sha(self):
        with TemporaryDirectory() as t:
            bad=Path(t)/'ground.png';Image.new('RGB',(1280,928),(55,66,77)).save(bad)
            with self.assertRaisesRegex(ValueError,'SHA_MISMATCH'):d29.verify_ground(bad)
    def test_no_component_or_rescale_in_generation(self):
        import inspect
        s=inspect.getsource(d29.execute_once)
        for code in ['.resize(','.crop(','connected_components','alpha_composite(']:self.assertNotIn(code,s)
if __name__=='__main__':unittest.main(verbosity=2)
