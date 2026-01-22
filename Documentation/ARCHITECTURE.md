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

Services are instantiated by ViewModels, not injected, keeping the architecture simple.

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

Note: the test files exist in the repo, but the Xcode project does not currently include a unit test target for them. They won’t run until they’re added to a test target.

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
