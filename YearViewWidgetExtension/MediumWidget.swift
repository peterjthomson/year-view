import WidgetKit
import SwiftUI

struct YearViewMediumWidget: Widget {
    let kind: String = "YearViewMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearViewWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Events")
        .description("Shows today's date and upcoming events.")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumWidgetView: View {
    let entry: YearViewWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Date
            VStack(alignment: .leading, spacing: 4) {
                Text(monthString)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(dayString)
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text(weekdayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 80)

            Divider()

            // Right side - Events
            VStack(alignment: .leading, spacing: 6) {
                if entry.events.isEmpty {
                    Text("No events today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    ForEach(entry.events.prefix(3)) { event in
                        WidgetEventRow(event: event)
                    }

                    if entry.events.count > 3 {
                        Text("+\(entry.events.count - 3) more")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
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

struct WidgetEventRow: View {
    let event: WidgetEvent

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(timeString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 32)
    }

    private var timeString: String {
        if event.isAllDay {
            return "All day"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}

#Preview(as: .systemMedium) {
    YearViewMediumWidget()
} timeline: {
    YearViewWidgetEntry(
        date: Date(),
        events: [
            WidgetEvent(id: "1", title: "Team Standup", startDate: Date(), endDate: Date(), isAllDay: false, color: .blue),
            WidgetEvent(id: "2", title: "Design Review", startDate: Date(), endDate: Date(), isAllDay: false, color: .green),
            WidgetEvent(id: "3", title: "Lunch with Sarah", startDate: Date(), endDate: Date(), isAllDay: false, color: .orange),
        ],
        monthDays: []
    )
}
