# Year View Architecture

This document describes the architecture and design patterns used in Year View.

## Overview

Year View is built using SwiftUI with a modern, Observable-based architecture. The app follows Apple's recommended patterns for multiplatform development, supporting iOS, iPadOS, and macOS from a single codebase.

## Technology Choices

### Why Standard SwiftUI (Not TCA)

Year View intentionally uses standard SwiftUI with `@Observable` instead of The Composable Architecture (TCA) because:

1. **Read-only visualization** - The app primarily displays calendar data without complex state mutations
2. **Simple state flow** - Calendar data flows one direction: EventKit → ViewModel → View
3. **Lower learning curve** - Standard SwiftUI patterns are familiar to all iOS developers
4. **Reduced dependencies** - No external architecture frameworks required
5. **Apple ecosystem alignment** - Follows patterns from Apple's own sample apps (Food Truck)

### Minimum OS Requirements

- iOS 17.0+
- iPadOS 17.0+
- macOS 14.0 (Sonoma)+

These requirements enable use of:
- `@Observable` macro (replaces `ObservableObject`)
- Modern SwiftUI navigation APIs
- Improved EventKit APIs

## Project Structure

- `YearViewApp.swift` — App entry point, scene configuration
- `ContentView.swift` — Root view with navigation
- `Models/` — Calendar data models and (future) sets
- `ViewModels/` — App state and view models
- `Views/` — SwiftUI views and layouts
- `Services/` — EventKit, deep links, and caching
- `Utilities/` — Date/color helpers and haptics
- `Platform/` — macOS‑specific UI and commands

## Data Flow
- Apple Calendar data flows through `EventKitService` into `CalendarViewModel`.
- Google Calendar data can flow through `GoogleCalendarService` (experimental).
- `CalendarViewModel` aggregates and filters events for UI consumption.
- `YearView`, `DayDetailView`, and `CalendarSelectionView` consume view model state.

## Key Patterns

### @Observable ViewModels

ViewModels use the `@Observable` macro to drive SwiftUI updates. Views access
the shared models via environment injection from `YearViewApp`.

### Service Layer

Services encapsulate external dependencies:

- **EventKitService** - Wraps EKEventStore for calendar access
- **GoogleCalendarService** - Handles OAuth and API calls
- **CalendarDeepLinkService** - Opens native calendar apps
- **CalendarCacheService** - Persists user preferences

ViewModels instantiate their services. `AppSettings` accepts a cache and
`CalendarCacheService` accepts a `UserDefaults` instance so preference tests can
use an isolated suite without changing the user's settings.

### Event Layout

`CalendarEvent.displayedDayInterval(calendar:)` defines the half-open range of
occupied days. All-day end dates and timed events ending exactly at midnight
exclude the following day. `displayedDayOffsets(in:calendar:)` clips that range
to a visible month or week using calendar arithmetic, including across DST.

The Months and Year layouts allocate overlapping events to separate lanes.
`Views/EventBarMetrics.swift` contains shared bar sizing and capacity rules,
plus the overflow indicator. When events exceed capacity, layouts reserve space
for a per-day hidden-event count; very compact cells display a dot. Day selection
still opens the complete event list.

### Platform Abstraction

Platform-specific code is isolated under `Platform/` and gated with `#if os(...)`
checks so iOS and macOS behaviors stay cleanly separated.

## Calendar Integration

### Apple Calendar (EventKit)

Primary integration path. Automatically includes:
- iCloud calendars
- Exchange/Outlook (via Apple Calendar)
- Google (via Apple Calendar)
- CalDAV calendars
- Subscribed calendars
- Shared/delegated calendars

### Google Calendar (Direct API)

Optional direct integration for users who prefer it:
- OAuth 2.0 with Keychain token storage
- Read-only scopes (`calendar.readonly`, `calendar.events.readonly`)

Status: the repo includes a `GoogleCalendarService` prototype, but it is not fully productized (UI wiring, error states, App Review scope decisions, etc.). Treat this as **planned / experimental** until it’s exercised end-to-end.

### Deep Linking

All event creation/editing defers to native apps:

| Action | Apple Calendar | Google Calendar |
|--------|----------------|-----------------|
| View Day | `calshow:{timestamp}` | `calendar.google.com/day` |
| Create Event | `calshow:` | `calendar.google.com/render` |

## Testing Strategy

### Unit Tests

Located in `YearViewTests/`:

- **Model tests** - CalendarEvent, CalendarSource properties and equality
- **ViewModel tests** - State management, computed properties
- **Service tests** - Caching, date utilities
- **Utility tests** - Date calculations, color conversions

The `YearViewTests` target runs through the shared `YearView` scheme locally and
in CI. Calendar day-range tests cover exclusive all-day end dates, daylight
saving transitions, midnight boundaries, and cross-month clipping.
Event-display regressions also cover overlapping lanes, saved font sizes, and
overflow in small cells. Focused macOS `ImageRenderer` checks verify visible bars
and indicators and attach images to the Xcode test results. These check rendering
with synthetic events, not live EventKit ingestion.

### UI Tests

Views include SwiftUI previews for visual testing during development.

### Manual Testing

- Calendar permission flows
- Deep link behavior
- Accessibility (VoiceOver, Dynamic Type)

## Accessibility

- VoiceOver labels for core controls and event rows
- Dynamic Type support for most text; dense grids use fixed sizes
- Reduce Motion respected for standard animations; some custom effects may not yet adapt
- Keyboard navigation on macOS in standard lists and toolbars
- Contrast designed for light/dark modes with user-adjustable colors

## Performance Considerations

- **Lazy loading** - `LazyVGrid` and `LazyHStack` for month grids
- **Event caching** - Events loaded once per year, filtered in memory
- **Image-free** - Uses SF Symbols exclusively
- **Minimal re-renders** - `@Observable` provides fine-grained updates

## Future Considerations

Potential enhancements (not in v1.0):

- SwiftData for calendar set persistence
- CloudKit sync for preferences
- Live Activities for upcoming events
- Siri Shortcuts integration
- Widgets (iOS/macOS)
- Apple Watch app
