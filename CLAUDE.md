# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Year View is a **multiplatform (iOS/iPadOS/macOS) year-at-a-glance calendar companion** built with SwiftUI. It's intentionally **read-only** and deep-links to native calendar apps (Apple Calendar, Google Calendar) for all event creation/editing.

**Key characteristics:**
- Minimum deployment: iOS 17+ / macOS 14+ (requires `@Observable` macro)
- Single Xcode project with unified multiplatform target
- No external dependencies or architecture frameworks (no TCA, no SPM packages)
- Uses standard SwiftUI with `@Observable` for state management

## Development Commands

### Building

Open and build in Xcode:
```bash
open YearView.xcodeproj
# Then press Cmd+R to build and run
```

Build from command line:
```bash
# iOS simulator build
xcodebuild build \
  -project YearView.xcodeproj \
  -target YearView \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug

# macOS build
xcodebuild build \
  -project YearView.xcodeproj \
  -target YearView \
  -sdk macosx \
  -destination 'platform=macOS' \
  -configuration Debug
```

### Testing

```bash
# Run tests in Xcode: Cmd+U

# Run tests from command line:
xcodebuild test \
  -project YearView.xcodeproj \
  -scheme YearView \
  -destination 'platform=macOS'
```

### CI

GitHub Actions builds both iOS (simulator) and macOS targets on every push/PR via `.github/workflows/ci.yml`.

## Architecture

### MVVM with @Observable

The app uses **standard SwiftUI MVVM** with Apple's `@Observable` macro instead of The Composable Architecture (TCA). This decision reflects the app's read-only nature and simple unidirectional data flow.

**Key ViewModels:**
- **CalendarViewModel** (`ViewModels/CalendarViewModel.swift`) - Main app state, manages calendars, events, year navigation, filtering. Injected via `.environment()` and accessed with `@Environment`.
- **YearViewModel** (`ViewModels/YearViewModel.swift`) - Display configuration for year layouts (monthRows, bigYear, standardGrid, continuousRow, verticalList).
- **DayViewModel** (`ViewModels/DayViewModel.swift`) - State for day detail view, event sorting, time formatting.

### Data Flow

```
EventKit (Apple Calendar) → EventKitService → CalendarViewModel → Views
Google Calendar API → GoogleCalendarService → CalendarViewModel → Views
```

- ViewModels own and instantiate services; AppSettings accepts a cache and CalendarCacheService accepts isolated UserDefaults for preference tests
- Services encapsulate external dependencies (EventKit, Google API, UserDefaults)
- State changes in `@Observable` ViewModels automatically trigger SwiftUI updates
- All calendar data is read-only; mutations defer to native apps via deep links

### Project Structure

```
YearView/
├── YearViewApp.swift           # App entry, @State ViewModels, platform-specific scenes
├── ContentView.swift           # Root navigation view
├── Models/
│   ├── CalendarEvent.swift     # Event model (from EKEvent)
│   ├── CalendarSource.swift    # Calendar model with SourceType enum
│   └── CalendarSet.swift       # User-defined calendar groups (SwiftData, experimental)
├── ViewModels/
│   ├── CalendarViewModel.swift # Main state: calendars, events, displayedYear, filtering
│   ├── YearViewModel.swift     # Layout config: layoutStyle, showWeekends, zoomLevel
│   └── DayViewModel.swift      # Day detail state: events, formatting, deep links
├── Views/
│   ├── YearView.swift          # Core year visualization
│   ├── MonthGridView.swift     # Month grid component
│   ├── DayCell.swift           # Individual day cell with event indicators
│   ├── DayDetailView.swift     # Day popover/sheet
│   ├── EventRow.swift          # Event list item
│   ├── CalendarSelectionView.swift
│   ├── YearPickerView.swift
│   ├── SearchView.swift
│   └── Layouts/                # Year layout strategies
│       ├── YearMonthRowLayout.swift    # Default: month rows
│       ├── BigYearLayout.swift         # Continuous week rows
│       ├── StandardGridLayout.swift    # 4×3 grid
│       ├── ContinuousRowLayout.swift   # Horizontal scroll
│       ├── VerticalListLayout.swift    # Vertical months
│       └── PowerLawLayout.swift        # Today + week + month + upcoming
├── Services/
│   ├── EventKitService.swift          # Apple Calendar (primary integration)
│   ├── GoogleCalendarService.swift    # Google API (experimental, not fully productized)
│   ├── CalendarDeepLinkService.swift  # Native app deep links (calshow:, etc.)
│   └── CalendarCacheService.swift     # UserDefaults persistence
├── Utilities/
│   ├── DateUtilities.swift     # Date extensions: startOfDay, isToday, adding(days:), etc.
│   ├── ColorUtilities.swift    # Color extensions: hex parsing, luminance, contrast
│   └── HapticFeedback.swift    # iOS haptics (no-op on macOS)
└── Platform/
    ├── MenuBarView.swift       # macOS menu bar extra (wrapped in #if os(macOS))
    └── MacCommands.swift       # macOS keyboard shortcuts
```

### Platform Abstraction

Platform-specific code uses compile-time checks:
```swift
#if os(macOS)
struct MenuBarView: View { ... }
#endif

#if os(iOS)
HapticFeedback.light()
#endif
```

The main app target builds for all platforms (iOS/iPadOS/macOS) from the same codebase.

## Calendar Integration

### Apple Calendar (EventKit) - Primary

- Wraps `EKEventStore` in `EventKitService`
- Automatically includes: iCloud, Exchange, Google (via Apple Calendar), CalDAV, subscribed calendars
- Requires calendar permission prompt on first launch
- Events loaded once per year (`displayedYear` change triggers reload)
- Deep links use `calshow:` URL scheme for viewing/creating events

### Google Calendar (Direct API) - Experimental

`GoogleCalendarService` exists but is **not fully productized**. It's a prototype for optional direct Google Calendar API integration. Missing:
- Complete UI wiring
- Error state handling
- App Review scope decisions
- OAuth flow finalization

Treat as planned/experimental until exercised end-to-end.

## Key Patterns and Conventions

### @Observable State Management

ViewModels use `@Observable` macro (requires iOS 17+):
```swift
@Observable
final class CalendarViewModel {
    var calendars: [CalendarSource] = []
    var events: [CalendarEvent] = []
    var displayedYear: Int { didSet { /* reload events */ } }

    var filteredEvents: [CalendarEvent] {
        events.filter { enabledCalendarIDs.contains($0.calendarID) }
    }
}
```

Views receive ViewModels via environment:
```swift
struct YearView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
}
```

Injected in `YearViewApp.swift`:
```swift
@State private var calendarViewModel = CalendarViewModel()

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(calendarViewModel)
    }
}
```

### Year Change Performance

When `displayedYear` changes, `CalendarViewModel` loads a full year of events. This is efficient because:
- Events cached in memory for the year
- Filtering happens via computed properties (`filteredEvents`)
- Lazy SwiftUI grids prevent full re-renders
- No image assets (SF Symbols only)

### Read-Only Philosophy

No event creation/editing in Year View. All mutations defer to native apps via `CalendarDeepLinkService`:
- `openCalendar(at:)` - Open Apple Calendar to date
- `openEvent(_:)` - Open event in Calendar app
- `createEvent(on:)` - Create event via `calshow:` deep link
- `openGoogleCalendar(at:)` - Open Google Calendar web UI

### Multi-Day and All-Day Events

`CalendarEvent.displayedDayInterval(calendar:)` is the shared source of occupied
days. `CalendarViewModel` indexes these days for `events(for:)`, and layouts use
`displayedDayOffsets(in:calendar:)` to clip events to a visible month or week.
- All-day end dates are exclusive.
- Timed events ending exactly at midnight do not occupy the following day.
- Calendar-day arithmetic preserves spans across DST and month boundaries.
- Overlapping bars use separate lanes; shared EventBarMetrics reserves space for
  overflow counts when all lanes do not fit.

### Calendar Preferences Persistence

`CalendarCacheService` stores preferences in `UserDefaults`:
- Enabled calendar IDs (`saveEnabledCalendarIDs`, `loadEnabledCalendarIDs`)
- Layout style (`saveSelectedLayout`, `loadSelectedLayout`)
- Show weekends/week numbers
- Event text size (1–24 pt, default 10; 1 pt draws thin lines in Months/Year)
- Last viewed year (saved but **not** restored on launch—app always starts on current year)

### Accessibility

- Full VoiceOver labels on all interactive elements
- Dynamic Type support for all text
- Respects Reduce Motion for animations
- Keyboard navigation on macOS (`MacCommands.swift`)
- Sufficient color contrast (light/dark modes)

## Testing Notes

- `YearViewTests` is part of the shared `YearView` scheme and runs locally and in CI
- Tests cover: models, ViewModels, services, date utilities, color utilities
- Event-display tests cover layout and preference behavior, with focused macOS rendered-image checks for visible bars and overflow
- SwiftUI previews used for visual testing during development
- Manual testing required for: calendar permissions, deep links, VoiceOver

## Common Tasks

### Adding a New Layout Style

1. Create layout view in `Views/Layouts/` (e.g., `MyLayout.swift`)
2. Add case to `YearLayoutStyle` enum in `YearViewModel.swift`
3. Add switch case in `YearView.swift` to render the layout
4. Add icon and description to `YearLayoutStyle` computed properties

### Adding Calendar Permission Handling

Calendar permission is requested in `CalendarViewModel.requestAccess()`. If denied:
- `hasCalendarAccess` remains `false`
- `errorMessage` set to prompt user to Settings
- No events load

Prompt user to: Settings → Privacy & Security → Calendars → Year View.

### Platform-Specific Feature

Wrap code in `#if os()`:
```swift
#if os(macOS)
// macOS-only code
#endif

#if os(iOS)
// iOS/iPadOS-only code
#endif
```

Ensure shared code remains platform-agnostic.

## Documentation

See `Documentation/` for detailed reference:
- `ARCHITECTURE.md` - Design patterns, technology choices, data flow
- `API.md` - Type reference for models, ViewModels, services, utilities
- `GETTING_STARTED.md` - Setup, Google Calendar OAuth, troubleshooting
- `APP-STORE.md` - App Store submission details
- `LAUNCH.md` - Release checklist

## Release verification

Follow `RELEASE-PROTOCOL.md` and `scripts/release/LOCAL-COMPUTER-USE.md`.
Use the final extracted signed package for the native walkthrough. Run the
shared script checks with `python3 -m unittest discover -s scripts/release -p "test_*.py"`.
