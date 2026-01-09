# Launch Checklist (Pre-1.0)

This doc is focused on shipping **Year View** (iOS + macOS + watchOS + widgets) from this repo, with a bias toward **P0 launch blockers** and “things App Review will ask about”.

## P0: Before you touch App Store Connect

- **Build every target locally**
  - iOS/iPadOS app (`YearView`)
  - macOS app (`YearView`)
  - Widget extension (`YearViewWidgetExtension`)
  - watchOS app (`YearView Watch App`)
- **Verify calendar permission UX**
  - Fresh install (notDetermined → prompt)
  - Denied path (what does user see?)
  - “Limited / writeOnly” edge cases on iOS 17+ (you currently request full access)
- **Decide what “Google Calendar (Direct API)” means for v1**
  - If it’s not user-facing and not tested end-to-end, remove it or feature-flag it off for 1.0.
- **Decide whether widgets are “eventful” at launch**
  - Widgets can’t request permission. They will show empty until the main app has been opened and granted Calendar access.

## P0: App Store Connect requirements

- **Privacy Policy URL**
  - Even if you don’t collect data, you’ll want a real privacy policy URL ready (and the in-app “Privacy Policy” menu item should point to it).
- **App Privacy “nutrition label”**
  - If you truly collect nothing, select “Data Not Collected”.
  - Calendar access still requires clear explanation; it’s local, but it is still user data.
- **Required usage strings**
  - iOS: `NSCalendarsUsageDescription` (already present in `YearView/Info.plist`)
- **Screenshots**
  - iPhone, iPad, macOS, Apple Watch, widgets (if you ship them)

## P0: Distribution mechanics

### iOS / iPadOS

- **Archive**: Product → Archive (iOS device destination)
- **Upload**: Distribute App → App Store Connect → Upload
- **TestFlight**: create an internal testing group first, then external

### macOS

Decide whether you are shipping:
- **Mac App Store** (MAS) build, or
- **Developer ID notarized** build, or both.

You already have sandbox entitlements in `YearView/YearView.entitlements` including calendar and network client.

### Widgets

- Confirm widget bundle identifier + provisioning
- Confirm widgets load with and without Calendar permission
- Confirm widget timelines refresh as expected

### watchOS

- Confirm the watch app compiles + runs on a watchOS simulator/device
- Confirm the watch app behavior when calendar data is unavailable (common case)

## P1: Release hardening

- **Crash-free “Help / Feedback / Privacy Policy” links**
- **Accessibility pass** (VoiceOver labels, Dynamic Type, contrast)
- **Performance sanity** (year view with thousands of events)
- **CI builds** (at least build all targets on macOS runners)

