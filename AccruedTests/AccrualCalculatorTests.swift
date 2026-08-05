import XCTest
@testable import Accrued

final class AccrualCalculatorTests: XCTestCase {
    let zone = TimeZone(identifier: "America/Chicago")!

    func config(mode: CompensationMode = .annual, amount: Decimal = 160000, days: Set<Int> = [2, 3, 4, 5, 6], start: Int = 480, end: Int = 960) -> AccrualConfiguration {
        AccrualConfiguration(mode: mode, amount: amount, enabledWeekdays: days, startMinutes: start, endMinutes: end, weeklyHours: 40)
    }

    func date(_ text: String) -> Date {
        let formatter = ISO8601DateFormatter(); formatter.timeZone = zone
        return formatter.date(from: text)!
    }

    func calculator(_ text: String, calendarID: Calendar.Identifier = .gregorian) -> AccrualCalculator {
        var calendar = Calendar(identifier: calendarID); calendar.timeZone = zone; calendar.locale = Locale(identifier: "en_US")
        return AccrualCalculator(calendar: calendar, timeZone: zone, now: date(text))
    }

    func assertDecimal(_ actual: Decimal, _ expected: Decimal, accuracy: Double = 0.01, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(NSDecimalNumber(decimal: actual).doubleValue, NSDecimalNumber(decimal: expected).doubleValue, accuracy: accuracy, file: file, line: line)
    }

    func testBeforeStartMidwayAndAfterEnd() {
        XCTAssertEqual(calculator("2026-06-15T12:00:00-05:00").snapshot(configuration: config()).today.progress, 0.5, accuracy: 0.001)
        XCTAssertEqual(calculator("2026-06-15T07:59:00-05:00").snapshot(configuration: config()).today.accrued, 0)
        XCTAssertEqual(calculator("2026-06-15T17:00:00-05:00").snapshot(configuration: config()).today.progress, 1)
    }

    func testDisabledWorkday() {
        XCTAssertEqual(calculator("2026-06-14T12:00:00-05:00").snapshot(configuration: config()).today.accrued, 0)
    }

    func testWeekAndMonthAggregatesAndBoundaries() {
        let snapshot = calculator("2026-06-17T12:00:00-05:00").snapshot(configuration: config())
        XCTAssertEqual(snapshot.week.progress, 0.5, accuracy: 0.001) // Monday + Tuesday + half Wednesday of five days.
        XCTAssertEqual(calculator("2026-06-01T09:00:00-05:00").snapshot(configuration: config()).month.full, snapshot.month.full, accuracy: 0.01)
        XCTAssertGreaterThan(snapshot.month.full, snapshot.week.full)
    }

    func testLeapFebruaryAndMonthBoundary() {
        let leap = calculator("2028-02-29T16:00:00-06:00").snapshot(configuration: config())
        assertDecimal(leap.month.full, Decimal(string: "12923.0769230769")!)
        XCTAssertEqual(calculator("2028-03-01T08:00:00-06:00").snapshot(configuration: config()).month.accrued, 0)
    }

    func testDSTTransitionAndCompensationModes() {
        let dst = calculator("2026-03-09T12:00:00-05:00").snapshot(configuration: config())
        XCTAssertEqual(dst.today.progress, 0.5, accuracy: 0.001)
        XCTAssertEqual(config(mode: .monthly, amount: 10000).hourlyRate, config(amount: 120000).hourlyRate)
    }

    func testInvalidInputsAndProgressClamping() {
        let invalid = config(amount: 0, days: [], start: 600, end: 500)
        let snapshot = calculator("2026-06-15T12:00:00-05:00").snapshot(configuration: invalid)
        XCTAssertEqual(snapshot.hourlyRate, 0); XCTAssertEqual(snapshot.today.progress, 0)
        XCTAssertGreaterThanOrEqual(snapshot.week.progress, 0); XCTAssertLessThanOrEqual(snapshot.week.progress, 1)
    }
}
