# Year View Architecture

This document describes the architecture and design patterns used in Year View.

## Overview

Year View is built using SwiftUI with a modern, Observable-based architecture. The app follows Apple's recommended patterns for multiplatform development, supporting iOS, iPadOS, macOS, and watchOS from a single codebase.

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
- watchOS 10.0+

These requirements enable use of:
- `@Observable` macro (replaces `ObservableObject`)
- Modern SwiftUI navigation APIs
- Latest WidgetKit features
- Improved EventKit APIs

## Project Structure

```
YearView/
├── YearViewApp.swift          # App entry point, scene configuration
├── ContentView.swift          # Root view with navigation
├── Models/
│   ├── CalendarEvent.swift    # Event data model
│   ├── CalendarSource.swift   # Calendar/source data model
│   └── CalendarSet.swift      # User-defined calendar groups
├── ViewModels/
│   ├── CalendarViewModel.swift # Main app state
│   ├── YearViewModel.swift     # Year view configuration
│   └── DayViewModel.swift      # Day detail state
├── Views/
│   ├── YearView.swift         # Core year visualization
│   ├── MonthGridView.swift    # Month grid component
│   ├── DayCell.swift          # Individual day cell
│   ├── DayDetailView.swift    # Day popover/sheet
│   ├── EventRow.swift         # Event list item
│   ├── CalendarSelectionView.swift
│   ├── YearPickerView.swift
│   ├── SearchView.swift
│   └── Layouts/
│       ├── StandardGridLayout.swift    # 4×3 grid
│       ├── ContinuousRowLayout.swift   # Horizontal scroll
│       └── VerticalListLayout.swift    # Vertical months
├── Services/
│   ├── EventKitService.swift          # Apple Calendar integration
│   ├── GoogleCalendarService.swift    # Google Calendar API
│   ├── CalendarDeepLinkService.swift  # Native app deep links
│   └── CalendarCacheService.swift     # UserDefaults persistence
├── Utilities/
│   ├── DateUtilities.swift    # Date helpers
│   ├── ColorUtilities.swift   # Color helpers
│   └── HapticFeedback.swift   # Haptic feedback (iOS)
└── Platform/
    ├── MenuBarView.swift      # macOS menu bar widget
    └── MacCommands.swift      # macOS keyboard shortcuts
```

## Data Flow

```
┌─────────────────┐     ┌─────────────────┐
│   EventKit      │────▶│  EventKitService │
│ (Apple Calendar)│     └────────┬────────┘
└─────────────────┘              │
                                 ▼
┌─────────────────┐     ┌─────────────────┐
│ Google Calendar │────▶│GoogleCalService  │
│      API        │     └────────┬────────┘
└─────────────────┘              │
                                 ▼
                        ┌─────────────────┐
                        │CalendarViewModel │ ◀── @Observable
                        │                 │
                        │ • calendars     │
                        │ • events        │
                        │ • displayedYear │
                        └────────┬────────┘
                                 │
            ┌────────────────────┼────────────────────┐
            ▼                    ▼                    ▼
    ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
    │   YearView    │   │ DayDetailView │   │CalendarSelect │
    └───────────────┘   └───────────────┘   └───────────────┘
```

## Key Patterns

### @Observable ViewModels

ViewModels use the `@Observable` macro for automatic UI updates:

```swift
@Observable
final class CalendarViewModel {
    var calendars: [CalendarSource] = []
    var events: [CalendarEvent] = []
    var displayedYear: Int

    // Computed properties automatically trigger updates
    var filteredEvents: [CalendarEvent] {
        events.filter { enabledCalendarIDs.contains($0.calendarID) }
    }
}
```

Views receive the ViewModel via environment:

```swift
struct YearView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
}
```

### Service Layer

Services encapsulate external dependencies:

- **EventKitService** - Wraps EKEventStore for calendar access
- **GoogleCalendarService** - Handles OAuth and API calls
- **CalendarDeepLinkService** - Opens native calendar apps
- **CalendarCacheService** - Persists user preferences

Services are instantiated by ViewModels, not injected, keeping the architecture simple.

### Platform Abstraction

Platform-specific code is isolated using `#if os()`:

```swift
#if os(macOS)
struct MenuBarView: View { ... }
#endif

#if os(iOS)
HapticFeedback.light()
#endif
```

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
- Widget appearance
- Accessibility (VoiceOver, Dynamic Type)

## Accessibility

- Full VoiceOver support with descriptive labels
- Dynamic Type for all text
- Respects Reduce Motion system setting
- Keyboard navigation on macOS
- Sufficient color contrast in both light/dark modes

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
- Widget configuration intents
