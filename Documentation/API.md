# Year View API Reference

This document provides API reference for Year View's public types and services.

## Models

### CalendarEvent

Represents a calendar event from any source. Conforms to `Identifiable` and `Hashable`.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `title` | `String` | Event title |
| `startDate` | `Date` | Start date/time |
| `endDate` | `Date` | End date/time |
| `isAllDay` | `Bool` | Whether event is all-day |
| `calendarID` | `String` | Parent calendar ID |
| `calendarColor` | `Color` | Calendar color |
| `calendarTitle` | `String` | Calendar name |
| `location` | `String?` | Event location |
| `notes` | `String?` | Event notes |
| `url` | `URL?` | Associated URL |
| `hasVideoCall` | `Bool` | Video call detected |
| `videoCallURL` | `URL?` | Video call link |

| Computed Property | Type | Description |
|-------------------|------|-------------|
| `isMultiDay` | `Bool` | True if event spans multiple days |
| `duration` | `TimeInterval` | Event duration in seconds |

Can be initialized directly or from an `EKEvent` (EventKit).

---

### CalendarSource

Represents a calendar from Apple Calendar or Google Calendar. Conforms to `Identifiable` and `Hashable`.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Calendar identifier |
| `title` | `String` | Calendar name |
| `color` | `Color` | Calendar color |
| `sourceType` | `SourceType` | Source type (see below) |
| `isEnabled` | `Bool` | Whether calendar is visible |

#### SourceType

| Case | Display Name |
|------|--------------|
| `local` | On My Device |
| `iCloud` | iCloud |
| `exchange` | Exchange |
| `google` | Google |
| `calDAV` | CalDAV |
| `unknown` | Other |

Each case provides `displayName` and `icon` (SF Symbol) properties.

---

### CalendarSet

User-defined group of calendars (persisted with SwiftData).

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `name` | `String` | Set name |
| `calendarIDs` | `[String]` | Included calendar IDs |
| `iconName` | `String` | SF Symbol name |
| `colorHex` | `String` | Hex color string |
| `isDefault` | `Bool` | Whether this is the default set |
| `color` | `Color` | Computed color from hex |

---

## ViewModels

### CalendarViewModel

Main application state. Use with `@Environment`.

| Property | Type | Description |
|----------|------|-------------|
| `calendars` | `[CalendarSource]` | All available calendars |
| `events` | `[CalendarEvent]` | Events for displayed year |
| `displayedYear` | `Int` | Currently displayed year |
| `selectedDate` | `Date?` | Selected date (if any) |
| `isLoading` | `Bool` | Loading state |
| `errorMessage` | `String?` | Error message (if any) |
| `hasCalendarAccess` | `Bool` | Calendar permission granted |
| `enabledCalendarIDs` | `Set<String>` | IDs of enabled calendars |
| `filteredEvents` | `[CalendarEvent]` | Events from enabled calendars |

#### Methods

| Category | Method | Description |
|----------|--------|-------------|
| Lifecycle | `requestAccess()` | Request calendar permission |
| Lifecycle | `loadCalendars()` | Fetch available calendars |
| Lifecycle | `loadEvents()` | Fetch events for displayed year |
| Navigation | `goToToday()` | Navigate to current date |
| Navigation | `goToPreviousYear()` | Go to previous year |
| Navigation | `goToNextYear()` | Go to next year |
| Calendar | `toggleCalendar(_:)` | Toggle calendar visibility |
| Calendar | `enableAllCalendars()` | Show all calendars |
| Calendar | `disableAllCalendars()` | Hide all calendars |
| Calendar | `setEnabledCalendarIDs(_:)` | Batch update enabled calendars |
| Query | `events(for:)` | Get events for a date |
| Query | `eventColors(for:)` | Get event colors for a date |
| Query | `hasEvents(on:)` | Check if date has events |
| Query | `search(query:)` | Search events by text |

---

### YearViewModel

Year view display configuration.

| Property | Type | Description |
|----------|------|-------------|
| `layoutStyle` | `YearLayoutStyle` | Current layout (default: `.monthRows`) |
| `showWeekends` | `Bool` | Show weekend days (default: `true`) |
| `showWeekNumbers` | `Bool` | Show week numbers (default: `false`) |
| `zoomLevel` | `CGFloat` | Zoom level (default: `1.0`) |

| Method | Returns | Description |
|--------|---------|-------------|
| `months(for:)` | `[MonthData]` | Generate month data for a year |

#### YearLayoutStyle

| Case | Description |
|------|-------------|
| `monthRows` | Calendar.app-style month rows (default) |
| `bigYear` | Continuous week rows |
| `standardGrid` | Traditional 4×3 month grid |
| `continuousRow` | Horizontal month scroll |
| `verticalList` | Vertical month list |

Each case provides `icon` (SF Symbol name) and `description` properties.

---

### DayViewModel

State for day detail view.

| Property | Type | Description |
|----------|------|-------------|
| `selectedDate` | `Date` | The displayed date |
| `events` | `[CalendarEvent]` | Events for the date |
| `isLoading` | `Bool` | Loading state |
| `formattedDate` | `String` | Full date string (e.g., "Monday, June 15, 2026") |
| `shortFormattedDate` | `String` | Short date string (e.g., "Monday, Jun 15") |
| `sortedEvents` | `[CalendarEvent]` | Events sorted by time (all-day first) |
| `allDayEvents` | `[CalendarEvent]` | All-day events only |
| `timedEvents` | `[CalendarEvent]` | Timed events only |

| Method | Description |
|--------|-------------|
| `openInCalendar(event:)` | Open event or date in Calendar app |
| `addEvent()` | Create new event on selected date |
| `joinVideoCall(event:)` | Open video call URL |
| `formattedTime(for:)` | Format event time range |
| `formattedDuration(for:)` | Format event duration |

---

## Services

### EventKitService

Apple Calendar integration via EventKit. Handles authorization, calendar fetching, and event queries.

| Method | Description |
|--------|-------------|
| `requestAccess()` | Request calendar permission |
| `fetchCalendars()` | Get all available calendars |
| `fetchEvents(from:to:)` | Get events in date range |
| `startObservingChanges(handler:)` | Subscribe to calendar changes |

---

### GoogleCalendarService

Direct Google Calendar API integration (experimental). Handles OAuth and read-only calendar/event access.

| Method | Description |
|--------|-------------|
| `signIn()` | Authenticate with Google |
| `signOut()` | Clear authentication |
| `fetchCalendars()` | Get Google calendars |
| `fetchEvents(calendarID:from:to:)` | Get events from a calendar |

---

### CalendarDeepLinkService

Opens native calendar apps for viewing/editing events.

| Method | Description |
|--------|-------------|
| `openCalendar(at:)` | Open Apple Calendar to a date |
| `openEvent(_:)` | Open event in Calendar app |
| `createEvent(on:)` | Create new event |
| `openGoogleCalendar(at:)` | Open Google Calendar web |
| `openURL(_:)` | Open arbitrary URL |

---

### CalendarCacheService

UserDefaults persistence for preferences.

| Data | Methods |
|------|---------|
| Enabled calendars | `saveEnabledCalendarIDs(_:)` / `loadEnabledCalendarIDs()` |
| Layout | `saveSelectedLayout(_:)` / `loadSelectedLayout()` |
| Show weekends | `saveShowWeekends(_:)` / `loadShowWeekends()` |
| Show week numbers | `saveShowWeekNumbers(_:)` / `loadShowWeekNumbers()` |
| First day of week | `saveFirstDayOfWeek(_:)` / `loadFirstDayOfWeek()` |
| Last viewed year | `saveLastViewedYear(_:)` / `loadLastViewedYear()` |
| Reset | `clearAllPreferences()` |

---

## Utilities

### Date Extensions

Extensions on `Date` for common calendar operations.

| Category | Methods/Properties |
|----------|-------------------|
| Boundaries | `startOfDay`, `endOfDay`, `startOfMonth`, `endOfMonth`, `startOfYear`, `endOfYear` |
| Queries | `isToday`, `isWeekend` |
| Comparison | `isSameDay(as:)`, `isSameMonth(as:)`, `isSameYear(as:)` |
| Arithmetic | `adding(days:)`, `adding(months:)`, `adding(years:)` |
| Components | `dayOfMonth`, `month`, `year`, `weekday`, `weekOfYear` |
| Factory | `Date.from(year:month:day:)` |

### Calendar Extensions

Extensions on `Calendar` for date enumeration.

| Method | Description |
|--------|-------------|
| `daysInMonth(for:)` | Number of days in month |
| `firstDayOfMonth(for:)` | First day of month |
| `allDays(in:)` | All days in a month |
| `allMonths(in:)` | All months in a year |

### DateRange

Represents a range of dates with utilities for enumeration and containment checks.

### Color Extensions

Extensions on `Color` for hex parsing, luminance calculation, and system colors.

| Category | Methods/Properties |
|----------|-------------------|
| Init | `init(hex:)`, `init(cgColor:)` |
| Analysis | `luminance`, `isDark`, `contrastingTextColor` |
| Transform | `adjustedBrightness(_:)` |
| System | `systemBackground`, `systemGroupedBackground`, `separator` |

### HapticFeedback

Cross-platform haptic feedback (iOS only, no-op on macOS).

| Method | Description |
|--------|-------------|
| `light()`, `medium()`, `heavy()` | Impact feedback |
| `selection()` | Selection feedback |
| `success()`, `warning()`, `error()` | Notification feedback |
