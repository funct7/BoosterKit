//
//  FixedTimeIntervalTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import XCTest
import BoosterKit

class FixedTimeIntervalTests : XCTestCase {
    
    typealias SUT = FixedTimeInterval
    
    func test_value() {
        let secInMillis = 0.001,
            secInMin = 60.0,
            secInHour = secInMin * 60.0,
            secInDay = secInHour * 24.0
        
        XCTAssertEqual(SUT.millisecond(1).value, secInMillis)
        XCTAssertEqual(SUT.millisecond(16).value, 16 * secInMillis)
        
        XCTAssertEqual(SUT.second(1).value, 1)
        XCTAssertEqual(SUT.second(16).value, 16.0)
        
        XCTAssertEqual(SUT.minute(1).value, secInMin)
        XCTAssertEqual(SUT.minute(16).value, 16.0 * secInMin)
        
        XCTAssertEqual(SUT.hour(1).value, secInHour)
        XCTAssertEqual(SUT.hour(16).value, 16.0 * secInHour)
        
        XCTAssertEqual(SUT.day(1).value, secInDay)
        XCTAssertEqual(SUT.day(16).value, 16.0 * secInDay)
    }
    
}
