import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

spec = importlib.util.spec_from_file_location('verify_zip', Path(__file__).with_name('verify-zip.py'))
verify_zip = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify_zip)


class ReleaseZipTests(unittest.TestCase):
    def test_final_bundle_layout(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / 'candidate.zip'
            cases = [
                (['YearView.app/Contents/Info.plist'], True),
                (['YearView.app/YearView.app/Contents/Info.plist'], False),
                (['YearView.app/Contents/Info.plist', 'Other.app/Contents/Info.plist'], False),
                (['YearView.app/Contents/Info.plist', '../outside'], False),
            ]
            for names, valid in cases:
                with self.subTest(names=names):
                    with zipfile.ZipFile(path, 'w') as archive:
                        for name in names:
                            archive.writestr(name, b'fixture')
                    if valid:
                        verify_zip.check_layout(path)
                    else:
                        with self.assertRaises(ValueError):
                            verify_zip.check_layout(path)

    def test_missing_zip_fails_before_mac_commands(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(verify_zip, 'run') as run:
            with self.assertRaises(FileNotFoundError):
                verify_zip.verify(Path(temporary) / 'missing.zip', '1.4')
            run.assert_not_called()


if __name__ == '__main__':
    unittest.main()
