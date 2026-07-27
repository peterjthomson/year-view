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
├── YearViewTests/          # Unit tests
├── Documentation/          # Architecture & API docs
├── README.md
└── LICENSE
```

## Running Tests

### In Xcode

1. Select the YearView scheme
2. Press `Cmd+U` or go to Product → Test

### From Command Line

```bash
xcodebuild test \
  -project YearView.xcodeproj \
  -scheme YearView \
  -destination 'platform=macOS'
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

## Google Calendar Prototype

The repository contains an experimental direct Google Calendar service, but it
is not wired into the shipping UI or supported as a release feature. Calendars
from Google accounts configured in Apple Calendar are supported through
EventKit.

## Troubleshooting

### "Calendar access denied"

1. Go to Settings → Privacy & Security → Calendars
2. Find Year View and enable access
3. Restart the app

### Build errors with @Observable

Ensure you're using:
- Xcode 15.0 or later
- iOS 17.0 / macOS 14.0 deployment target
- Swift 5.9 or later

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for design patterns
- Read [API.md](API.md) for type reference
- Check [MARKETING.md](MARKETING.md) for App Store assets

## Support

For issues and feature requests, please open a GitHub issue.
