import SwiftUI
import EventKit
import Observation

@Observable
final class CalendarViewModel {
    private let eventKitService = EventKitService()
    private let googleCalendarService = GoogleCalendarService()
    private let cacheService = CalendarCacheService()

    var calendars: [CalendarSource] = []
    var events: [CalendarEvent] = []
    var displayedYear: Int {
        didSet {
            guard displayedYear != oldValue else { return }
            cacheService.saveLastViewedYear(displayedYear)
            guard hasCalendarAccess else { return }
            Task { @MainActor in
                await loadEvents()
            }
        }
    }
    var selectedDate: Date?
    var isLoading = false
    var errorMessage: String?
    var hasCalendarAccess = false

    var enabledCalendarIDs: Set<String> {
        Set(calendars.filter { $0.isEnabled }.map { $0.id })
    }

    var filteredEvents: [CalendarEvent] {
        events.filter { enabledCalendarIDs.contains($0.calendarID) }
    }

    init() {
        // Default to the current year on launch (do not restore last viewed year)
        self.displayedYear = Calendar.current.component(.year, from: Date())
    }

    @MainActor
    func requestAccess() async {
        isLoading = true
        errorMessage = nil

        do {
            let granted = try await eventKitService.requestAccess()
            hasCalendarAccess = granted

            if granted {
                await loadCalendars()
                await loadEvents()
            } else {
                errorMessage = "Calendar access denied. Please enable access in Settings."
            }
        } catch {
            errorMessage = "Failed to request calendar access: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func loadCalendars() async {
        let ekCalendars = eventKitService.fetchCalendars()
        calendars = ekCalendars.map { CalendarSource(from: $0) }

        // Load saved preferences
        let savedEnabledIDs = cacheService.loadEnabledCalendarIDs()
        if !savedEnabledIDs.isEmpty {
            for index in calendars.indices {
                calendars[index].isEnabled = savedEnabledIDs.contains(calendars[index].id)
            }
        }
    }

    @MainActor
    func loadEvents() async {
        guard hasCalendarAccess else { return }

        isLoading = true

        let calendar = Calendar.current
        var components = DateComponents()
        components.year = displayedYear
        components.month = 1
        components.day = 1

        guard let startOfYear = calendar.date(from: components) else {
            isLoading = false
            return
        }

        components.year = displayedYear + 1
        guard let endOfYear = calendar.date(from: components) else {
            isLoading = false
            return
        }

        let ekEvents = eventKitService.fetchEvents(from: startOfYear, to: endOfYear)
        events = ekEvents.map { CalendarEvent(from: $0) }

        isLoading = false
    }

    func toggleCalendar(_ calendar: CalendarSource) {
        let updated = calendars.map { source in
            var copy = source
            if copy.id == calendar.id {
                copy.isEnabled.toggle()
            }
            return copy
        }
        calendars = updated
        saveCalendarPreferences()
    }

    func enableAllCalendars() {
        calendars = calendars.map { source in
            var copy = source
            copy.isEnabled = true
            return copy
        }
        saveCalendarPreferences()
    }

    func disableAllCalendars() {
        calendars = calendars.map { source in
            var copy = source
            copy.isEnabled = false
            return copy
        }
        saveCalendarPreferences()
    }

    /// Update enabled calendars in a single batch (avoids per-row UI churn).
    func setEnabledCalendarIDs(_ ids: Set<String>) {
        calendars = calendars.map { source in
            var copy = source
            copy.isEnabled = ids.contains(copy.id)
            return copy
        }
        saveCalendarPreferences()
    }

    private func saveCalendarPreferences() {
        let enabledIDs = calendars.filter { $0.isEnabled }.map { $0.id }
        cacheService.saveEnabledCalendarIDs(enabledIDs)
    }

    func goToToday() {
        let currentYear = Calendar.current.component(.year, from: Date())
        if displayedYear != currentYear {
            displayedYear = currentYear
            Task {
                await loadEvents()
            }
        }
        selectedDate = Date()
    }

    func goToPreviousYear() {
        displayedYear -= 1
        Task {
            await loadEvents()
        }
    }

    func goToNextYear() {
        displayedYear += 1
        Task {
            await loadEvents()
        }
    }

    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return filteredEvents.filter { event in
            if event.isAllDay {
                // For all-day events, check if date falls within the event range
                let eventStart = calendar.startOfDay(for: event.startDate)
                let eventEnd = calendar.startOfDay(for: event.endDate)
                let targetDate = calendar.startOfDay(for: date)
                return targetDate >= eventStart && targetDate < eventEnd
            } else if event.isMultiDay {
                // For multi-day events
                let eventStart = calendar.startOfDay(for: event.startDate)
                let eventEnd = calendar.startOfDay(for: event.endDate)
                let targetDate = calendar.startOfDay(for: date)
                return targetDate >= eventStart && targetDate <= eventEnd
            } else {
                // For regular events
                return calendar.isDate(event.startDate, inSameDayAs: date)
            }
        }
    }

    func eventColors(for date: Date) -> [Color] {
        let dayEvents = events(for: date)
        var colors: [Color] = []
        var seenCalendarIDs: Set<String> = []

        for event in dayEvents {
            if !seenCalendarIDs.contains(event.calendarID) && colors.count < 3 {
                colors.append(event.calendarColor)
                seenCalendarIDs.insert(event.calendarID)
            }
        }

        return colors
    }

    func hasEvents(on date: Date) -> Bool {
        !events(for: date).isEmpty
    }

    func search(query: String) -> [CalendarEvent] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return filteredEvents.filter { event in
            event.title.lowercased().contains(lowercasedQuery) ||
            (event.location?.lowercased().contains(lowercasedQuery) ?? false) ||
            (event.notes?.lowercased().contains(lowercasedQuery) ?? false)
        }.sorted { $0.startDate < $1.startDate }
    }
}
