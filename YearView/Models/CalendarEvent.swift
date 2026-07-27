import SwiftUI
#if canImport(EventKit)
import EventKit
#endif

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

    var isMultiDay: Bool {
        let span = displayedDayOffsets(
            in: displayedDayInterval(calendar: .current),
            calendar: .current
        )?.span ?? 1
        return span > 1
    }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    /// The half-open range of calendar days occupied by the event.
    ///
    /// EventKit all-day event end dates are exclusive. Timed events ending
    /// exactly at midnight also do not occupy the following day.
    func displayedDayInterval(calendar: Calendar) -> DateInterval {
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        let nextStartDay = calendar.date(byAdding: .day, value: 1, to: startDay)
            ?? startDay.addingTimeInterval(86_400)

        let exclusiveEnd: Date
        if isAllDay {
            exclusiveEnd = max(endDay, nextStartDay)
        } else if endDate > startDate, endDate == endDay, endDay > startDay {
            exclusiveEnd = endDay
        } else {
            exclusiveEnd = calendar.date(byAdding: .day, value: 1, to: endDay)
                ?? endDay.addingTimeInterval(86_400)
        }

        return DateInterval(start: startDay, end: max(exclusiveEnd, nextStartDay))
    }

    /// Returns the event's start offset and span after intersecting it with
    /// a half-open day interval. Calendar arithmetic keeps this DST-safe.
    func displayedDayOffsets(
        in visibleInterval: DateInterval,
        calendar: Calendar
    ) -> (start: Int, span: Int)? {
        let eventInterval = displayedDayInterval(calendar: calendar)
        let overlapStart = max(eventInterval.start, visibleInterval.start)
        let overlapEnd = min(eventInterval.end, visibleInterval.end)

        guard overlapStart < overlapEnd else { return nil }

        let start = calendar.dateComponents(
            [.day],
            from: visibleInterval.start,
            to: overlapStart
        ).day ?? 0
        let span = calendar.dateComponents(
            [.day],
            from: overlapStart,
            to: overlapEnd
        ).day ?? 0

        guard span > 0 else { return nil }
        return (start, span)
    }

    init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        calendarID: String,
        calendarColor: Color,
        calendarTitle: String,
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil,
        hasVideoCall: Bool = false,
        videoCallURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.calendarID = calendarID
        self.calendarColor = calendarColor
        self.calendarTitle = calendarTitle
        self.location = location
        self.notes = notes
        self.url = url
        self.hasVideoCall = hasVideoCall
        self.videoCallURL = videoCallURL
    }

    #if canImport(EventKit)
    init(from ekEvent: EKEvent) {
        // Use a composite ID for recurring events to ensure uniqueness across occurrences.
        // eventIdentifier identifies the series, not the specific occurrence.
        let baseID = ekEvent.eventIdentifier ?? UUID().uuidString
        self.id = "\(baseID)-\(ekEvent.startDate.timeIntervalSince1970)"
        
        self.title = ekEvent.title ?? "Untitled"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.calendarID = ekEvent.calendar?.calendarIdentifier ?? ""
        self.calendarColor = Color(cgColor: ekEvent.calendar?.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        self.calendarTitle = ekEvent.calendar?.title ?? "Calendar"
        self.location = ekEvent.location
        self.notes = ekEvent.notes
        self.url = ekEvent.url

        // Detect video call links
        let videoCallDetector = VideoCallDetector()
        let (hasCall, callURL) = videoCallDetector.detectVideoCall(
            in: ekEvent.notes,
            location: ekEvent.location,
            url: ekEvent.url
        )
        self.hasVideoCall = hasCall
        self.videoCallURL = callURL
    }
    #endif

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

private struct VideoCallDetector {
    private let patterns: [(pattern: String, prefix: String)] = [
        ("https://[^\\s]*zoom\\.us/[^\\s]+", ""),
        ("https://meet\\.google\\.com/[^\\s]+", ""),
        ("https://teams\\.microsoft\\.com/[^\\s]+", ""),
        ("https://[^\\s]*webex\\.com/[^\\s]+", ""),
    ]

    func detectVideoCall(in notes: String?, location: String?, url: URL?) -> (hasCall: Bool, url: URL?) {
        // Check URL first
        if let url = url, isVideoCallURL(url) {
            return (true, url)
        }

        // Check location
        if let location = location, let foundURL = findVideoCallURL(in: location) {
            return (true, foundURL)
        }

        // Check notes
        if let notes = notes, let foundURL = findVideoCallURL(in: notes) {
            return (true, foundURL)
        }

        return (false, nil)
    }

    private func isVideoCallURL(_ url: URL) -> Bool {
        let host = url.host?.lowercased() ?? ""
        return host.contains("zoom.us") ||
               host.contains("meet.google.com") ||
               host.contains("teams.microsoft.com") ||
               host.contains("webex.com")
    }

    private func findVideoCallURL(in text: String) -> URL? {
        for (pattern, _) in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let urlString = String(text[range])
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        return nil
    }
}

extension CalendarEvent {
    static var preview: CalendarEvent {
        CalendarEvent(
            id: "preview-1",
            title: "Team Meeting",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            isAllDay: false,
            calendarID: "work",
            calendarColor: .blue,
            calendarTitle: "Work",
            location: "Conference Room A",
            hasVideoCall: true,
            videoCallURL: URL(string: "https://meet.google.com/abc-defg-hij")
        )
    }

    static var previewAllDay: CalendarEvent {
        CalendarEvent(
            id: "preview-2",
            title: "Company Holiday",
            startDate: Calendar.current.startOfDay(for: Date()),
            endDate: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400),
            isAllDay: true,
            calendarID: "company",
            calendarColor: .green,
            calendarTitle: "Company"
        )
    }
}
