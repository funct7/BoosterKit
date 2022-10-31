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
    
    private var viewProvider: _ViewProvider!
    private var sut: CalendarAdapter<_Cell>!
    
    private func setUp(initialMonth: ISO8601Month, monthRange: Pair<ISO8601Month?, ISO8601Month?>) {
        sut = .init(
            initialMonth: initialMonth,
            monthRange: monthRange,
            viewProvider: withVar(_ViewProvider()) { self.viewProvider = $0 })
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
    
    func test_monthRange_settingNewValue_adjustsScrollPositionToCurrentMonth() throws {
        let oct2022 = try ISO8601Month(year: 2022, month: 10)
        setUp(initialMonth: oct2022.advanced(by: 2), monthRange: Pair(nil, nil))
        
        let frame = CGRect(origin: .zero, size: CGSize(width: 390, height: 320))
        let layout = MockCalendarLayout(),
            view = MockCollectionView(frame: frame, collectionViewLayout: layout)
        
        sut.view = view
        
        func resetMock() {
            layout.invalidateLayoutIfNeededArgs = []
            view.reloadDataCallCount = 0
            view.contentOffsetArgs = []
        }
        
        resetMock()
        
        // upperBound: unbounded -> bounded infinite -> unbounded
        sut.monthRange.second = oct2022 // upper bound: sec 1 -> sec 1
        
        expect(self.sut.currentMonth).to(equal(oct2022))
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(1))
        expect(view.reloadDataCallCount).to(equal(1))
        expect(view.contentOffsetArgs).to(haveCount(1))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width))
        
        sut.monthRange.second = oct2022.advanced(by: -2) // upper bound: sec 1 -> sec 1
        
        expect(self.sut.currentMonth).to(equal(oct2022.advanced(by: -2)))
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(2))
        expect(view.reloadDataCallCount).to(equal(2))
        expect(view.contentOffsetArgs).to(haveCount(2))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width))
        
        sut.monthRange.second = nil // unbounded: sec 1 -> sec 1
        
        expect(self.sut.currentMonth).to(equal(oct2022.advanced(by: -2)))
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(3))
        expect(view.reloadDataCallCount).to(equal(3))
        expect(view.contentOffsetArgs).to(haveCount(3))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width))
        
        resetMock()
        
        // lowerBound: unbounded -> bounded infinite -> unbounded
        sut.monthRange.first = oct2022 // lower bound: sec 1 -> sec 0
        
        expect(self.sut.currentMonth).to(equal(oct2022))
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(1))
        expect(view.reloadDataCallCount).to(equal(1))
        expect(view.contentOffsetArgs).to(haveCount(1))
        expect(view.contentOffsetArgs.last?.x).to(equal(0))

        sut.monthRange.first = oct2022.advanced(by: 2) // lower bound: sec 0 -> sec 0
        
        expect(self.sut.currentMonth).to(equal(oct2022.advanced(by: 2)))
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(2))
        expect(view.reloadDataCallCount).to(equal(2))
        expect(view.contentOffsetArgs).to(haveCount(2))
        expect(view.contentOffsetArgs.last?.x).to(equal(0))
        
        sut.monthRange.first = oct2022.advanced(by: -2) // lower bound: sec 0 -> sec 1
        
        expect(self.sut.currentMonth).to(equal(oct2022.advanced(by: 2))) // unchanged
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(3))
        expect(view.reloadDataCallCount).to(equal(3))
        expect(view.contentOffsetArgs).to(haveCount(3))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width))
        
        sut.monthRange.first = oct2022
        sut.currentMonth = oct2022
        resetMock()
        
        sut.monthRange.first = nil // lower bound: sec 0 -> sec 1
        
        expect(self.sut.currentMonth).to(equal(oct2022)) // unchanged
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(1))
        expect(view.reloadDataCallCount).to(equal(1))
        expect(view.contentOffsetArgs).to(haveCount(1))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width))
        
        // finite -> finite
        sut.monthRange = Pair(oct2022, oct2022.advanced(by: 2))
        resetMock()
        
        sut.monthRange.first = oct2022.advanced(by: -9) // sec 0 -> sec 9
        
        expect(self.sut.currentMonth).to(equal(oct2022)) // unchanged
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(1))
        expect(view.reloadDataCallCount).to(equal(1))
        expect(view.contentOffsetArgs).to(haveCount(1))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width * 9))
        
        sut.monthRange.first = oct2022.advanced(by: -4) // sec 9 -> sec 4
        
        expect(self.sut.currentMonth).to(equal(oct2022)) // unchanged
        expect(layout.invalidateLayoutIfNeededArgs).to(haveCount(2))
        expect(view.reloadDataCallCount).to(equal(2))
        expect(view.contentOffsetArgs).to(haveCount(2))
        expect(view.contentOffsetArgs.last?.x).to(equal(frame.width * 4))
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
    
    func test_getCellWithDate() throws {
        typealias _Context = CalendarDateContext
        
        let oct2022 = try ISO8601Month(year: 2022, month: 10, timeZone: .seoul)
        
        setUp(initialMonth: oct2022, monthRange: Pair(nil, nil))
        
        let layout = MockCalendarLayout(),
            view = MockCollectionView(
                frame: CGRect(origin: .zero, size: CGSize(width: 390, height: 320)),
                collectionViewLayout: layout)
        
        sut.view = withVar(view) {
            $0.register(
                TestCalendarAdapterCell.self,
                forCellWithReuseIdentifier: viewProvider.getCellIdentifier())
        }
        sut.view.layoutIfNeeded()
        sut.currentMonth = oct2022
        sut.view.layoutIfNeeded()
        
        let sep24 = try ISO8601Date(year: 2022, month: 9, day: 24, timeZone: .seoul),
            sep25 = try ISO8601Date(year: 2022, month: 9, day: 25, timeZone: .seoul),
            oct31 = try ISO8601Date(year: 2022, month: 10, day: 31, timeZone: .seoul),
            nov5 = try ISO8601Date(year: 2022, month: 11, day: 5, timeZone: .seoul),
            nov6 = try ISO8601Date(year: 2022, month: 11, day: 6, timeZone: .seoul)
        
        XCTAssertNil(try sut.getCell(date: sep24))
        XCTAssertEqual(try sut.getCell(date: sep25)?.context, _Context(date: sep25, position: .leading))
        XCTAssertEqual(
            try sut.getCell(date: oct2022.dateRange.lowerBound)?.context,
            _Context(date: oct2022.dateRange.lowerBound, position: .main))
        XCTAssertEqual(try sut.getCell(date: oct31)?.context, _Context(date: oct31, position: .main))
        XCTAssertEqual(try sut.getCell(date: nov5)?.context, _Context(date: nov5, position: .trailing))
        XCTAssertNil(try sut.getCell(date: nov6))
        
        let sep2022 = oct2022.advanced(by: -1)
        
        sut.currentMonth = sep2022
        sut.view.layoutIfNeeded()
        
        XCTAssertEqual(try sut.getCell(date: sep24)?.context, _Context(date: sep24, position: .main))
        XCTAssertNil(try sut.getCell(date: oct2022.dateRange.lowerBound.advanced(by: 1)))
        
        sut.displayOption = .fixed
        sut.view.layoutIfNeeded()
        
        let oct2 = oct2022.dateRange.lowerBound.advanced(by: 1)
        XCTAssertEqual(try sut.getCell(date: oct2)?.context, _Context(date: oct2, position: .trailing))
        
        let oct2HK = try ISO8601Date(year: 2022, month: 10, day: 2, timeZone: .hongKong)
        expect(try self.sut.getCell(date: oct2HK)).to(throwError(BoosterKitError.illegalArgument))
    }
    
    func test_reload() {
        let now = ISO8601Month()
        setUp(initialMonth: now, monthRange: Pair(nil, nil))
        
        let layout = MockCalendarLayout(),
            view = MockCollectionView(frame: .zero, collectionViewLayout: layout)
        
        sut.view = view
        
        // un-optimized
        sut.reload()
        expect(view.reloadDataCallCount).to(equal(2))
        
        sut.currentMonth = now.advanced(by: 12)
        
        sut.reload()
        expect(view.reloadDataCallCount).to(equal(4))
    }
    
    func test_reloadDate() throws {
        let oct2022 = try ISO8601Month(year: 2022, month: 10, timeZone: .seoul)
        setUp(initialMonth: oct2022, monthRange: Pair(nil, nil))
        
        let layout = MockCalendarLayout(),
            view = MockCollectionView(frame: CGRect(origin: .zero, size: CGSize(width: 390, height: 320)), collectionViewLayout: layout)
        
        sut.view = withVar(view) {
            $0.register(
                TestCalendarAdapterCell.self,
                forCellWithReuseIdentifier: viewProvider.getCellIdentifier())
        }
        
        let sep24 = try ISO8601Date(year: 2022, month: 9, day: 24, timeZone: .seoul), // out of bounds
            sep25 = try ISO8601Date(year: 2022, month: 9, day: 25, timeZone: .seoul),
            oct28 = try ISO8601Date(year: 2022, month: 10, day: 28, timeZone: .seoul),
            nov5 = try ISO8601Date(year: 2022, month: 11, day: 5, timeZone: .seoul),
            nov6 = try ISO8601Date(year: 2022, month: 11, day: 6, timeZone: .seoul)   // out of bounds
        
        try sut.reloadDate(sep24)
        expect(view.reloadItemsAtIndexPathsArgs).to(beEmpty())
        
        try sut.reloadDate(sep25)
        expect(view.reloadItemsAtIndexPathsArgs).to(haveCount(1))
        expect(view.reloadItemsAtIndexPathsArgs.last).to(equal([IndexPath(indexes: [1, 0])]))
        
        try sut.reloadDate(oct28)
        expect(view.reloadItemsAtIndexPathsArgs).to(haveCount(2))
        expect(view.reloadItemsAtIndexPathsArgs.last).to(equal([IndexPath(indexes: [1, 33])]))
        
        try sut.reloadDate(nov5)
        expect(view.reloadItemsAtIndexPathsArgs).to(haveCount(3))
        expect(view.reloadItemsAtIndexPathsArgs.last).to(equal([IndexPath(indexes: [1, 41])]))
        
        try sut.reloadDate(nov6)
        expect(view.reloadItemsAtIndexPathsArgs).to(haveCount(3))
        
        expect(try self.sut.reloadDate(ISO8601Date(date: Date(), timeZone: .hongKong)))
            .to(throwError(BoosterKitError.illegalArgument))
    }
    
}

private final class MockCollectionView : UICollectionView {
    
    var contentOffsetArgs: [CGPoint] = []
    override var contentOffset: CGPoint {
        didSet {
            contentOffsetArgs.append(contentOffset)
        }
    }
    
    var reloadDataCallCount = 0
    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }
    
    var reloadItemsAtIndexPathsArgs: [[IndexPath]] = []
    override func reloadItems(at indexPaths: [IndexPath]) {
        reloadItemsAtIndexPathsArgs.append(indexPaths)
        super.reloadItems(at: indexPaths)
    }
    
}

private final class MockCalendarLayout : CalendarLayout {
    
    var invalidateLayoutIfNeededArgs: [CalendarLayout.DataSet] = []
    
    override func invalidateLayoutIfNeeded(dataSet: CalendarLayout.DataSet) {
        invalidateLayoutIfNeededArgs.append(dataSet)
        super.invalidateLayoutIfNeeded(dataSet: dataSet)
    }
    
}
