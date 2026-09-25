# Release configuration

These export options were previously only in `build/`, which is gitignored — so
a release could not be reproduced from a clean clone. They are configuration,
not build output, and belong in version control.

- `ExportOptions-DirectDownload.plist` — Developer ID export for the GitHub
  download (`method: developer-id`, automatic signing)
- `ExportOptions-AppStore.plist` — App Store export

Archive, export and notarize the direct-download candidate:

```bash
xcodebuild archive -project YearView.xcodeproj -scheme YearView \
  -destination 'generic/platform=macOS' -archivePath build/YearView-GitHub.xcarchive

xcodebuild -exportArchive -archivePath build/YearView-GitHub.xcarchive \
  -exportOptionsPlist release-config/ExportOptions-DirectDownload.plist \
  -exportPath build/github-export

ditto -c -k --keepParent "build/github-export/YearView.app" build/YearView.zip

# Submit and collect status without waiting on Apple.
./scripts/release/notarize.sh submit build/YearView.zip
./scripts/release/notarize.sh status
# After the status is Accepted, staple the app (ZIP files cannot be stapled).
xcrun stapler staple build/github-export/YearView.app
xcrun stapler validate build/github-export/YearView.app

# Repackage the exported app with its ticket before publishing.
ditto -c -k --keepParent "build/github-export/YearView.app" build/YearView.zip
```

Verify the final ZIP, including the app extracted from it:

```bash
python3 scripts/release/verify-zip.py build/YearView.zip --version <app-version>
```

Complete the native walkthrough in [RELEASE-PROTOCOL.md](../RELEASE-PROTOCOL.md)
before uploading. The ZIP verifier requires macOS, Xcode command-line tools and
Python 3; it does not change the Xcode build or notarization steps above.
