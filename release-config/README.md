# Release configuration

These export options were previously only in `build/`, which is gitignored — so
a release could not be reproduced from a clean clone. They are configuration,
not build output, and belong in version control.

- `ExportOptions-DirectDownload.plist` — Developer ID export for the GitHub
  download (`method: developer-id`, automatic signing)
- `ExportOptions-AppStore.plist` — App Store export

Release procedure is the shared release protocol in `../RELEASE-PROTOCOL.md`:

```bash
xcodebuild archive -project YearView.xcodeproj -scheme YearView \
  -destination 'generic/platform=macOS' -archivePath build/YearView-GitHub.xcarchive

xcodebuild -exportArchive -archivePath build/YearView-GitHub.xcarchive \
  -exportOptionsPlist release-config/ExportOptions-DirectDownload.plist \
  -exportPath build/github-export

ditto -c -k --keepParent "build/github-export/YearView.app" build/YearView-submission.zip

# Submit and collect status without waiting on Apple.
./scripts/release/notarize.sh submit --app build/github-export/YearView.app build/YearView-submission.zip
./scripts/release/notarize.sh status
# After the status is Accepted, staple the app (ZIP files cannot be stapled).
./scripts/release/notarize.sh staple

# Repackage the exported app with its ticket before publishing.
ditto -c -k --keepParent "build/github-export/YearView.app" build/YearView.zip
```

Verify the final ZIP, including the extracted app, then complete the native
walkthrough in `scripts/release/LOCAL-COMPUTER-USE.md`:

```bash
./scripts/release/verify-mac-artifact.sh --zip build/YearView.zip \
  --bundle-id com.yearview.app
```
