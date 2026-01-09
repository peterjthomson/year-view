# Getting Started with Year View

This guide helps developers set up and run Year View locally.

## Requirements

- **Xcode 15.0+** (required for iOS 17 / macOS 14 SDK)
- **macOS Sonoma 14.0+** (for macOS app development)
- **iOS 17.0+ device or simulator**
- **Apple Developer account** (for device testing and calendar access)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/peterjthomson/year-view.git
cd year-view
```

### 2. Open in Xcode

```bash
open YearView.xcodeproj
```

### 3. Select a Scheme

Choose from the available schemes:
- **YearView** — iOS/iPadOS/macOS multiplatform app
- **YearView Watch App** — watchOS app
- **YearViewWidgetExtension** — Widget extension

### 4. Configure Signing

1. Select the project in the navigator
2. Select your target
3. Under "Signing & Capabilities", select your team
4. Xcode will automatically manage provisioning profiles

### 5. Build and Run

Press `Cmd+R` or click the Run button.

## Project Structure

```
year-view/
├── YearView.xcodeproj/     # Xcode project
├── YearView/               # Main app source
├── YearView Watch App/     # watchOS app source
├── YearViewWidgetExtension/# Widget source
├── YearViewTests/          # Unit tests
├── Documentation/          # Architecture & API docs
├── README.md
├── MARKETING.md            # App Store & marketing copy
└── LICENSE
```

## Running Tests

### In Xcode

1. Select the YearView scheme
2. Press `Cmd+U` or go to Product → Test

> Note: `YearViewTests/` currently contains unit test files, but the Xcode project does not define a unit test target for them yet. Until a test target is created and the files are added to it, `Cmd+U` / CI test steps will not run these tests.

### From Command Line

```bash
xcodebuild test \
  -project YearView.xcodeproj \
  -scheme YearView \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Calendar Access

Year View requires calendar access to function. On first launch:

1. The app will request calendar permission
2. Grant "Full Access" when prompted
3. If denied, direct users to Settings → Privacy → Calendars

### Testing with Sample Data

For development without real calendar data, you can:

1. Create test events in the iOS Simulator's Calendar app
2. Use the preview data in `CalendarEvent.preview` and `CalendarSource.previewList`

## Google Calendar Setup (Optional)

To enable direct Google Calendar integration:

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project
3. Enable the Google Calendar API

### 2. Create OAuth Credentials

1. Go to APIs & Services → Credentials
2. Create OAuth 2.0 Client ID
3. Select "iOS" as application type
4. Add your bundle identifier

### 3. Configure the App

Add to your `Info.plist`:

```xml
<key>GOOGLE_CLIENT_ID</key>
<string>your-client-id.apps.googleusercontent.com</string>
<key>GOOGLE_REDIRECT_URI</key>
<string>com.googleusercontent.apps.your-client-id:/oauth2callback</string>
```

Add URL scheme to handle OAuth callback:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.your-client-id</string>
        </array>
    </dict>
</array>
```

## Widgets

### iOS Widgets

Widgets require an App Group for data sharing:

1. Add App Group capability to main app and widget extension
2. Use the same group identifier (e.g., `group.com.yearview.app`)
3. Share data via `UserDefaults(suiteName:)`

### macOS Widgets

macOS widgets work similarly but use a different container:

1. Add App Group capability
2. Ensure both app and widget use the same group

## watchOS

The watch app is a standalone WatchKit app:

1. Requires separate provisioning profile
2. Calendar access requested independently
3. Uses WatchConnectivity for iPhone communication (future enhancement)

## Troubleshooting

### "Calendar access denied"

1. Go to Settings → Privacy & Security → Calendars
2. Find Year View and enable access
3. Restart the app

### Widgets not appearing

1. Ensure widget extension builds successfully
2. Add the widget from the widget gallery
3. Check that App Groups are configured correctly

### Build errors with @Observable

Ensure you're using:
- Xcode 15.0 or later
- iOS 17.0 / macOS 14.0 deployment target
- Swift 5.9 or later

### Google Sign-In not working

1. Verify client ID is correct
2. Check URL scheme is registered
3. Ensure redirect URI matches exactly

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for design patterns
- Read [API.md](API.md) for type reference
- Check [MARKETING.md](../MARKETING.md) for App Store assets

## Support

For issues and feature requests, please open a GitHub issue.
