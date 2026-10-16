#!/usr/bin/env python3
"""Read-only smoke check using saved macOS credentials; output contains counts only."""
import json
import pathlib
import plistlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]

def keychain(key, optional=False):
    result = subprocess.run(
        ['security', 'find-generic-password', '-s', 'com.SilverMarcs.Birdie', '-a', key, '-w'],
        capture_output=True, text=True, timeout=60,
    )
    if result.returncode:
        if optional and result.returncode == 44:
            return None
        raise RuntimeError('Saved session is unavailable; check Keychain access.')
    return result.stdout.strip()

try:
    saved = keychain('x.session', optional=True)
    if saved:
        credentials = json.loads(saved)
    else:
        preferences = pathlib.Path.home() / 'Library/Containers/com.SilverMarcs.SwiftX/Data/Library/Preferences/com.SilverMarcs.SwiftX.plist'
        user_agent = plistlib.loads(preferences.read_bytes()).get('x.userAgent', '') if preferences.exists() else ''
        credentials = {'cookie': keychain('x.cookieHeader'), 'authorization': keychain('x.authorizationBearer'), 'userAgent': user_agent}
    sources = [p for p in (root / 'Birdie/Models').glob('*.swift') if not p.name.startswith('Navigation')]
    sources += list((root / 'Birdie/Services').glob('*.swift')) + list((root / 'Birdie/Services/X').glob('*.swift'))
    sources += [root / 'Birdie/Utils/FormatExtensions.swift', root / 'Scripts/VerifyLive.swift']
    with tempfile.TemporaryDirectory(prefix='birdie-live-') as temporary:
        executable = str(pathlib.Path(temporary) / 'verify-live')
        subprocess.run(['xcrun', 'swiftc', '-swift-version', '6', '-parse-as-library', *map(str, sources), '-o', executable], check=True)
        subprocess.run([executable, *sys.argv[1:]], input=json.dumps(credentials), text=True, check=True, timeout=180)
except (RuntimeError, subprocess.SubprocessError, OSError, ValueError):
    print('Live check could not complete. Check Keychain access, build output, and network availability.', file=sys.stderr)
    sys.exit(1)
