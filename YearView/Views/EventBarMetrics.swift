import SwiftUI

/// Shared sizing for calendar event bars and their overflow indicators.
struct EventBarMetrics {
    let barHeight: CGFloat
    let cellHeight: CGFloat
    let topInset: CGFloat
    let spacing: CGFloat = 2

    init(fontSize: CGFloat, cellHeight: CGFloat, topInset: CGFloat? = nil) {
        self.init(
            barHeight: fontSize <= 1 ? 1 : ceil(fontSize * 1.25 + 1),
            cellHeight: cellHeight,
            topInset: topInset ?? max(1, min(6, cellHeight * 0.2)) + 14
        )
    }

    init(barHeight: CGFloat, cellHeight: CGFloat, topInset: CGFloat) {
        self.barHeight = barHeight
        self.cellHeight = cellHeight
        self.topInset = topInset
    }

    var capacity: Int { capacity(bottomInset: 2) }

    /// Reserve bottom space only when overflow uses a count, not a corner dot.
    func visibleCapacity(requiredRows: Int, cellWidth: CGFloat) -> Int {
        let showsCount = EventOverflowIndicator.showsCount(in: CGSize(width: cellWidth, height: cellHeight))
        return requiredRows > capacity && showsCount ? capacity(bottomInset: 12) : capacity
    }

    private func capacity(bottomInset: CGFloat) -> Int {
        max(0, Int(floor((cellHeight - topInset - bottomInset + spacing) / (barHeight + spacing))))
    }
}

struct EventOverflowIndicator: View {
    let count: Int
    let cellSize: CGSize
    var color: Color = .primary

    static func showsCount(in cellSize: CGSize) -> Bool {
        cellSize.width >= 28 && cellSize.height >= 30
    }

    var body: some View {
        Group {
            if Self.showsCount(in: cellSize) {
                Text("+\(count)")
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: max(0, cellSize.width - 4), height: 10)
                    .frame(width: cellSize.width, height: cellSize.height, alignment: .bottom)
            } else {
                Circle()
                    .frame(width: 3, height: 3)
                    .padding(2)
                    .frame(width: cellSize.width, height: cellSize.height, alignment: .topTrailing)
            }
        }
        .foregroundStyle(color)
        .accessibilityLabel("\(count) more event\(count == 1 ? "" : "s")")
        .accessibilityHint("Select this day to view all events")
        .allowsHitTesting(false)
    }
}
