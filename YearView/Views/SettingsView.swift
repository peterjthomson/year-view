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
                    .frame(minWidth: 400, minHeight: 500)
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
        appSettings.weekStartsOn = .monday
        appSettings.pageBackgroundColor = Color.systemBackground
        appSettings.weekdayBackgroundColor = .clear
        appSettings.weekendBackgroundColor = Color.secondarySystemGroupedBackground.opacity(0.5)
        appSettings.unusedCellColor = Color.secondarySystemGroupedBackground.opacity(0.3)
        appSettings.dateLabelColor = .primary
        appSettings.columnHeadingColor = .secondary
        appSettings.rowHeadingColor = .primary
        appSettings.todayColor = .accentColor
        appSettings.gridlineColor = Color.separator.opacity(0.5)
        appSettings.showGridlinesBigYear = true
        appSettings.showGridlinesMonthRows = true
        appSettings.showGridlinesGrid = false
        appSettings.showGridlinesRow = false
        appSettings.showGridlinesList = false
        appSettings.monthLabelFormat = .letter
        appSettings.monthLabelFontSize = .medium
        appSettings.showAllDayEvents = true
        appSettings.showTimeBasedEvents = false
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}
