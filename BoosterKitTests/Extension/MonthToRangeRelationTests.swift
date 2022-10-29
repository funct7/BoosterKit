//
//  MonthToRangeRelationTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/10/29.
//

import XCTest
@testable import BoosterKit
import Nimble

class MonthToRangeRelationTests : XCTestCase {
    
    private typealias SUT = MonthToRangeRelation
    private typealias MonthRange = Pair<ISO8601Month?, ISO8601Month?>
    
    func test_factoryMethod() throws {
        do { // infinite
            let range = MonthRange(nil, nil)
            
            // the range has no notion of any time zone
            let jan1970 = try ISO8601Month(year: 1970, month: 1, timeZone: .seoul),
                oct2022 = try ISO8601Month(year: 2022, month: 10, timeZone: .tokyo),
                dec3000 = try ISO8601Month(year: 3000, month: 12, timeZone: .hongKong)
            
            XCTAssertEqual(try SUT.from(month: jan1970, range: range), .withinBounds)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .withinBounds)
            XCTAssertEqual(try SUT.from(month: dec3000, range: range), .withinBounds)
        }
        
        do { // min-bounded infinite
            let oct2022 = try ISO8601Month(year: 2022, month: 10)
            let range = MonthRange(oct2022, nil)
            
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: -1), range: range), .lessThan)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .minBound)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: 1), range: range), .withinBounds)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: 12000), range: range), .withinBounds)
        }
        
        do { // max-bounded infinite
            let oct2022 = try ISO8601Month(year: 2022, month: 10)
            let range = MonthRange(nil, oct2022)
            
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: 1), range: range), .greaterThan)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .maxBound)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: -1), range: range), .withinBounds)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: -12000), range: range), .withinBounds)
        }
        
        do { // range spanning 3+ months
            let oct2022 = try ISO8601Month(year: 2022, month: 10),
                jan2022 = try ISO8601Month(year: 2022, month: 1),
                dec2022 = try ISO8601Month(year: 2022, month: 12)
            let range = MonthRange(jan2022, dec2022)
            
            XCTAssertEqual(try SUT.from(month: jan2022.advanced(by: -1), range: range), .lessThan)
            XCTAssertEqual(try SUT.from(month: jan2022, range: range), .minBound)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .withinBounds)
            XCTAssertEqual(try SUT.from(month: dec2022, range: range), .maxBound)
            XCTAssertEqual(try SUT.from(month: dec2022.advanced(by: 1), range: range), .greaterThan)
        }
        
        do { // 2-month range
            let sep2022 = try ISO8601Month(year: 2022, month: 9),
                oct2022 = try ISO8601Month(year: 2022, month: 10)
            let range = MonthRange(sep2022, oct2022)
            
            XCTAssertEqual(try SUT.from(month: sep2022.advanced(by: -1), range: range), .lessThan)
            XCTAssertEqual(try SUT.from(month: sep2022, range: range), .minBound)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .maxBound)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: 1), range: range), .greaterThan)
        }
        
        do { // 1-month range
            let oct2022 = try ISO8601Month(year: 2022, month: 10)
            let range = MonthRange(oct2022, oct2022)
            
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: -1), range: range), .lessThan)
            XCTAssertEqual(try SUT.from(month: oct2022, range: range), .equal)
            XCTAssertEqual(try SUT.from(month: oct2022.advanced(by: 1), range: range), .greaterThan)
        }
        
        do { // Illegal arguments
            let oct2022 = try ISO8601Month(year: 2022, month: 10, timeZone: .seoul)
            
            expect(try SUT.from(month: oct2022, range: Pair(oct2022, oct2022.advanced(by: -1))))
                .to(throwAssertion())
            expect(try SUT.from(month: try ISO8601Month(year: 2022, month: 10, timeZone: .hongKong), range: Pair(oct2022, oct2022)))
                .to(throwError(BoosterKitError.illegalArgument))
        }
    }
    
}
