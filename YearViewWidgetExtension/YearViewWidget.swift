import WidgetKit
import SwiftUI
import EventKit

@main
struct YearViewWidgetBundle: WidgetBundle {
    var body: some Widget {
        YearViewSmallWidget()
        YearViewMediumWidget()
        YearViewLargeWidget()
        #if os(iOS)
        YearViewLockScreenWidget()
        #endif
    }
}

struct YearViewWidgetEntry: TimelineEntry {
    let date: Date
    let events: [WidgetEvent]
    let monthDays: [WidgetDay]
}

struct WidgetEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let color: Color
}

struct WidgetDay: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isToday: Bool
    let hasEvents: Bool
}

struct YearViewWidgetProvider: TimelineProvider {
    private let eventStore = EKEventStore()

    func placeholder(in context: Context) -> YearViewWidgetEntry {
        YearViewWidgetEntry(
            date: Date(),
            events: [],
            monthDays: generateMonthDays(for: Date())
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (YearViewWidgetEntry) -> Void) {
        let entry = YearViewWidgetEntry(
            date: Date(),
            events: fetchTodayEvents(),
            monthDays: generateMonthDays(for: Date())
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YearViewWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = YearViewWidgetEntry(
            date: currentDate,
            events: fetchTodayEvents(),
            monthDays: generateMonthDays(for: currentDate)
        )

        // Update at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: currentDate.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func fetchTodayEvents() -> [WidgetEvent] {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .authorized || status == .fullAccess else {
            return []
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents.prefix(5).map { event in
            WidgetEvent(
                id: event.eventIdentifier ?? UUID().uuidString,
                title: event.title ?? "Untitled",
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                color: Color(cgColor: event.calendar?.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
            )
        }
    }

    private func generateMonthDays(for date: Date) -> [WidgetDay] {
        let calendar = Calendar.current
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: date)!

        return range.compactMap { day -> WidgetDay? in
            guard let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) else { return nil }
            return WidgetDay(
                date: dayDate,
                dayNumber: day,
                isToday: calendar.isDateInToday(dayDate),
                hasEvents: hasEvents(on: dayDate)
            )
        }
    }

    private func hasEvents(on date: Date) -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .authorized || status == .fullAccess else {
            return false
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)

        return !events.isEmpty
    }
}
