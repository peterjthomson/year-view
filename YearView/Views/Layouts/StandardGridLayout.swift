import SwiftUI

struct StandardGridLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
        Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(months) { month in
                    MonthGridView(
                        month: month,
                        selectedDate: selectedDate,
                        onDateTap: onDateTap
                    )
                }
            }
            .padding()
        }
        .background(Color.systemGroupedBackground)
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
}
