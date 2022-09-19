//
//  CalendarAdapter.UICollectionViewAdapter.LayoutPlanTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/19.
//

import XCTest
@testable import BoosterKit

class CalendarAdapter_UICollectionViewAdapter_LayoutPlanTests : XCTestCase {
    
    private typealias SUT = CalendarAdapter<UICollectionViewCell>.UICollectionViewAdapter.LayoutPlan
    
    func test() throws {
        // 6-week month
        let jan2022 = try ISO8601Month(year: 2022, month: 1)
        let plan1 = SUT.create(month: jan2022)
        XCTAssertEqual(plan1.leadingDays, 6)
        XCTAssertEqual(plan1.numberOfDays, 31)
        XCTAssertEqual(plan1.numberOfWeeks, 6)
        XCTAssertEqual(plan1.trailingDays, 5)
        
        // 5-week month, no trailing days
        let apr2022 = try ISO8601Month(year: 2022, month: 4)
        let plan2 = SUT.create(month: apr2022)
        XCTAssertEqual(plan2.leadingDays, 5)
        XCTAssertEqual(plan2.numberOfDays, 30)
        XCTAssertEqual(plan2.numberOfWeeks, 5)
        XCTAssertEqual(plan2.trailingDays, 0)
        
        // 5-week month, no leading days
        let may2022 = try ISO8601Month(year: 2022, month: 5)
        let plan3 = SUT.create(month: may2022)
        XCTAssertEqual(plan3.leadingDays, 0)
        XCTAssertEqual(plan3.numberOfDays, 31)
        XCTAssertEqual(plan3.numberOfWeeks, 5)
        XCTAssertEqual(plan3.trailingDays, 4)
        
        let feb2015 = try ISO8601Month(year: 2015, month: 2) // 4-week month
        let plan4 = SUT.create(month: feb2015)
        XCTAssertEqual(plan4.leadingDays, 0)
        XCTAssertEqual(plan4.numberOfDays, 28)
        XCTAssertEqual(plan4.numberOfWeeks, 4)
        XCTAssertEqual(plan4.trailingDays, 0)
    }
    
}
