"""A19 tests: fake provider only, zero paid requests, no private binaries in git."""
import base64
from io import BytesIO
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from PIL import Image
from tools.asset_factory.a19_one_shot_provider_gate import (
    A19Hold, A19UnknownSubmission, EXPECTED_REQUEST_SHA,
    PrivateOneShotLedger, check_explicit_grant, submit_once,
    verify_completed_raw_frames,
)


def fake_grant(**patches):
    g = {
        "user_explicitly_approved_one_paid_post": True,
        "request_sha256": EXPECTED_REQUEST_SHA,
        "approved_action": "pixel_lab_skeleton_v3_one_post",
        "approval_reference": "TEST-SYNTHETIC-NOT-A-GRANT",
        "max_authorized_usd": "0.05",
    }
    g.update(patches)
    return g


def fake_png(i):
    im=Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    for y in range(10, 40):
        for x in range(15, 35):
            im.putpixel((x, y), (40+i*50, 70, 120, 255))
    out=BytesIO()
    im.save(out, format="PNG")
    return out.getvalue()


class A19ProviderGateTests(unittest.TestCase):
    def test_no_approval_is_hold(self):
        with self.assertRaises(A19Hold):
            check_explicit_grant(request_sha=EXPECTED_REQUEST_SHA,
                                 grant=fake_grant(user_explicitly_approved_one_paid_post=False))

    def test_wrong_approval_sha_is_hold(self):
        with self.assertRaises(A19Hold):
            check_explicit_grant(request_sha=EXPECTED_REQUEST_SHA,
                                 grant=fake_grant(request_sha256='0'*64))

    def test_price_below_estimate_is_hold(self):
        with self.assertRaises(A19Hold):
            check_explicit_grant(request_sha=EXPECTED_REQUEST_SHA,
                                 grant=fake_grant(max_authorized_usd='0.01'))

    def test_invalid_price_nan_is_hold(self):
        with self.assertRaises(A19Hold):
            check_explicit_grant(request_sha=EXPECTED_REQUEST_SHA,
                                 grant=fake_grant(max_authorized_usd='NaN'))

    @patch('tools.asset_factory.a19_one_shot_provider_gate.canonical_request_preflight')
    def test_authorized_mock_sends_exactly_one_post(self, validate):
        validate.return_value=({'action':'run'}, {'request_sha256':EXPECTED_REQUEST_SHA})
        sent=[]
        def mock_post(url, payload, token):
            sent.append(url)
            self.assertEqual(token,'SYNTHETIC-NOT-REAL')
            return {'background_job_id':'synthetic-job-1','status':'processing'}
        with tempfile.TemporaryDirectory() as d:
            ledger=PrivateOneShotLedger(Path(d))
            result=submit_once(b'fake-private-bytes',grant=fake_grant(),
                               token='SYNTHETIC-NOT-REAL',ledger=ledger,
                               isolated_cloud_runner_confirmed=True,
                               approved_provider_post=mock_post)
            self.assertEqual(result['job_id'],'synthetic-job-1')
            self.assertEqual(len(sent),1)
            record=json.loads(next(Path(d).glob('*.json')).read_text('utf-8'))
            self.assertEqual(record['phase'],'SUBMITTED_ONE_POST')
            self.assertEqual(record['retries'],0)
            self.assertNotIn('SYNTHETIC-NOT-REAL',str(record))
            self.assertNotIn('fake-private-bytes',str(record))
            with self.assertRaises(A19Hold):
                submit_once(b'fake-private-bytes',grant=fake_grant(),
                            token='SYNTHETIC-NOT-REAL',ledger=ledger,
                            isolated_cloud_runner_confirmed=True,
                            approved_provider_post=mock_post)
            self.assertEqual(len(sent),1)

    @patch('tools.asset_factory.a19_one_shot_provider_gate.canonical_request_preflight')
    def test_timeout_after_possible_post_is_never_retried(self, validate):
        validate.return_value=({'action':'run'}, {'request_sha256':EXPECTED_REQUEST_SHA})
        calls=[]
        def timeout_post(*args):
            calls.append(1)
            raise TimeoutError('Simulated lost provider response')
        with tempfile.TemporaryDirectory() as d:
            ledger=PrivateOneShotLedger(Path(d))
            with self.assertRaises(A19UnknownSubmission):
                submit_once(b'private',grant=fake_grant(),token='fake',ledger=ledger,
                            isolated_cloud_runner_confirmed=True,
                            approved_provider_post=timeout_post)
            item=json.loads(next(Path(d).glob('*.json')).read_text())
            self.assertEqual(item['phase'],'POST_MAY_HAVE_OCCURRED')
            with self.assertRaises(A19Hold):
                submit_once(b'private',grant=fake_grant(),token='fake',ledger=ledger,
                            isolated_cloud_runner_confirmed=True,
                            approved_provider_post=timeout_post)
            self.assertEqual(len(calls),1)

    @patch('tools.asset_factory.a19_one_shot_provider_gate.canonical_request_preflight')
    def test_no_pc_execution_even_if_approval_flag_present(self, validate):
        validate.return_value=({'action':'run'}, {'request_sha256':EXPECTED_REQUEST_SHA})
        calls=[]
        with tempfile.TemporaryDirectory() as d:
            with self.assertRaises(A19Hold):
                submit_once(b'private',grant=fake_grant(),token='fake',
                            ledger=PrivateOneShotLedger(Path(d)),
                            isolated_cloud_runner_confirmed=False,
                            approved_provider_post=lambda *args:calls.append(1))
            self.assertEqual(calls,[])
            self.assertEqual(list(Path(d).glob('*.json')),[])

    def test_completed_fake_raw_png_frames_format_pass_is_not_art_pass(self):
        images=[{'base64':base64.b64encode(fake_png(i)).decode('ascii')} for i in range(3)]
        raw,qa=verify_completed_raw_frames({'status':'completed','last_response':{'images':images}})
        self.assertEqual(len(raw),3)
        self.assertEqual(qa['art_gate'],'USER_REQUIRED')
        self.assertEqual(qa['native_vx_gate'],'NOT_RUN')
        self.assertFalse(qa['formal_seal'])

    def test_duplicate_raw_images_are_rejected(self):
        p=base64.b64encode(fake_png(0)).decode('ascii')
        images=[{'base64':p}]*3
        with self.assertRaises(ValueError):
            verify_completed_raw_frames({'status':'completed','last_response':{'images':images}})

    def test_not_completed_job_does_not_become_sprite(self):
        with self.assertRaises(A19Hold):
            verify_completed_raw_frames({'status':'processing','last_response':{'images':[]}})

    def test_no_magic_retry_without_private_ledger(self):
        with tempfile.TemporaryDirectory() as d:
            with self.assertRaises(A19Hold):
                PrivateOneShotLedger(Path(d)/'nonexistent')

if __name__ == '__main__':
    unittest.main()
