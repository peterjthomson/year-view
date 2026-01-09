import WidgetKit
import SwiftUI

struct YearViewLargeWidget: Widget {
    let kind: String = "YearViewLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearViewWidgetProvider()) { entry in
            LargeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Month View")
        .description("Shows the current month calendar with events.")
        .supportedFamilies([.systemLarge])
    }
}

struct LargeWidgetView: View {
    let entry: YearViewWidgetEntry

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                if !entry.events.isEmpty {
                    Text("\(entry.events.count) today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading empty cells
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear
                        .frame(height: 28)
                }

                // Days
                ForEach(entry.monthDays) { day in
                    WidgetDayCell(day: day)
                }
            }

            Divider()

            // Today's events
            VStack(alignment: .leading, spacing: 6) {
                Text("Today")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                if entry.events.isEmpty {
                    Text("No events")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entry.events.prefix(3)) { event in
                        WidgetEventRow(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: entry.date)
    }

    private var leadingEmptyDays: Int {
        guard let firstDay = entry.monthDays.first else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay.date)
        return weekday - calendar.firstWeekday
    }
}

struct WidgetDayCell: View {
    let day: WidgetDay

    var body: some View {
        ZStack {
            if day.isToday {
                Circle()
                    .fill(Color.accentColor)
            }

            Text("\(day.dayNumber)")
                .font(.system(size: 12, weight: day.isToday ? .bold : .regular, design: .rounded))
                .foregroundStyle(day.isToday ? .white : .primary)
        }
        .frame(height: 28)
        .overlay(alignment: .bottom) {
            if day.hasEvents && !day.isToday {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: 4)
                    .offset(y: -2)
            }
        }
    }
}

#Preview(as: .systemLarge) {
    YearViewLargeWidget()
} timeline: {
    YearViewWidgetEntry(
        date: Date(),
        events: [
            WidgetEvent(id: "1", title: "Team Standup", startDate: Date(), endDate: Date(), isAllDay: false, color: .blue),
            WidgetEvent(id: "2", title: "Design Review", startDate: Date(), endDate: Date(), isAllDay: false, color: .green),
        ],
        monthDays: (1...31).map { day in
            WidgetDay(
                date: Date(),
                dayNumber: day,
                isToday: day == Calendar.current.component(.day, from: Date()),
                hasEvents: [5, 12, 15, 20, 25].contains(day)
            )
        }
    )
}
