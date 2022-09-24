//
//  CalendarAdapterTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/24.
//

import XCTest
import UIKit
import BoosterKit
import Nimble

class CalendarAdapterTests : XCTestCase {
    
    private typealias _ViewProvider = TestCalendarAdapterComponentViewProvider
    private typealias _Cell = TestCalendarAdapterCell
    
    private var adapter: CalendarAdapter<_Cell>!
    
    private func setUp(initialMonth: ISO8601Month, monthRange: Pair<ISO8601Month?, ISO8601Month?>) {
        adapter = .init(
            initialMonth: initialMonth,
            monthRange: monthRange,
            viewProvider: _ViewProvider())
    }
    
    func test_currentMonth_invariant() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022))
        expect(self.adapter.currentMonth = sep2022.advanced(by: 1)).to(throwAssertion())
        
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, nil))
        expect(self.adapter.currentMonth = sep2022.advanced(by: -1)).to(throwAssertion())
        
        setUp(initialMonth: sep2022, monthRange: Pair(nil, sep2022))
        expect(self.adapter.currentMonth = sep2022.advanced(by: 1)).to(throwAssertion())
    }
    
    func test_monthRange_invariant() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9, timeZone: .seoul)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022))
        
        expect(self.adapter.monthRange = Pair(sep2022, try ISO8601Month(year: 2022, month: 10, timeZone: .tokyo)))
            .to(throwAssertion())
        expect(self.adapter.monthRange = Pair(sep2022, try ISO8601Month(year: 2022, month: 10, timeZone: .hongKong)))
            .to(throwAssertion())
        
        expect(self.adapter.monthRange = Pair(sep2022, sep2022.advanced(by: -1)))
            .to(throwAssertion())
        
        adapter.monthRange = Pair(sep2022, sep2022.advanced(by: 10))
        XCTAssertEqual(adapter.currentMonth, sep2022)
        
        adapter.monthRange = Pair(sep2022.advanced(by: 5), sep2022.advanced(by: 10))
        XCTAssertEqual(adapter.currentMonth, sep2022.advanced(by: 5))
        
        adapter.monthRange = Pair(sep2022.advanced(by: -12), sep2022)
        XCTAssertEqual(adapter.currentMonth, sep2022)
    }
    
}
