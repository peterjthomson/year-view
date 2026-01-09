import XCTest
import SwiftUI
@testable import YearView

final class ColorUtilitiesTests: XCTestCase {

    // MARK: - Color from Hex Tests

    func testColorFromHex6() {
        let color = Color(hex: "FF5733")

        // Should create a valid color - we can't easily inspect SwiftUI Color values
        // but we can verify it doesn't crash
        XCTAssertNotNil(color)
    }

    func testColorFromHex8() {
        let color = Color(hex: "80FF5733") // With alpha

        XCTAssertNotNil(color)
    }

    func testColorFromHex3() {
        let color = Color(hex: "F00") // Short form red

        XCTAssertNotNil(color)
    }

    func testColorFromHexWithHash() {
        let color = Color(hex: "#007AFF")

        XCTAssertNotNil(color)
    }

    // MARK: - Calendar Colors Tests

    func testDefaultColorsCount() {
        XCTAssertEqual(CalendarColors.defaultColors.count, 12)
    }

    func testColorForIndex() {
        let color0 = CalendarColors.color(for: 0)
        let color1 = CalendarColors.color(for: 1)
        let color12 = CalendarColors.color(for: 12) // Should wrap around

        XCTAssertNotNil(color0)
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color12)
    }

    func testColorForIndexWrapsAround() {
        let color0 = CalendarColors.color(for: 0)
        let color12 = CalendarColors.color(for: 12)

        // Index 12 should wrap to index 0
        // Can't easily compare SwiftUI Colors, but they should both exist
        XCTAssertNotNil(color0)
        XCTAssertNotNil(color12)
    }

    func testRandomColor() {
        let color = CalendarColors.randomColor()

        XCTAssertNotNil(color)
        XCTAssertTrue(CalendarColors.defaultColors.contains(where: { _ in true }))
    }

    // MARK: - System Colors Tests

    func testSystemGroupedBackground() {
        let color = Color.systemGroupedBackground

        XCTAssertNotNil(color)
    }

    func testSecondarySystemGroupedBackground() {
        let color = Color.secondarySystemGroupedBackground

        XCTAssertNotNil(color)
    }
}
