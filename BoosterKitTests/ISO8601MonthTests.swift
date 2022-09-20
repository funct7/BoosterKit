//
//  ISO8601MonthTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import XCTest
import BoosterKit
import Nimble

// TODO: test methods where the created ISO8601Month and provided arguments are in different time zones
class ISO8601MonthTests : XCTestCase {
    
    typealias SUT = ISO8601Month
    
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
        expect(SUT()).to(equal(SUT(date: Date())))

        let sut_sep7 = SUT(date: date_sep7)
        let stringRepresentation = "2022-09"
        
        expect(sut_sep7.description).to(equal(stringRepresentation))
        expect(sut_sep7).to(equal(sut_sep7))
        
        let sut2 = try SUT(year: 2022, month: 9)
        expect(sut2.description).to(equal(stringRepresentation))
        expect(sut2).to(equal(sut2))
        expect(sut2).to(equal(sut_sep7))
        expect(sut_sep7).to(equal(sut2))
        
        expect(try SUT(year: 2022, month: 13)).to(throwError(BoosterKitError.illegalArgument))
        
        let sut3 = try SUT(string: stringRepresentation)
        expect(sut3.description).to(equal(stringRepresentation))
        expect(sut3).to(equal(sut3))
        expect(sut3).to(equal(sut2))
        expect(sut3).to(equal(sut_sep7))
    }
    
    func test_instantRange() throws {
        let sut_sep = SUT(date: date_sep7)
        let date_sep1 = cal.date(from: DateComponents(year: 2022, month: 9))!,
            date_oct1 = cal.date(from: DateComponents(year: 2022, month: 10))!
        let sut_oct = SUT(date: date_oct1)
        
        XCTAssertEqual(sut_sep.instantRange, date_sep1 ..< date_oct1)
        XCTAssertEqual(sut_sep.instantRange.upperBound, sut_oct.instantRange.lowerBound)
    }
    
    func test_timeZone() {
        XCTAssertEqual(SUT().timeZone, .autoupdatingCurrent)
        
        [TimeZone(identifier: "Asia/Seoul")!,
         TimeZone(identifier: "Asia/Tokyo")!,
         TimeZone(identifier: "Asia/Hong_Kong")!,]
            .forEach { tz in
                XCTAssertEqual(ISO8601Month(timeZone: tz).timeZone, tz)
            }
    }
    
    func test_containsInstant() {
        XCTAssertTrue(SUT().contains(instant: Date()))
        
        let date_sep1 = cal.date(from: DateComponents(year: 2022, month: 9, day: 1))!,
            date_aug31 = date_sep1.addingTimeInterval(-0.001),
            date_oct1 = cal.date(from: DateComponents(year: 2022, month: 10, day: 1))!,
            date_sep30 = date_oct1.addingTimeInterval(-0.001)
        
        let sut_aug = SUT(date: date_aug31),
            sut_sep1 = SUT(date: date_sep1),
            sut_sep30 = SUT(date: date_sep30),
            sut_oct = SUT(date: date_oct1)
        
        XCTAssertTrue(sut_aug.contains(instant: date_aug31))
        XCTAssertFalse(sut_aug.contains(instant: date_sep1))
        XCTAssertFalse(sut_aug.contains(instant: date_sep30))
        XCTAssertFalse(sut_aug.contains(instant: date_oct1))
        
        XCTAssertFalse(sut_sep1.contains(instant: date_aug31))
        XCTAssertTrue(sut_sep1.contains(instant: date_sep1))
        XCTAssertTrue(sut_sep1.contains(instant: date_sep30))
        XCTAssertFalse(sut_sep1.contains(instant: date_oct1))
        
        XCTAssertFalse(sut_sep30.contains(instant: date_aug31))
        XCTAssertTrue(sut_sep30.contains(instant: date_sep1))
        XCTAssertTrue(sut_sep30.contains(instant: date_sep30))
        XCTAssertFalse(sut_sep30.contains(instant: date_oct1))
        
        XCTAssertFalse(sut_oct.contains(instant: date_aug31))
        XCTAssertFalse(sut_oct.contains(instant: date_sep1))
        XCTAssertFalse(sut_oct.contains(instant: date_sep30))
        XCTAssertTrue(sut_oct.contains(instant: date_oct1))
    }
    
    func test_equatable() throws {
        let sep_ko = try ISO8601Month(year: 2022, month: 9, timeZone: .seoul),
            sep_jp = try ISO8601Month(year: 2022, month: 9, timeZone: .tokyo)
        
        XCTAssertNotEqual(sep_ko, sep_jp)
        XCTAssertEqual(sep_ko, sep_ko)
        XCTAssertEqual(sep_jp, sep_jp)
    }
    
    func test_hashable() {
        var set = Set<SUT>()
        let sut = SUT(date: date_sep7)
        
        stride(
            from: sut.instantRange.lowerBound.timeIntervalSinceReferenceDate,
            to: sut.instantRange.upperBound.timeIntervalSinceReferenceDate,
            by: FixedTimeInterval.day(1).value)
            .forEach {
                set.insert(SUT(date: Date(timeIntervalSinceReferenceDate: $0)))
            }
        
        expect(set).to(haveCount(1))
        
        set.insert(SUT(date: sut.instantRange.upperBound))
        
        expect(set).to(haveCount(2))
    }

    func test_comparable() throws {
        // When same time zone
        let year = 2022, month = 9
        let sut_aug_ko = try ISO8601Month(year: year, month: month-1, timeZone: .seoul),
            sut_sep_ko = try ISO8601Month(year: year, month: month, timeZone: .seoul),
            sut_oct_ko = try ISO8601Month(year: year, month: month+1, timeZone: .seoul)
        
        XCTAssertFalse(sut_aug_ko < sut_aug_ko)
        XCTAssertFalse(sut_aug_ko > sut_aug_ko)
        
        XCTAssertTrue(sut_aug_ko < sut_sep_ko)
        XCTAssertFalse(sut_aug_ko > sut_sep_ko)
        
        XCTAssertFalse(sut_sep_ko < sut_aug_ko)
        XCTAssertTrue(sut_sep_ko > sut_aug_ko)
        
        XCTAssertTrue(sut_aug_ko < sut_oct_ko)
        XCTAssertFalse(sut_aug_ko > sut_oct_ko)
        
        XCTAssertFalse(sut_oct_ko < sut_aug_ko)
        XCTAssertTrue(sut_oct_ko > sut_aug_ko)
        
        XCTAssertTrue(sut_sep_ko < sut_oct_ko)
        XCTAssertFalse(sut_sep_ko > sut_oct_ko)
        
        XCTAssertFalse(sut_oct_ko < sut_sep_ko)
        XCTAssertTrue(sut_oct_ko > sut_sep_ko)
        
        // When different time zone with same offset
        let sut_sep_jp = try ISO8601Month(year: year, month: month, timeZone: .tokyo)
        XCTAssertFalse(sut_sep_ko < sut_sep_jp)
        XCTAssertFalse(sut_sep_ko > sut_sep_jp)
        XCTAssertFalse(sut_sep_jp < sut_sep_ko)
        XCTAssertFalse(sut_sep_jp > sut_sep_ko)
        
        XCTAssertTrue(sut_sep_jp != sut_sep_ko) // different time zone, so not equal
        XCTAssertFalse(sut_sep_jp == sut_sep_ko)
        XCTAssertTrue(sut_sep_jp.instantRange == sut_sep_ko.instantRange)
        
        XCTAssertTrue(sut_aug_ko < sut_sep_jp)
        XCTAssertTrue(sut_sep_jp < sut_oct_ko)
        
        // When different time zone
        let sut_aug_hk = try ISO8601Month(year: year, month: month-1, timeZone: .hongKong),
            sut_sep_hk = try ISO8601Month(year: year, month: month, timeZone: .hongKong),
            sut_oct_hk = try ISO8601Month(year: year, month: month+1, timeZone: .hongKong)
        
        XCTAssertTrue(sut_aug_ko < sut_aug_hk)
        XCTAssertFalse(sut_aug_ko > sut_aug_hk)
        XCTAssertFalse(sut_aug_hk < sut_aug_ko)
        XCTAssertTrue(sut_aug_hk > sut_aug_ko)
        
        XCTAssertTrue(sut_sep_ko < sut_sep_hk)
        XCTAssertFalse(sut_sep_ko > sut_sep_hk)
        XCTAssertFalse(sut_sep_hk < sut_sep_ko)
        XCTAssertTrue(sut_sep_hk > sut_sep_ko)
        
        XCTAssertTrue(sut_oct_ko < sut_oct_hk)
        XCTAssertFalse(sut_oct_ko > sut_oct_hk)
        XCTAssertFalse(sut_oct_hk < sut_oct_ko)
        XCTAssertTrue(sut_oct_hk > sut_oct_ko)
    }
    
    // A working implementation of `distance(to:)` could not be achieved,
    // since there is no meaningful distance for instances whose time zones differ.
    // For this reason, `Strideable` conformance is dropped,
    // and methods with similar signatures are provided.
    func test_strideableLike() throws {
        let sut_jan2020_ko = try ISO8601Month(year: 2020, month: 1, timeZone: .seoul),
            sut_dec2020_ko = try ISO8601Month(year: 2020, month: 12, timeZone: .seoul),
            sut_jan2021_ko = try ISO8601Month(year: 2021, month: 1, timeZone: .seoul)
        
        XCTAssertEqual(sut_jan2020_ko.advanced(by: 11), sut_dec2020_ko)
        XCTAssertEqual(sut_jan2020_ko.advanced(by: 12), sut_jan2021_ko)
        XCTAssertEqual(sut_dec2020_ko.advanced(by: 0), sut_dec2020_ko)
        XCTAssertEqual(sut_dec2020_ko.advanced(by: -11), sut_jan2020_ko)
        XCTAssertEqual(sut_jan2021_ko.advanced(by: -12), sut_jan2020_ko)
        
        XCTAssertEqual(try sut_jan2020_ko.distance(to: sut_dec2020_ko), 11)
        XCTAssertEqual(try sut_jan2020_ko.distance(to: sut_jan2021_ko), 12)

        XCTAssertEqual(try sut_dec2020_ko.distance(to: sut_jan2020_ko), -11)
        XCTAssertEqual(try sut_jan2021_ko.distance(to: sut_jan2020_ko), -12)
        
        let sut_jan2020_jp = try ISO8601Month(year: 2020, month: 1, timeZone: .tokyo),
            sut_dec2020_jp = try ISO8601Month(year: 2020, month: 12, timeZone: .tokyo)
        
        XCTAssertNotEqual(sut_jan2020_ko.advanced(by: 0), sut_jan2020_jp)
        XCTAssertEqual(try sut_jan2020_ko.distance(to: sut_jan2020_jp), 0)
        XCTAssertEqual(try sut_jan2020_ko.distance(to: sut_dec2020_jp), 11)
        
        let sut_jan2020_hk = try ISO8601Month(year: 2020, month: 1, timeZone: .hongKong)
        expect(try sut_jan2020_hk.distance(to: sut_jan2020_ko)).to(throwError(BoosterKitError.illegalArgument))
    }
    
    func test_initWithDate() throws {
        let jan1_2022 = try ISO8601Date(year: 2022, month: 1, day: 1, timeZone: .tokyo),
            mar23_2023 = try ISO8601Date(year: 2023, month: 3, day: 23)

        XCTAssertEqual(ISO8601Month(date: jan1_2022), try ISO8601Month(year: 2022, month: 1, timeZone: .tokyo))
        XCTAssertEqual(ISO8601Month(date: mar23_2023), try ISO8601Month(year: 2023, month: 3))
    }

}
