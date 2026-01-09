import SwiftUI

@main
struct YearViewApp: App {
    @State private var calendarViewModel = CalendarViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(calendarViewModel)
        }
        #if os(macOS)
        .commands {
            MacCommands(calendarViewModel: calendarViewModel)
        }

        MenuBarExtra("Year View", systemImage: "calendar") {
            MenuBarView()
                .environment(calendarViewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            CalendarSelectionView()
                .environment(calendarViewModel)
        }
        #endif
    }
}
