import SwiftUI

struct VerticalListLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @State private var scrollPosition: Int?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 32, pinnedViews: [.sectionHeaders]) {
                ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                    Section {
                        MonthListView(
                            month: month,
                            selectedDate: selectedDate,
                            onDateTap: onDateTap
                        )
                    } header: {
                        MonthSectionHeader(month: month)
                    }
                    .id(index)
                }
            }
            .padding(.horizontal)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Scroll to current month
            let currentMonth = Calendar.current.component(.month, from: Date()) - 1
            scrollPosition = currentMonth
        }
    }
}

struct MonthSectionHeader: View {
    let month: MonthData

    var body: some View {
        HStack {
            Text(month.name)
                .font(.title)
                .fontWeight(.bold)

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
    }
}

struct MonthListView: View {
    let month: MonthData
    let selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Horizontal day strip for each week
            ForEach(month.weeks.indices, id: \.self) { weekIndex in
                WeekStripView(
                    days: month.weeks[weekIndex],
                    selectedDate: selectedDate,
                    onDateTap: onDateTap
                )

                if weekIndex < month.weeks.count - 1 {
                    Divider()
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct WeekStripView: View {
    let days: [DayData?]
    let selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                if let day = days[index] {
                    DayStripCell(
                        day: day,
                        isSelected: isSelected(day.date),
                        eventColors: calendarViewModel.eventColors(for: day.date),
                        onTap: { onDateTap(day.date) }
                    )
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct DayStripCell: View {
    let day: DayData
    let isSelected: Bool
    let eventColors: [Color]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Weekday
                Text(weekdayAbbreviation)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                // Day number
                ZStack {
                    if day.isToday {
                        Circle()
                            .fill(Color.accentColor)
                    } else if isSelected {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                    } else if day.isWeekend {
                        Circle()
                            .fill(.quaternary.opacity(0.5))
                    }

                    Text("\(day.dayNumber)")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(day.isToday ? .bold : .regular)
                        .foregroundStyle(day.isToday ? .white : .primary)
                }
                .frame(width: 36, height: 36)

                // Event indicators
                HStack(spacing: 2) {
                    ForEach(eventColors.prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var weekdayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date)
    }
}

#Preview {
    let calendar = Calendar.current
    let months = (1...12).compactMap { month -> MonthData? in
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = 1
        guard let date = calendar.date(from: components) else { return nil }
        return MonthData(date: date, calendar: calendar)
    }

    return NavigationStack {
        VerticalListLayout(
            months: months,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
}
