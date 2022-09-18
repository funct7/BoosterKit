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
    
}

