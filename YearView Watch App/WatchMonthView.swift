import SwiftUI

struct WatchMonthView: View {
    @Environment(WatchCalendarViewModel.self) private var viewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Month header with navigation
                HStack {
                    Button {
                        viewModel.goToPreviousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(monthYearString)
                        .font(.headline)

                    Spacer()

                    Button {
                        viewModel.goToNextMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                }

                // Weekday headers
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                // Days grid
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(daysInMonth, id: \.self) { day in
                        if let day = day {
                            WatchDayCell(
                                date: day,
                                isToday: calendar.isDateInToday(day),
                                hasEvents: viewModel.hasEvents(on: day)
                            )
                        } else {
                            Color.clear
                                .frame(width: 20, height: 20)
                        }
                    }
                }

                // Today button
                Button {
                    viewModel.goToToday()
                } label: {
                    Label("Today", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
            .padding(.horizontal, 4)
        }
        .digitalCrownRotation(
            detent: Binding(
                get: { Double(calendar.component(.month, from: viewModel.displayedMonth)) },
                set: { _ in }
            ),
            from: 1,
            through: 12,
            by: 1,
            sensitivity: .medium
        ) { event in
            // Digital Crown rotation to navigate months
            // This is a simplified implementation
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: viewModel.displayedMonth)
    }

    private var daysInMonth: [Date?] {
        let firstDay = calendar.firstDayOfMonth(for: viewModel.displayedMonth)
        let weekday = calendar.component(.weekday, from: firstDay)
        let daysCount = calendar.daysInMonth(for: viewModel.displayedMonth)

        var days: [Date?] = []

        // Leading empty cells
        for _ in 1..<weekday {
            days.append(nil)
        }

        // Actual days
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }
}

struct WatchDayCell: View {
    let date: Date
    let isToday: Bool
    let hasEvents: Bool

    var body: some View {
        NavigationLink {
            WatchDayDetailView(date: date)
        } label: {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                }

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 12, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? .black : .primary)
            }
            .frame(width: 20, height: 20)
            .overlay(alignment: .bottom) {
                if hasEvents && !isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 4, height: 4)
                        .offset(y: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WatchMonthView()
        .environment(WatchCalendarViewModel())
}
