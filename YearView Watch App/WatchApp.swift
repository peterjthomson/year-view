import SwiftUI
import Observation

@main
struct YearViewWatchApp: App {
    @State private var calendarViewModel = WatchCalendarViewModel()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(calendarViewModel)
        }
    }
}

@Observable
final class WatchCalendarViewModel {
    var events: [CalendarEvent] = []
    var displayedMonth: Date = Date()
    var isLoading = false
    var hasCalendarAccess = false

    #if canImport(EventKit)
    private let eventKitService = EventKitService()
    #endif

    @MainActor
    func requestAccess() async {
        isLoading = true
        #if canImport(EventKit)
        do {
            hasCalendarAccess = try await eventKitService.requestAccess()
            if hasCalendarAccess {
                await loadEvents()
            }
        } catch {
            hasCalendarAccess = false
        }
        #else
        // EventKit isn't available on this platform.
        hasCalendarAccess = false
        events = []
        #endif
        isLoading = false
    }

    @MainActor
    func loadEvents() async {
        #if canImport(EventKit)
        let startOfMonth = displayedMonth.startOfMonth
        let endOfMonth = displayedMonth.endOfMonth

        let ekEvents = eventKitService.fetchEvents(from: startOfMonth, to: endOfMonth)
        events = ekEvents.map { CalendarEvent(from: $0) }
        #else
        events = []
        #endif
    }

    func events(for date: Date) -> [CalendarEvent] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }

    func hasEvents(on date: Date) -> Bool {
        !events(for: date).isEmpty
    }

    func goToNextMonth() {
        displayedMonth = displayedMonth.adding(months: 1)
        Task { await loadEvents() }
    }

    func goToPreviousMonth() {
        displayedMonth = displayedMonth.adding(months: -1)
        Task { await loadEvents() }
    }

    func goToToday() {
        displayedMonth = Date()
        Task { await loadEvents() }
    }
}
