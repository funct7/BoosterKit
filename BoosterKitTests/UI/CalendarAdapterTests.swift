//
//  CalendarAdapterTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/24.
//

import XCTest
import UIKit
@testable import BoosterKit
import Nimble

class CalendarAdapterTests : XCTestCase {
    
    private typealias _ViewProvider = TestCalendarAdapterComponentViewProvider
    private typealias _Cell = TestCalendarAdapterCell
    
    private var sut: CalendarAdapter<_Cell>!
    
    private func setUp(initialMonth: ISO8601Month, monthRange: Pair<ISO8601Month?, ISO8601Month?>) {
        sut = .init(
            initialMonth: initialMonth,
            monthRange: monthRange,
            viewProvider: _ViewProvider())
    }
    
    func test_currentMonth_invariant() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022))
        expect(self.sut.currentMonth = sep2022.advanced(by: 1)).to(throwAssertion())
        
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, nil))
        expect(self.sut.currentMonth = sep2022.advanced(by: -1)).to(throwAssertion())
        
        setUp(initialMonth: sep2022, monthRange: Pair(nil, sep2022))
        expect(self.sut.currentMonth = sep2022.advanced(by: 1)).to(throwAssertion())
    }
    
    func test_monthRange_invariant() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9, timeZone: .seoul)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022))
        
        expect(self.sut.monthRange = Pair(sep2022, try ISO8601Month(year: 2022, month: 10, timeZone: .tokyo)))
            .to(throwAssertion())
        expect(self.sut.monthRange = Pair(sep2022, try ISO8601Month(year: 2022, month: 10, timeZone: .hongKong)))
            .to(throwAssertion())
        
        expect(self.sut.monthRange = Pair(sep2022, sep2022.advanced(by: -1)))
            .to(throwAssertion())
        
        sut.monthRange = Pair(sep2022, sep2022.advanced(by: 10))
        XCTAssertEqual(sut.currentMonth, sep2022)
        
        sut.monthRange = Pair(sep2022.advanced(by: 5), sep2022.advanced(by: 10))
        XCTAssertEqual(sut.currentMonth, sep2022.advanced(by: 5))
        
        sut.monthRange = Pair(sep2022.advanced(by: -12), sep2022)
        XCTAssertEqual(sut.currentMonth, sep2022)
    }
    
    func test_requestsLayoutInvalidationForDataChanges() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9, timeZone: .seoul)
        setUp(initialMonth: sep2022, monthRange: Pair(nil, nil))
        
        let layout = MockCalendarLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        sut.view = view
        // calls method for initial setting of data
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(1))
        
        // same as the current value, but `invalidLayoutIfNeeded` is called regardless.
        // it is up to the `CalendarLayout` instance to check for changes.
        sut.displayOption = .dynamic
        
        typealias DataSet = CalendarLayout.DataSet
        
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(2))
        expect(layout.invalidateLayoutIfNeededArgs.last).to(equal(DataSet(displayOption: .dynamic, monthRange: Pair(nil, nil), currentMonth: sep2022)))
        
        sut.displayOption = .fixed
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(3))
        expect(layout.invalidateLayoutIfNeededArgs.last).to(equal(DataSet(displayOption: .fixed, monthRange: Pair(nil, nil), currentMonth: sep2022)))
        
        sut.monthRange.first = sep2022
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(4))
        expect(layout.invalidateLayoutIfNeededArgs.last).to(equal(DataSet(displayOption: .fixed, monthRange: Pair(sep2022, nil), currentMonth: sep2022)))
        
        sut.monthRange.second = sep2022
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(5))
        expect(layout.invalidateLayoutIfNeededArgs.last).to(equal(DataSet(displayOption: .fixed, monthRange: Pair(sep2022, sep2022), currentMonth: sep2022)))
        
        sut.monthRange = Pair(nil, nil)
        sut.currentMonth = sep2022.advanced(by: 1)
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(7))
        expect(layout.invalidateLayoutIfNeededArgs.last).to(equal(DataSet(displayOption: .fixed, monthRange: Pair(nil, nil), currentMonth: sep2022.advanced(by: 1))))
    }
    
}

private final class MockCalendarLayout : CalendarLayout {
    
    var invalidateLayoutIfNeededArgs: [CalendarLayout.DataSet] = []
    
    override func invalidateLayoutIfNeeded(dataSet: CalendarLayout.DataSet) {
        invalidateLayoutIfNeededArgs.append(dataSet)
    }
    
}
