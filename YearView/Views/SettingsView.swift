import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showManageCalendars = false
    
    var body: some View {
        @Bindable var settings = appSettings
        
        Form {
            // MARK: - Calendar Settings
            Section {
                Button {
                    showManageCalendars = true
                } label: {
                    Label("Manage Calendars", systemImage: "checklist")
                }
                .sheet(isPresented: $showManageCalendars) {
                    NavigationStack {
                        CalendarSelectionView()
                    }
                    #if os(macOS)
                    .frame(minWidth: 400, minHeight: 500)
                    #endif
                }
                
                Picker("Week Starts On", selection: $settings.weekStartsOn) {
                    ForEach(WeekStartDay.allCases) { day in
                        Text(day.name).tag(day)
                    }
                }
            } header: {
                Label("Calendar", systemImage: "calendar")
            }
            
            // MARK: - Event Display
            Section {
                Toggle("Show All-Day Events", isOn: $settings.showAllDayEvents)
                Toggle("Show Time-Based Events", isOn: $settings.showTimeBasedEvents)
            } header: {
                Label("Event Display", systemImage: "calendar.badge.clock")
            }
            
            // MARK: - Background Colors
            Section {
                ColorPicker("Page Background", selection: $settings.pageBackgroundColor, supportsOpacity: true)
                ColorPicker("Weekday Background", selection: $settings.weekdayBackgroundColor, supportsOpacity: true)
                ColorPicker("Weekend Background", selection: $settings.weekendBackgroundColor, supportsOpacity: true)
                ColorPicker("Unused Cells", selection: $settings.unusedCellColor, supportsOpacity: true)
                ColorPicker("Today Highlight", selection: $settings.todayColor, supportsOpacity: false)
            } header: {
                Label("Background Colors", systemImage: "square.filled.on.square")
            }
            
            // MARK: - Text Colors
            Section {
                ColorPicker("Date Labels", selection: $settings.dateLabelColor, supportsOpacity: false)
                ColorPicker("Column Headings", selection: $settings.columnHeadingColor, supportsOpacity: false)
                ColorPicker("Row Headings", selection: $settings.rowHeadingColor, supportsOpacity: false)
            } header: {
                Label("Text Colors", systemImage: "textformat")
            }
            
            // MARK: - Month Rows View
            Section {
                Picker("Month Label Format", selection: $settings.monthLabelFormat) {
                    ForEach(MonthLabelFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                Picker("Month Label Size", selection: $settings.monthLabelFontSize) {
                    ForEach(MonthLabelFontSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                Toggle("Show Events", isOn: $settings.showMonthRowEvents)
            } header: {
                Label("Month Rows View", systemImage: "rectangle.grid.1x2")
            }
            
            // MARK: - Gridlines
            Section {
                ColorPicker("Gridline Color", selection: $settings.gridlineColor, supportsOpacity: true)
                Toggle("Year View", isOn: $settings.showGridlinesBigYear)
                Toggle("Month Rows View", isOn: $settings.showGridlinesMonthRows)
                Toggle("Grid View", isOn: $settings.showGridlinesGrid)
                Toggle("Row View", isOn: $settings.showGridlinesRow)
                Toggle("List View", isOn: $settings.showGridlinesList)
            } header: {
                Label("Gridlines", systemImage: "grid")
            }
            
            // MARK: - Reset
            Section {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 600)
        #endif
    }
    
    private func resetToDefaults() {
        let defaults = AppSettings()
        appSettings.weekStartsOn = defaults.weekStartsOn
        appSettings.pageBackgroundColor = defaults.pageBackgroundColor
        appSettings.weekdayBackgroundColor = defaults.weekdayBackgroundColor
        appSettings.weekendBackgroundColor = defaults.weekendBackgroundColor
        appSettings.unusedCellColor = defaults.unusedCellColor
        appSettings.dateLabelColor = defaults.dateLabelColor
        appSettings.columnHeadingColor = defaults.columnHeadingColor
        appSettings.rowHeadingColor = defaults.rowHeadingColor
        appSettings.todayColor = defaults.todayColor
        appSettings.gridlineColor = defaults.gridlineColor
        appSettings.showGridlinesBigYear = defaults.showGridlinesBigYear
        appSettings.showGridlinesMonthRows = defaults.showGridlinesMonthRows
        appSettings.showGridlinesGrid = defaults.showGridlinesGrid
        appSettings.showGridlinesRow = defaults.showGridlinesRow
        appSettings.showGridlinesList = defaults.showGridlinesList
        appSettings.monthLabelFormat = defaults.monthLabelFormat
        appSettings.monthLabelFontSize = defaults.monthLabelFontSize
        appSettings.showMonthRowEvents = defaults.showMonthRowEvents
        appSettings.showAllDayEvents = defaults.showAllDayEvents
        appSettings.showTimeBasedEvents = defaults.showTimeBasedEvents
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
        .environment(CalendarViewModel())
}
