import SwiftUI

#if os(macOS)
struct MenuBarView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedWeekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(formattedDate)
                        .font(.headline)
                }

                Spacer()

                Button {
                    calendarViewModel.goToToday()
                    selectedDate = Date()
                } label: {
                    Text("Today")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Divider()

            // Mini month view
            MiniMonthView(
                selectedDate: $selectedDate,
                onDateSelect: { date in
                    // Could open main window at this date
                }
            )
            .padding(.horizontal)

            Divider()

            // Today's events
            if !todayEvents.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(todayEvents.prefix(5)) { event in
                        MenuBarEventRow(event: event)
                    }

                    if todayEvents.count > 5 {
                        Text("+\(todayEvents.count - 5) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                }
            } else {
                Text("No events today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Divider()

            // Quick actions
            HStack {
                Button {
                    NSWorkspace.shared.open(URL(string: "x-apple-calevent://")!)
                } label: {
                    Label("Open Calendar", systemImage: "calendar")
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
                .buttonStyle(.plain)
            }
            .font(.caption)
            .padding()
        }
        .frame(width: 280)
    }

    private var todayEvents: [CalendarEvent] {
        calendarViewModel.events(for: Date())
    }

    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
}

struct MiniMonthView: View {
    @Binding var selectedDate: Date
    let onDateSelect: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            // Month navigation
            HStack {
                Button {
                    selectedDate = selectedDate.adding(months: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthYearString)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Button {
                    selectedDate = selectedDate.adding(months: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Days grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(daysInMonth, id: \.self) { day in
                    if let day = day {
                        MiniDayCell(
                            date: day,
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(day),
                            hasEvents: calendarViewModel.hasEvents(on: day)
                        ) {
                            selectedDate = day
                            onDateSelect(day)
                        }
                    } else {
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private var daysInMonth: [Date?] {
        let firstDay = calendar.firstDayOfMonth(for: selectedDate)
        let weekday = calendar.component(.weekday, from: firstDay)
        let daysCount = calendar.daysInMonth(for: selectedDate)

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

struct MiniDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                } else if isSelected {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1)
                }

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 11))
                    .foregroundStyle(isToday ? .white : .primary)
            }
            .frame(width: 24, height: 24)
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

struct MenuBarEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.calendarColor)
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .lineLimit(1)

                if !event.isAllDay {
                    Text(timeString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            // Open in Calendar app
            if let url = URL(string: "x-apple-calevent://") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}
#endif
