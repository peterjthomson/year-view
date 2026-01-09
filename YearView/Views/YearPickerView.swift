import SwiftUI

struct YearPickerView: View {
    @Binding var selectedYear: Int
    @Environment(\.dismiss) private var dismiss

    private let currentYear = Calendar.current.component(.year, from: Date())
    private let yearRange: [Int]

    init(selectedYear: Binding<Int>) {
        self._selectedYear = selectedYear
        // Show 10 years before and 10 years after current year
        let start = Calendar.current.component(.year, from: Date()) - 10
        let end = Calendar.current.component(.year, from: Date()) + 10
        self.yearRange = Array(start...end)
    }

    var body: some View {
        List(yearRange, id: \.self) { year in
            Button {
                selectedYear = year
                dismiss()
            } label: {
                HStack {
                    Text(String(year))
                        .font(.body)
                        .fontWeight(year == currentYear ? .semibold : .regular)

                    if year == currentYear {
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if year == selectedYear {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                            .fontWeight(.semibold)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Year \(year)")
            .accessibilityValue(year == selectedYear ? "selected" : "")
            .accessibilityAddTraits(year == selectedYear ? .isSelected : [])
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .scrollContentBackground(.visible)
        .onAppear {
            // This would ideally scroll to selected year
            // ScrollViewReader can be used for this in a real implementation
        }
    }
}

#Preview {
    NavigationStack {
        YearPickerView(selectedYear: .constant(2026))
            .navigationTitle("Select Year")
    }
}
