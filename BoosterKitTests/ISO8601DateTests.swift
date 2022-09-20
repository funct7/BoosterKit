//
//  ISO8601DateTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import XCTest
import BoosterKit
import Nimble

// TODO: test methods where the created ISO8601Date and provided arguments are in different time zones
class ISO8601DateTests : XCTestCase {

    var cal: Calendar!
    var dc_sep7: DateComponents!
    var date_sep7: Date!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cal = Calendar(identifier: .gregorian)
        dc_sep7 = DateComponents(year: 2022, month: 9, day: 7)
        date_sep7 = cal.date(from: dc_sep7)!
    }

    func test_initializer() throws {
        expect(ISO8601Date()).to(equal(ISO8601Date(date: Date())))

        let sut_sep7 = ISO8601Date(date: date_sep7)
        let stringRepresentation = "2022-09-07"
        
        expect(sut_sep7.description).to(equal(stringRepresentation))
        expect(sut_sep7).to(equal(sut_sep7))
        
        let sut2 = try ISO8601Date(year: 2022, month: 9, day: 7)
        expect(sut2.description).to(equal(stringRepresentation))
        expect(sut2).to(equal(sut2))
        expect(sut2).to(equal(sut_sep7))
        expect(sut_sep7).to(equal(sut2))
        
        expect(try ISO8601Date(year: 2022, month: 9, day: 31)).to(throwError(BoosterKitError.illegalArgument))
        
        let sut3 = try ISO8601Date(string: stringRepresentation)
        expect(sut3.description).to(equal(stringRepresentation))
        expect(sut3).to(equal(sut3))
        expect(sut3).to(equal(sut2))
        expect(sut3).to(equal(sut_sep7))
    }
    
    func test_instantRange() throws {
        let sut_sep7 = ISO8601Date(date: date_sep7)
        let date_sep8 = date_sep7.adding(.day(1))
        let sut_sep8 = ISO8601Date(date: date_sep8)
        
        XCTAssertEqual(sut_sep7.instantRange, date_sep7 ..< date_sep8)
        XCTAssertEqual(sut_sep7.instantRange.upperBound, sut_sep8.instantRange.lowerBound)
    }
    
    func test_timeZone() {
        XCTAssertEqual(ISO8601Date().timeZone, .autoupdatingCurrent)
        
        [TimeZone(identifier: "Asia/Seoul")!,
         TimeZone(identifier: "Asia/Tokyo")!,
         TimeZone(identifier: "Asia/Hong_Kong")!,]
            .forEach { tz in
                XCTAssertEqual(ISO8601Date(timeZone: tz).timeZone, tz)
            }
    }
    
    func test_containsInstant() {
        XCTAssertTrue(ISO8601Date().contains(instant: Date()))
        
        let date_sep6 = date_sep7.addingTimeInterval(-0.001),
            date_sep7_2 = cal.date(from: withVar(dc_sep7) { $0.hour = 8 })!,
            date_sep8 = cal.date(from: withVar(dc_sep7) { $0.day = 8 })!,
            date_sep7_3 = date_sep8.addingTimeInterval(-0.001)
        
        let sut_sep6 = ISO8601Date(date: date_sep6),
            sut_sep7 = ISO8601Date(date: date_sep7),
            sut_sep8 = ISO8601Date(date: date_sep8)
        
        XCTAssertTrue(sut_sep6.contains(instant: date_sep6))
        XCTAssertFalse(sut_sep6.contains(instant: date_sep7))
        XCTAssertFalse(sut_sep6.contains(instant: date_sep8))
        
        XCTAssertFalse(sut_sep7.contains(instant: date_sep6))
        XCTAssertTrue(sut_sep7.contains(instant: date_sep7))
        XCTAssertTrue(sut_sep7.contains(instant: date_sep7_2))
        XCTAssertTrue(sut_sep7.contains(instant: date_sep7_3))
        XCTAssertFalse(sut_sep7.contains(instant: date_sep8))
        
        XCTAssertFalse(sut_sep8.contains(instant: date_sep6))
        XCTAssertFalse(sut_sep8.contains(instant: date_sep7_3))
        XCTAssertTrue(sut_sep8.contains(instant: date_sep8))
    }
    
    func test_hashable() {
        var set = Set<ISO8601Date>()
        let sut = ISO8601Date(date: date_sep7)
        
        stride(
            from: sut.instantRange.lowerBound.timeIntervalSinceReferenceDate,
            to: sut.instantRange.upperBound.timeIntervalSinceReferenceDate,
            by: 60.0)
            .forEach {
                set.insert(ISO8601Date(date: Date(timeIntervalSinceReferenceDate: $0)))
            }
        
        expect(set).to(haveCount(1))
        
        set.insert(ISO8601Date(date: sut.instantRange.upperBound))
        
        expect(set).to(haveCount(2))
    }
    
    func test_comparable() throws {
        // When same time zone
        let year = 2022, month = 9, day = 18
        let sut_sep17_ko = try ISO8601Date(year: year, month: month, day: day-1, timeZone: .seoul),
            sut_sep18_ko = try ISO8601Date(year: year, month: month, day: day, timeZone: .seoul),
            sut_sep19_ko = try ISO8601Date(year: year, month: month, day: day+1, timeZone: .seoul)
        
        XCTAssertFalse(sut_sep17_ko < sut_sep17_ko)
        XCTAssertFalse(sut_sep17_ko > sut_sep17_ko)
        
        XCTAssertTrue(sut_sep17_ko < sut_sep18_ko)
        XCTAssertFalse(sut_sep17_ko > sut_sep18_ko)
        
        XCTAssertFalse(sut_sep18_ko < sut_sep17_ko)
        XCTAssertTrue(sut_sep18_ko > sut_sep17_ko)
        
        XCTAssertTrue(sut_sep17_ko < sut_sep19_ko)
        XCTAssertFalse(sut_sep17_ko > sut_sep19_ko)
        
        XCTAssertFalse(sut_sep19_ko < sut_sep17_ko)
        XCTAssertTrue(sut_sep19_ko > sut_sep17_ko)
        
        XCTAssertTrue(sut_sep18_ko < sut_sep19_ko)
        XCTAssertFalse(sut_sep18_ko > sut_sep19_ko)
        
        XCTAssertFalse(sut_sep19_ko < sut_sep18_ko)
        XCTAssertTrue(sut_sep19_ko > sut_sep18_ko)
        
        // When different time zone with same offset
        let sut_sep18_jp = try ISO8601Date(year: year, month: month, day: day, timeZone: .tokyo)
        XCTAssertFalse(sut_sep18_ko < sut_sep18_jp)
        XCTAssertFalse(sut_sep18_ko > sut_sep18_jp)
        XCTAssertFalse(sut_sep18_jp < sut_sep18_ko)
        XCTAssertFalse(sut_sep18_jp > sut_sep18_ko)
        
        XCTAssertTrue(sut_sep18_jp != sut_sep18_ko) // different time zone, so not equal
        XCTAssertFalse(sut_sep18_jp == sut_sep18_ko)
        XCTAssertTrue(sut_sep18_jp.instantRange == sut_sep18_ko.instantRange)
        
        XCTAssertTrue(sut_sep17_ko < sut_sep18_jp)
        XCTAssertTrue(sut_sep18_jp < sut_sep19_ko)
        
        // When different time zone
        let sut_sep17_hk = try ISO8601Date(year: year, month: month, day: day-1, timeZone: .hongKong),
            sut_sep18_hk = try ISO8601Date(year: year, month: month, day: day, timeZone: .hongKong),
            sut_sep19_hk = try ISO8601Date(year: year, month: month, day: day+1, timeZone: .hongKong)
        
        XCTAssertTrue(sut_sep17_ko < sut_sep17_hk)
        XCTAssertFalse(sut_sep17_ko > sut_sep17_hk)
        XCTAssertFalse(sut_sep17_hk < sut_sep17_ko)
        XCTAssertTrue(sut_sep17_hk > sut_sep17_ko)
        
        XCTAssertTrue(sut_sep18_ko < sut_sep18_hk)
        XCTAssertFalse(sut_sep18_ko > sut_sep18_hk)
        XCTAssertFalse(sut_sep18_hk < sut_sep18_ko)
        XCTAssertTrue(sut_sep18_hk > sut_sep18_ko)
        
        XCTAssertTrue(sut_sep19_ko < sut_sep19_hk)
        XCTAssertFalse(sut_sep19_ko > sut_sep19_hk)
        XCTAssertFalse(sut_sep19_hk < sut_sep19_ko)
        XCTAssertTrue(sut_sep19_hk > sut_sep19_ko)
    }
    
    // A working implementation of `distance(to:)` could not be achieved,
    // since there is no meaningful distance for instances whose time zones differ.
    // For this reason, `Strideable` conformance is dropped,
    // and methods with similar signatures are provided.
    func test_strideableLike() throws {
        let sut_feb1_ko = try ISO8601Date(year: 2020, month: 2, day: 1, timeZone: .seoul),
            sut_feb29_ko = try ISO8601Date(year: 2020, month: 2, day: 29, timeZone: .seoul),
            sut_mar1_ko = try ISO8601Date(year: 2020, month: 3, day: 1, timeZone: .seoul)
        
        XCTAssertEqual(sut_feb1_ko.advanced(by: 28), sut_feb29_ko)
        XCTAssertEqual(sut_feb1_ko.advanced(by: 29), sut_mar1_ko)
        XCTAssertEqual(sut_feb29_ko.advanced(by: 0), sut_feb29_ko)
        XCTAssertEqual(sut_feb29_ko.advanced(by: -28), sut_feb1_ko)
        XCTAssertEqual(sut_mar1_ko.advanced(by: -29), sut_feb1_ko)
        
        XCTAssertEqual(try sut_feb1_ko.distance(to: sut_feb29_ko), 28)
        XCTAssertEqual(try sut_feb1_ko.distance(to: sut_mar1_ko), 29)

        XCTAssertEqual(try sut_feb29_ko.distance(to: sut_feb1_ko), -28)
        XCTAssertEqual(try sut_mar1_ko.distance(to: sut_feb1_ko), -29)
        
        let sut_feb1_jp = try ISO8601Date(year: 2020, month: 2, day: 1, timeZone: .tokyo),
            sut_feb29_jp = try ISO8601Date(year: 2020, month: 2, day: 29, timeZone: .tokyo)
        
        XCTAssertNotEqual(sut_feb1_ko.advanced(by: 0), sut_feb1_jp)
        XCTAssertEqual(try sut_feb1_ko.distance(to: sut_feb1_jp), 0)
        XCTAssertEqual(try sut_feb1_ko.distance(to: sut_feb29_jp), 28)
        
        let sut_feb1_hk = try ISO8601Date(year: 2020, month: 2, day: 1, timeZone: .hongKong)
        expect(try sut_feb1_hk.distance(to: sut_feb1_ko)).to(throwError(BoosterKitError.illegalArgument))
    }
    
    func test_components() throws {
        let jan1_2022 = try ISO8601Date(year: 2022, month: 1, day: 1),
            mar23_2023 = try ISO8601Date(year: 2023, month: 3, day: 23, timeZone: .tokyo)
        
        XCTAssertEqual(jan1_2022.dateComponents([.year, .month, .day, .hour, .second]), DateComponents(timeZone: .autoupdatingCurrent, year: 2022, month: 1, day: 1))
        XCTAssertEqual(mar23_2023.dateComponents([.year, .month,]), DateComponents(timeZone: .tokyo, year: 2023, month: 3))
    }
    
    func test_month() throws {
        let sep20 = try ISO8601Date(year: 2022, month: 9, day: 20, timeZone: .hongKong),
            oct1 = try ISO8601Date(year: 2024, month: 10, day: 20)
        XCTAssertEqual(sep20.month, try ISO8601Month(year: 2022, month: 9, timeZone: .hongKong))
        XCTAssertEqual(oct1.month, try ISO8601Month(year: 2024, month: 10))
    }
    
}
