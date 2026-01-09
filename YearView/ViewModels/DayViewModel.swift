import SwiftUI
import Observation

@Observable
final class DayViewModel {
    var selectedDate: Date
    var events: [CalendarEvent]
    var isLoading = false

    private let deepLinkService = CalendarDeepLinkService()

    init(date: Date = Date(), events: [CalendarEvent] = []) {
        self.selectedDate = date
        self.events = events
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }

    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    var sortedEvents: [CalendarEvent] {
        events.sorted { event1, event2 in
            // All-day events first
            if event1.isAllDay && !event2.isAllDay {
                return true
            } else if !event1.isAllDay && event2.isAllDay {
                return false
            }
            // Then sort by start time
            return event1.startDate < event2.startDate
        }
    }

    var allDayEvents: [CalendarEvent] {
        events.filter { $0.isAllDay }
    }

    var timedEvents: [CalendarEvent] {
        events.filter { !$0.isAllDay }.sorted { $0.startDate < $1.startDate }
    }

    func openInCalendar(event: CalendarEvent? = nil) {
        if let event = event {
            deepLinkService.openEvent(event)
        } else {
            deepLinkService.openCalendar(at: selectedDate)
        }
    }

    func addEvent() {
        deepLinkService.createEvent(on: selectedDate)
    }

    func joinVideoCall(event: CalendarEvent) {
        guard let url = event.videoCallURL else { return }
        deepLinkService.openURL(url)
    }

    func formattedTime(for event: CalendarEvent) -> String {
        if event.isAllDay {
            return "All day"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let startTime = formatter.string(from: event.startDate)
        let endTime = formatter.string(from: event.endDate)

        return "\(startTime) - \(endTime)"
    }

    func formattedDuration(for event: CalendarEvent) -> String {
        let duration = event.duration
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
