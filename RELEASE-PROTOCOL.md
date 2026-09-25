# Year View release checks

Use the Xcode archive and export commands in
[release-config/README.md](release-config/README.md) for the macOS direct-download
ZIP. This repository owns its release process and signing configuration.
Credentials and export options must be configured for the release operator's
Apple team and build environment.

After Apple accepts the submission, staple the exported app and create the final
ZIP as documented there. Verify the app extracted from that ZIP, rather than
only checking the source app in the export directory:

```bash
python3 scripts/release/verify-zip.py build/YearView.zip --version <app-version>
```

The check requires macOS, Xcode command-line tools and Python 3. It checks the
YearView.app bundle layout, identifier, version, Developer ID signature,
stapled ticket and Gatekeeper acceptance on a temporary quarantined copy.
It does not modify the export or ZIP, and does not launch the app.

Open the extracted candidate for a native walkthrough. Check calendar permission
handling, year navigation, event display, layout preferences and reopening the
window. Test deep links when relevant to the change; preserve the user's calendar
data. Record source commit, version, ZIP checksum, OS and observed results.
Run the project's existing Xcode tests for application changes.

Upload the final ZIP with its SHA-256 checksum, then download and verify it again.
Keep App Store submissions separate: follow
[Documentation/APP-STORE.md](Documentation/APP-STORE.md) for their signing and
submission requirements. A direct-download ZIP check does not validate an
App Store or iOS build.
