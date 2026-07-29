# Release configuration

These export options were previously only in `build/`, which is gitignored — so
a release could not be reproduced from a clean clone. They are configuration,
not build output, and belong in version control.

- `ExportOptions-DirectDownload.plist` — Developer ID export for the GitHub
  download (`method: developer-id`, automatic signing)
- `ExportOptions-AppStore.plist` — App Store export

Release procedure is the shared five-stage protocol in `../RELEASE-PROTOCOL.md`:

```bash
xcodebuild archive -project YearView.xcodeproj -scheme YearView \
  -destination 'generic/platform=macOS' -archivePath build/YearView-GitHub.xcarchive

xcodebuild -exportArchive -archivePath build/YearView-GitHub.xcarchive \
  -exportOptionsPlist release-config/ExportOptions-DirectDownload.plist \
  -exportPath build/github-export

ditto -c -k --keepParent "build/github-export/YearView.app" build/YearView.zip

# Stages 2-4: submit, collect whenever, staple. Never blocks on Apple.
./scripts/release/notarize.sh submit build/YearView.zip
./scripts/release/notarize.sh status
./scripts/release/notarize.sh staple
```

Note `verify-mac-artifact.sh` is DMG-oriented; Year View ships a zip, so verify
the exported app directly:

```bash
spctl --assess --type execute -v build/github-export/YearView.app
xcrun stapler validate build/github-export/YearView.app
```
