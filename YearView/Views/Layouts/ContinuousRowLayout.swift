import SwiftUI

struct ContinuousRowLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @State private var scrollPosition: Int?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                        MonthColumnView(
                            month: month,
                            selectedDate: selectedDate,
                            onDateTap: onDateTap,
                            height: geometry.size.height
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, 24)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
        }
        .background(Color.systemGroupedBackground)
        .onAppear {
            // Scroll to current month
            let currentMonth = Calendar.current.component(.month, from: Date()) - 1
            scrollPosition = currentMonth
        }
    }
}

struct MonthColumnView: View {
    let month: MonthData
    let selectedDate: Date?
    let onDateTap: (Date) -> Void
    let height: CGFloat

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            Text(month.name)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 4)

            // Days in vertical list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(month.days) { day in
                        DayRowView(
                            day: day,
                            events: calendarViewModel.events(for: day.date),
                            isSelected: isSelected(day.date),
                            onTap: { onDateTap(day.date) }
                        )
                    }
                }
            }
        }
        .frame(width: 280)
        .padding(.vertical)
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct DayRowView: View {
    let day: DayData
    let events: [CalendarEvent]
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Day number and weekday
                VStack(alignment: .center, spacing: 2) {
                    Text(weekdayAbbreviation)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    ZStack {
                        if day.isToday {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 32, height: 32)
                        } else if isSelected {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }

                        Text("\(day.dayNumber)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundStyle(day.isToday ? .white : .primary)
                    }
                    .frame(width: 32, height: 32)
                }
                .frame(width: 40)

                // Events
                if events.isEmpty {
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(events.prefix(3)) { event in
                            EventRowCompact(event: event)
                        }

                        if events.count > 3 {
                            Text("+\(events.count - 3) more")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background {
                if day.isWeekend {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary.opacity(0.3))
                }
            }
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
        ContinuousRowLayout(
            months: months,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
}
