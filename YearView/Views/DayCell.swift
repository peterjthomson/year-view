import SwiftUI

struct DayCell: View {
    let day: DayData
    let isSelected: Bool
    let eventColors: [Color]
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    // Today highlight
                    if day.isToday {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 28, height: 28)
                    }

                    // Selection ring
                    if isSelected && !day.isToday {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }

                    Text("\(day.dayNumber)")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(day.isToday ? .bold : .regular)
                        .foregroundStyle(dayTextColor)
                }
                .frame(width: 30, height: 30)

                // Event dots
                HStack(spacing: 2) {
                    ForEach(eventColors.prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 6)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view events")
        .accessibilityAddTraits(day.isToday ? [.isSelected] : [])
    }

    private var dayTextColor: Color {
        if day.isToday {
            return .white
        } else if day.isWeekend {
            return .secondary
        } else {
            return .primary
        }
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        var label = formatter.string(from: day.date)

        if day.isToday {
            label = "Today, " + label
        }

        let eventCount = eventColors.count
        if eventCount > 0 {
            label += ", \(eventCount) event\(eventCount == 1 ? "" : "s")"
        }

        return label
    }
}

struct CompactDayCell: View {
    let day: DayData
    let hasEvents: Bool
    let eventColor: Color?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background for today
                if day.isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 16, height: 16)
                }

                // Event indicator
                if hasEvents && !day.isToday {
                    Circle()
                        .fill(eventColor ?? .gray)
                        .frame(width: 16, height: 16)
                        .opacity(0.3)
                }

                Text("\(day.dayNumber)")
                    .font(.system(size: 9, weight: day.isToday ? .bold : .regular, design: .rounded))
                    .foregroundStyle(day.isToday ? .white : (day.isWeekend ? .secondary : .primary))
            }
            .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var label = formatter.string(from: day.date)

        if day.isToday {
            label = "Today, " + label
        }

        if hasEvents {
            label += ", has events"
        }

        return label
    }
}

#Preview("Day Cell") {
    HStack(spacing: 20) {
        DayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            isSelected: false,
            eventColors: [.blue, .green],
            onTap: {}
        )

        DayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            isSelected: true,
            eventColors: [.blue],
            onTap: {}
        )

        DayCell(
            day: DayData(date: Date().addingTimeInterval(86400), calendar: Calendar.current),
            isSelected: false,
            eventColors: [],
            onTap: {}
        )
    }
    .padding()
}

#Preview("Compact Day Cell") {
    HStack(spacing: 8) {
        CompactDayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            hasEvents: true,
            eventColor: .blue,
            onTap: {}
        )

        CompactDayCell(
            day: DayData(date: Date().addingTimeInterval(86400), calendar: Calendar.current),
            hasEvents: false,
            eventColor: nil,
            onTap: {}
        )
    }
    .padding()
}
