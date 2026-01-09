# Year View API Reference

This document provides API reference for Year View's public types and services.

## Models

### CalendarEvent

Represents a calendar event from any source.

```swift
struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarID: String
    let calendarColor: Color
    let calendarTitle: String
    let location: String?
    let notes: String?
    let url: URL?
    let hasVideoCall: Bool
    let videoCallURL: URL?
}
```

#### Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `isMultiDay` | `Bool` | True if event spans multiple days |
| `duration` | `TimeInterval` | Event duration in seconds |

#### Initializers

```swift
// Standard initializer
init(id:title:startDate:endDate:isAllDay:calendarID:calendarColor:calendarTitle:location:notes:url:hasVideoCall:videoCallURL:)

// From EventKit
init(from ekEvent: EKEvent)
```

---

### CalendarSource

Represents a calendar from Apple Calendar or Google Calendar.

```swift
struct CalendarSource: Identifiable, Hashable {
    let id: String
    let title: String
    let color: Color
    let sourceType: SourceType
    var isEnabled: Bool
}
```

#### SourceType

```swift
enum SourceType: String, Codable {
    case local      // "On My Device"
    case iCloud     // "iCloud"
    case exchange   // "Exchange"
    case google     // "Google"
    case calDAV     // "CalDAV"
    case unknown    // "Other"

    var displayName: String { ... }
    var icon: String { ... }  // SF Symbol name
}
```

---

### CalendarSet

User-defined group of calendars (persisted with SwiftData).

```swift
@Model
final class CalendarSet {
    var id: UUID
    var name: String
    var calendarIDs: [String]
    var iconName: String
    var colorHex: String
    var isDefault: Bool

    var color: Color { ... }
}
```

---

## ViewModels

### CalendarViewModel

Main application state. Use with `@Environment`.

```swift
@Observable
final class CalendarViewModel {
    // State
    var calendars: [CalendarSource]
    var events: [CalendarEvent]
    var displayedYear: Int
    var selectedDate: Date?
    var isLoading: Bool
    var errorMessage: String?
    var hasCalendarAccess: Bool

    // Computed
    var enabledCalendarIDs: Set<String>
    var filteredEvents: [CalendarEvent]
}
```

#### Methods

```swift
// Lifecycle
func requestAccess() async
func loadCalendars() async
func loadEvents() async

// Navigation
func goToToday()
func goToPreviousYear()
func goToNextYear()

// Calendar management
func toggleCalendar(_ calendar: CalendarSource)
func enableAllCalendars()
func disableAllCalendars()

// Queries
func events(for date: Date) -> [CalendarEvent]
func eventColors(for date: Date) -> [Color]
func hasEvents(on date: Date) -> Bool
func search(query: String) -> [CalendarEvent]
```

---

### YearViewModel

Year view display configuration.

```swift
@Observable
final class YearViewModel {
    var layoutStyle: YearLayoutStyle
    var showWeekends: Bool
    var showWeekNumbers: Bool
    var firstDayOfWeek: Int
    var zoomLevel: CGFloat

    func months(for year: Int) -> [MonthData]
}
```

#### YearLayoutStyle

```swift
enum YearLayoutStyle: String, CaseIterable {
    case standardGrid   // 4×3 month grid
    case continuousRow  // Horizontal scrolling
    case verticalList   // Vertical month list

    var icon: String { ... }  // SF Symbol
}
```

---

### DayViewModel

State for day detail view.

```swift
@Observable
final class DayViewModel {
    var selectedDate: Date
    var events: [CalendarEvent]
    var isLoading: Bool

    // Computed
    var formattedDate: String
    var shortFormattedDate: String
    var sortedEvents: [CalendarEvent]
    var allDayEvents: [CalendarEvent]
    var timedEvents: [CalendarEvent]
}
```

#### Methods

```swift
func openInCalendar(event: CalendarEvent?)
func addEvent()
func joinVideoCall(event: CalendarEvent)
func formattedTime(for event: CalendarEvent) -> String
func formattedDuration(for event: CalendarEvent) -> String
```

---

## Services

### EventKitService

Apple Calendar integration via EventKit.

```swift
final class EventKitService {
    var authorizationStatus: EKAuthorizationStatus

    func requestAccess() async throws -> Bool
    func fetchCalendars() -> [EKCalendar]
    func fetchEvents(from: Date, to: Date, calendars: [EKCalendar]?) -> [EKEvent]
    func fetchEvent(withIdentifier: String) -> EKEvent?
    func startObservingChanges(handler: @escaping () -> Void) -> NSObjectProtocol
    func stopObservingChanges(observer: NSObjectProtocol)
}
```

---

### GoogleCalendarService

Direct Google Calendar API integration.

```swift
final class GoogleCalendarService {
    var isAuthenticated: Bool

    func signIn() async throws
    func signOut()
    func fetchCalendars() async throws -> [GoogleCalendar]
    func fetchEvents(calendarID: String, from: Date, to: Date) async throws -> [GoogleEvent]
}
```

#### GoogleCalendar

```swift
struct GoogleCalendar: Codable, Identifiable {
    let id: String
    let summary: String
    let backgroundColor: String?
    let foregroundColor: String?
    let primary: Bool?
    let accessRole: String
}
```

---

### CalendarDeepLinkService

Opens native calendar apps.

```swift
final class CalendarDeepLinkService {
    func openCalendar(at date: Date)
    func openEvent(_ event: CalendarEvent)
    func createEvent(on date: Date)
    func openGoogleCalendar(at date: Date)
    func openGoogleCalendarEvent(eventID: String, calendarID: String)
    func createGoogleCalendarEvent(on date: Date, title: String?)
    func openURL(_ url: URL)
}
```

---

### CalendarCacheService

UserDefaults persistence for preferences.

```swift
final class CalendarCacheService {
    // Calendar preferences
    func saveEnabledCalendarIDs(_ ids: [String])
    func loadEnabledCalendarIDs() -> [String]

    // Layout preferences
    func saveSelectedLayout(_ layout: String)
    func loadSelectedLayout() -> String

    // Display preferences
    func saveShowWeekends(_ show: Bool)
    func loadShowWeekends() -> Bool
    func saveShowWeekNumbers(_ show: Bool)
    func loadShowWeekNumbers() -> Bool
    func saveFirstDayOfWeek(_ day: Int)
    func loadFirstDayOfWeek() -> Int

    // State persistence
    func saveLastViewedYear(_ year: Int)
    func loadLastViewedYear() -> Int

    func clearAllPreferences()
}
```

---

## Utilities

### Date Extensions

```swift
extension Date {
    var startOfDay: Date
    var endOfDay: Date
    var startOfMonth: Date
    var endOfMonth: Date
    var startOfYear: Date
    var endOfYear: Date
    var isToday: Bool
    var isWeekend: Bool

    func isSameDay(as other: Date) -> Bool
    func isSameMonth(as other: Date) -> Bool
    func isSameYear(as other: Date) -> Bool

    func adding(days: Int) -> Date
    func adding(months: Int) -> Date
    func adding(years: Int) -> Date

    var dayOfMonth: Int
    var month: Int
    var year: Int
    var weekday: Int
    var weekOfYear: Int

    static func from(year: Int, month: Int, day: Int) -> Date?
}
```

### Calendar Extensions

```swift
extension Calendar {
    func daysInMonth(for date: Date) -> Int
    func firstDayOfMonth(for date: Date) -> Date
    func allDays(in month: Date) -> [Date]
    func allMonths(in year: Int) -> [Date]
}
```

### DateRange

```swift
struct DateRange {
    let start: Date
    let end: Date

    var days: [Date]
    func contains(_ date: Date) -> Bool

    static func month(containing date: Date) -> DateRange
    static func year(containing date: Date) -> DateRange
    static func year(_ year: Int) -> DateRange
}
```

### Color Extensions

```swift
extension Color {
    init(hex: String)
    init(cgColor: CGColor)

    var luminance: Double
    var isDark: Bool
    var contrastingTextColor: Color

    func adjustedBrightness(_ amount: Double) -> Color

    static var systemGroupedBackground: Color
    static var secondarySystemGroupedBackground: Color
}
```

### HapticFeedback

```swift
struct HapticFeedback {
    static func light()
    static func medium()
    static func heavy()
    static func selection()
    static func success()
    static func warning()
    static func error()
}
```
