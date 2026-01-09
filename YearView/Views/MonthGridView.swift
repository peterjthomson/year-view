import SwiftUI

struct MonthGridView: View {
    let month: MonthData
    let selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month header
            Text(month.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(month.weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(month.weeks.indices, id: \.self) { weekIndex in
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = month.weeks[weekIndex][dayIndex] {
                            DayCell(
                                day: day,
                                isSelected: isSelected(day.date),
                                eventColors: calendarViewModel.eventColors(for: day.date),
                                onTap: { onDateTap(day.date) }
                            )
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct CompactMonthGridView: View {
    let month: MonthData
    let selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(month.shortName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(month.weeks.indices, id: \.self) { weekIndex in
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = month.weeks[weekIndex][dayIndex] {
                            CompactDayCell(
                                day: day,
                                hasEvents: calendarViewModel.hasEvents(on: day.date),
                                eventColor: calendarViewModel.eventColors(for: day.date).first,
                                onTap: { onDateTap(day.date) }
                            )
                        } else {
                            Color.clear
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

#Preview("Standard Month Grid") {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2026
    components.month = 1
    components.day = 1
    let date = calendar.date(from: components)!

    return MonthGridView(
        month: MonthData(date: date, calendar: calendar),
        selectedDate: Date(),
        onDateTap: { _ in }
    )
    .environment(CalendarViewModel())
    .padding()
}

#Preview("Compact Month Grid") {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2026
    components.month = 1
    components.day = 1
    let date = calendar.date(from: components)!

    return CompactMonthGridView(
        month: MonthData(date: date, calendar: calendar),
        selectedDate: Date(),
        onDateTap: { _ in }
    )
    .environment(CalendarViewModel())
    .padding()
}
