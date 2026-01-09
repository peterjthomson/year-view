import WidgetKit
import SwiftUI

struct YearViewSmallWidget: Widget {
    let kind: String = "YearViewSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearViewWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today")
        .description("Shows today's date and event count.")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallWidgetView: View {
    let entry: YearViewWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month and year
            Text(monthString)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            // Day number
            Text(dayString)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)

            // Weekday
            Text(weekdayString)
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            // Event count
            if entry.events.isEmpty {
                Text("No events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.events.first?.color ?? .accentColor)
                        .frame(width: 8, height: 8)

                    Text("\(entry.events.count) event\(entry.events.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: entry.date).uppercased()
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }

    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
}

#Preview(as: .systemSmall) {
    YearViewSmallWidget()
} timeline: {
    YearViewWidgetEntry(date: Date(), events: [], monthDays: [])
    YearViewWidgetEntry(
        date: Date(),
        events: [
            WidgetEvent(id: "1", title: "Meeting", startDate: Date(), endDate: Date(), isAllDay: false, color: .blue)
        ],
        monthDays: []
    )
}
