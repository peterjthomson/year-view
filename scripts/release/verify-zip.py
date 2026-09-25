"""Verify the final Year View direct-download ZIP without changing its contents."""
import argparse
from pathlib import Path, PurePosixPath
import plistlib
import subprocess
import tempfile
import zipfile


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True)


def check_layout(path):
    with zipfile.ZipFile(path) as archive:
        names = set(archive.namelist())
    for name in names:
        if name.startswith('/') or '..' in PurePosixPath(name).parts:
            raise ValueError(f'unsafe archive path: {name}')
    apps = {name.split('/')[0] for name in names if name.split('/')[0].endswith('.app')}
    if apps != {'YearView.app'} or 'YearView.app/Contents/Info.plist' not in names:
        raise ValueError('expected one YearView.app with Contents/Info.plist at the ZIP root')
    if 'YearView.app/YearView.app/Contents/Info.plist' in names:
        raise ValueError('nested duplicate YearView.app')


def verify(path, version):
    check_layout(path)
    with tempfile.TemporaryDirectory(prefix='yearview-verify-') as temporary:
        run('ditto', '-x', '-k', str(path.resolve()), temporary)
        app = Path(temporary) / 'YearView.app'
        with (app / 'Contents/Info.plist').open('rb') as stream:
            info = plistlib.load(stream)
        if info.get('CFBundleIdentifier') != 'com.yearview.app':
            raise ValueError('unexpected bundle identifier')
        if info.get('CFBundleShortVersionString') != version:
            raise ValueError('unexpected app version')
        run('xattr', '-w', 'com.apple.quarantine', '0081;00000000;YearViewVerification;', str(app))
        run('codesign', '--verify', '--deep', '--strict', str(app))
        signature = run('codesign', '-dv', '--verbose=2', str(app)).stderr
        if 'Authority=Developer ID Application:' not in signature:
            raise ValueError('expected Developer ID Application signing')
        run('xcrun', 'stapler', 'validate', str(app))
        run('spctl', '--assess', '--type', 'execute', '--verbose=2', str(app))
    print('PASS: ZIP layout, app identity/version, signature, stapled ticket and Gatekeeper.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('zip', type=Path)
    parser.add_argument('--version', required=True, help='expected CFBundleShortVersionString')
    args = parser.parse_args()
    try:
        verify(args.zip, args.version)
    except (ValueError, OSError, zipfile.BadZipFile, plistlib.InvalidFileException,
            subprocess.CalledProcessError) as error:
        parser.exit(1, f'verify: {error}\n{getattr(error, "stderr", "") or ""}')
