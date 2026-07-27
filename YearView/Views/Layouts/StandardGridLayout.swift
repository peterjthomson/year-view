import SwiftUI

struct StandardGridLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(AppSettings.self) private var appSettings
    @Environment(CalendarViewModel.self) private var calendarViewModel

    /// The month containing today, if today is in the displayed year
    private var todayMonth: MonthData? {
        let today = Date()
        return months.first {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .month)
        }
    }

    private var columns: Int {
        #if os(macOS)
        return 4
        #else
        switch horizontalSizeClass {
        case .regular:
            return 4 // iPad landscape or larger iPhones in landscape
        default:
            return 3 // iPhone portrait
        }
        #endif
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .topLeading), count: columns)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 16) {
                    ForEach(months) { month in
                        MonthGridView(
                            month: month,
                            selectedDate: selectedDate,
                            appSettings: appSettings,
                            onDateTap: onDateTap
                        )
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .id(month.id)
                    }
                }
                .padding()
            }
            .background(appSettings.pageBackgroundColor)
            .onChange(of: calendarViewModel.scrollToTodayToken) {
                guard let month = todayMonth else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(month.id, anchor: .center)
                }
            }
        }
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
        StandardGridLayout(
            months: months,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
