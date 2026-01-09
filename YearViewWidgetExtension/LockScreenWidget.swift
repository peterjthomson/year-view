import WidgetKit
import SwiftUI

#if os(iOS)
struct YearViewLockScreenWidget: Widget {
    let kind: String = "YearViewLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearViewWidgetProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Today")
        .description("Shows today's date and event count on your Lock Screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetView: View {
    let entry: YearViewWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct CircularWidgetView: View {
    let entry: YearViewWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                Text(monthAbbrev)
                    .font(.system(size: 10, weight: .semibold))

                Text(dayString)
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                if !entry.events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(0..<min(entry.events.count, 3), id: \.self) { _ in
                            Circle()
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
    }

    private var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: entry.date).uppercased()
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }
}

struct RectangularWidgetView: View {
    let entry: YearViewWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(weekdayString)
                    .font(.caption2)
                    .fontWeight(.semibold)

                Text(dateString)
                    .font(.headline)
            }

            Spacer()

            if entry.events.isEmpty {
                Text("No events")
                    .font(.caption2)
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.events.count)")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("event\(entry.events.count == 1 ? "" : "s")")
                        .font(.caption2)
                }
            }
        }
    }

    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: entry.date)
    }
}

struct InlineWidgetView: View {
    let entry: YearViewWidgetEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")

            Text(dateString)

            if !entry.events.isEmpty {
                Text("•")
                Text("\(entry.events.count) event\(entry.events.count == 1 ? "" : "s")")
            }
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: entry.date)
    }
}

#Preview("Circular", as: .accessoryCircular) {
    YearViewLockScreenWidget()
} timeline: {
    YearViewWidgetEntry(date: Date(), events: [], monthDays: [])
}

#Preview("Rectangular", as: .accessoryRectangular) {
    YearViewLockScreenWidget()
} timeline: {
    YearViewWidgetEntry(
        date: Date(),
        events: [
            WidgetEvent(id: "1", title: "Meeting", startDate: Date(), endDate: Date(), isAllDay: false, color: .blue)
        ],
        monthDays: []
    )
}

#Preview("Inline", as: .accessoryInline) {
    YearViewLockScreenWidget()
} timeline: {
    YearViewWidgetEntry(
        date: Date(),
        events: [
            WidgetEvent(id: "1", title: "Meeting", startDate: Date(), endDate: Date(), isAllDay: false, color: .blue),
            WidgetEvent(id: "2", title: "Lunch", startDate: Date(), endDate: Date(), isAllDay: false, color: .green)
        ],
        monthDays: []
    )
}
#endif
