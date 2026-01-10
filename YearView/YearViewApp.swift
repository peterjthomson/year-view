import SwiftUI

@main
struct YearViewApp: App {
    @State private var calendarViewModel = CalendarViewModel()
    @State private var appSettings = AppSettings()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environment(calendarViewModel)
                .environment(appSettings)
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            MacCommands(calendarViewModel: calendarViewModel)
        }

        MenuBarExtra("Year View", systemImage: "calendar") {
            MenuBarView()
                .environment(calendarViewModel)
                .environment(appSettings)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(calendarViewModel)
                .environment(appSettings)
        }
        #else
        WindowGroup {
            ContentView()
                .environment(calendarViewModel)
                .environment(appSettings)
        }
        #endif
    }
}
