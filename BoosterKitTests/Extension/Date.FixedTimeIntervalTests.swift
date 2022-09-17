//
//  Date.FixedTimeIntervalTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import XCTest
import BoosterKit

class Date_FixedTimeIntervalTests : XCTestCase {
    
    func test_addingFixedTimeInterval() {
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: DateComponents(calendar: cal, year: 2022, month: 9, day: 17))!
        
        XCTAssertEqual(date.adding(.millisecond(64)), date.addingTimeInterval(0.064))
        XCTAssertEqual(date.adding(.second(30)), date.addingTimeInterval(30.0))
        XCTAssertEqual(date.adding(.minute(26)), date.addingTimeInterval(26.0 * 60.0))
        XCTAssertEqual(date.adding(.hour(7)), date.addingTimeInterval(7 * 60.0 * 60.0))
        XCTAssertEqual(date.adding(.day(3)), date.addingTimeInterval(3 * 24.0 * 60.0 * 60.0))
    }
    
}
