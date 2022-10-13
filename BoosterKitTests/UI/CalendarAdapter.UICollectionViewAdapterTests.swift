//
//  CalendarAdapter.UICollectionViewAdapterTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/21.
//

import XCTest
@testable import BoosterKit
import UIKit

class CalendarAdapter_UICollectionViewAdapterTests : XCTestCase {
    
    private enum _Constant {
        static let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    }
    
    private typealias _ViewProvider = TestCalendarAdapterComponentViewProvider
    private typealias _Cell = TestCalendarAdapterCell
    
    private var viewProvider: _ViewProvider!
    private var adapter: CalendarAdapter<_Cell>!
    private var sut: CalendarAdapter<_Cell>.UICollectionViewAdapter!
    
    private func setUp(
        initialMonth: ISO8601Month,
        monthRange: Pair<ISO8601Month?, ISO8601Month?>)
    {
        viewProvider = .init()
        _Constant.collectionView.register(_Cell.self, forCellWithReuseIdentifier: "\(_Cell.self)")
        
        adapter = .init(
            initialMonth: initialMonth,
            monthRange: monthRange,
            viewProvider: viewProvider)
        
        sut = .init(calendarAdapter: adapter)
    }
    
    func test_numberOfSections() throws {
        let current = ISO8601Month()
        let run = { self.sut.numberOfSections(in: _Constant.collectionView) }
        
        // monthRange is finite
        setUp(initialMonth: current, monthRange: Pair(current, current))
        XCTAssertEqual(run(), 1)
        
        setUp(initialMonth: current, monthRange: Pair(current, current.advanced(by: 1)))
        XCTAssertEqual(run(), 2)
        
        setUp(initialMonth: current, monthRange: Pair(current, current.advanced(by: 5)))
        XCTAssertEqual(run(), 6)
        
        setUp(initialMonth: current, monthRange: Pair(current, current.advanced(by: 23)))
        XCTAssertEqual(run(), 24)
        
        // monthRange has a lower bound
        setUp(initialMonth: current, monthRange: Pair(current, nil))
        XCTAssertEqual(run(), 2)
        
        adapter.currentMonth = current.advanced(by: 1)
        XCTAssertEqual(run(), 3)
        
        adapter.currentMonth = current
        XCTAssertEqual(run(), 2)
        
        adapter.currentMonth = current.advanced(by: 100)
        XCTAssertEqual(run(), 3)
        
        // monthRange has an upper bound
        setUp(initialMonth: current, monthRange: Pair(nil, current))
        XCTAssertEqual(run(), 2)
        
        adapter.currentMonth = current.advanced(by: -1)
        XCTAssertEqual(run(), 3)
        
        adapter.currentMonth = current
        XCTAssertEqual(run(), 2)
        
        adapter.currentMonth = current.advanced(by: -12)
        XCTAssertEqual(run(), 3)
        
        // monthRange is unbounded
        setUp(initialMonth: current, monthRange: Pair(nil, nil))
        XCTAssertEqual(run(), 3)
    }
    
    // `CalendarAdapterDisplayOption.dynamic` will show 5 weeks for most cases
    // and either shrink to 4 weeks for months like Feb 2015,
    // or expand to 6 weeks for months like Oct 2022.
    func test_numberOfItemsInSection_dynamic() throws {
        // 5-week month, flexibleMonthHeight
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022.advanced(by: -1), sep2022.advanced(by: 1)))
        
        let run: (Int) -> Int = {
            self.sut.collectionView(_Constant.collectionView, numberOfItemsInSection: $0)
        }
        
        XCTAssertEqual(run(0), 35)
        XCTAssertEqual(run(1), 35)
        XCTAssertEqual(run(2), 42) // Oct 2022 is a 6-week month
        
        // 4-week month
        let feb2015 = try ISO8601Month(year: 2015, month: 2)
        setUp(initialMonth: feb2015, monthRange: Pair(feb2015.advanced(by: -1), feb2015.advanced(by: 1)))
        
        XCTAssertEqual(run(0), 35)
        XCTAssertEqual(run(1), 28)
        XCTAssertEqual(run(2), 35)
        
        // edge cases
        setUp(
            initialMonth: sep2022,
            monthRange: Pair(try ISO8601Month(year: 2022, month: 1), try ISO8601Month(year: 2022, month: 12)))
        
        let expected = [
            42, 35, 35, 35,
            35, 35, 42, 35,
            35, 42, 35, 35,
        ]
        
        zip((0 ... 11), expected).forEach { i, count in
            XCTAssertEqual(run(i), count)
        }
        
        setUp(
            initialMonth: sep2022,
            monthRange: Pair(nil, sep2022.advanced(by: 1)))
        
        XCTAssertEqual(run(0), 35)
        XCTAssertEqual(run(1), 35)
        XCTAssertEqual(run(2), 42) // oct 2022
        
        adapter.currentMonth = sep2022.advanced(by: 1)
        XCTAssertEqual(run(1), 42) // oct 2022
        XCTAssertEqual(run(0), 35)
        
        let oct2021 = try ISO8601Month(year: 2021, month: 10)
        adapter.currentMonth = oct2021
        XCTAssertEqual(run(0), 35)
        XCTAssertEqual(run(1), 42) // oct 2021
        XCTAssertEqual(run(2), 35)
        
        adapter.currentMonth = oct2021.advanced(by: 1)
        XCTAssertEqual(run(0), 42) // oct 2021
        XCTAssertEqual(run(1), 35)
        XCTAssertEqual(run(2), 35)
        
        adapter.currentMonth = oct2021.advanced(by: -1)
        XCTAssertEqual(run(0), 35)
        XCTAssertEqual(run(1), 35)
        XCTAssertEqual(run(2), 42) // oct 2021
    }
    
    // `CalendarAdapterDisplayOption.fixed` will always show 6 weeks
    // and fill any remaining rows with days from the next month.
    func test_numberOfItemsInSection_fixed() throws {
        // 5-week month
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022.advanced(by: -1), sep2022.advanced(by: 1)))
        adapter.displayOption = .fixed
        
        let run: (Int) -> Int = {
            self.sut.collectionView(_Constant.collectionView, numberOfItemsInSection: $0)
        }
        
        XCTAssertEqual(run(0), 42)
        XCTAssertEqual(run(1), 42)
        XCTAssertEqual(run(2), 42) // Oct 2022 is a 6-week month
        
        // 4-week month
        let feb2015 = try ISO8601Month(year: 2015, month: 2)
        setUp(initialMonth: feb2015, monthRange: Pair(feb2015.advanced(by: -1), feb2015.advanced(by: 1)))
        adapter.displayOption = .fixed
        
        XCTAssertEqual(run(0), 42)
        XCTAssertEqual(run(1), 42)
        XCTAssertEqual(run(2), 42)
    }
    
    func test_cellForItemAtIndexPath() throws {
        let getItemCount: (Int) -> Int = {
            self.sut.collectionView(_Constant.collectionView, numberOfItemsInSection: $0)
        }
        let run: (Int, Int) -> _Cell = { section, index in
            self.sut.collectionView(_Constant.collectionView, cellForItemAt: IndexPath(indexes: [section, index])) as! _Cell
        }
        
        // === 1-month range ===
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022))
        
        // dynamic
        do {
            let itemCount = getItemCount(0)
            let expected = try CalendarAdapterContext.create(year: 2022, month: 9, leadingDays: 4, trailingDays: 1)
            
            XCTAssertEqual(itemCount, expected.count)
            
            (0 ..< itemCount).forEach { i in
                XCTAssertEqual(run(0, i).context, expected[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // fixed
        adapter.displayOption = .fixed
        do {
            let itemCount = getItemCount(0)
            let expected = try CalendarAdapterContext.create(year: 2022, month: 9, leadingDays: 4, trailingDays: 8)
            
            XCTAssertEqual(itemCount, expected.count)
            
            (0 ..< itemCount).forEach { i in
                XCTAssertEqual(run(0, i).context, expected[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // === 12-month range ===
        setUp(initialMonth: sep2022, monthRange: Pair(sep2022, sep2022.advanced(by: 11)))
        
        // dynamic
        do {
            let itemCount1 = getItemCount(0)
            let expected1 = try CalendarAdapterContext.create(year: 2022, month: 9, leadingDays: 4, trailingDays: 1)
            
            XCTAssertEqual(itemCount1, expected1.count)
            
            (0 ..< itemCount1).forEach { i in
                XCTAssertEqual(run(0, i).context, expected1[i])
            }
            
            let itemCount2 = getItemCount(1)
            let expected2 = try CalendarAdapterContext.create(year: 2022, month: 10, leadingDays: 6, trailingDays: 5)
            
            XCTAssertEqual(itemCount2, expected2.count)
            
            (0 ..< itemCount2).forEach { i in
                XCTAssertEqual(run(1, i).context, expected2[i])
            }
            
            let itemCount3 = getItemCount(3)
            let expected3 = try CalendarAdapterContext.create(year: 2022, month: 12, leadingDays: 4, trailingDays: 0)
            
            XCTAssertEqual(itemCount3, expected3.count)
            
            (0 ..< itemCount3).forEach { i in
                XCTAssertEqual(run(3, i).context, expected3[i])
            }
            
            let itemCount4 = getItemCount(11)
            let expected4 = try CalendarAdapterContext.create(year: 2023, month: 8, leadingDays: 2, trailingDays: 2)
            
            XCTAssertEqual(itemCount4, expected4.count)
            
            (0 ..< itemCount4).forEach { i in
                XCTAssertEqual(run(11, i).context, expected4[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // fixed
        adapter.displayOption = .fixed
        
        do {
            let itemCount1 = getItemCount(0)
            let expected1 = try CalendarAdapterContext.create(year: 2022, month: 9, leadingDays: 4, trailingDays: 8)
            
            XCTAssertEqual(itemCount1, expected1.count)
            
            (0 ..< itemCount1).forEach { i in
                XCTAssertEqual(run(0, i).context, expected1[i])
            }
            
            let itemCount2 = getItemCount(1)
            let expected2 = try CalendarAdapterContext.create(year: 2022, month: 10, leadingDays: 6, trailingDays: 5)
            
            XCTAssertEqual(itemCount2, expected2.count)
            
            (0 ..< itemCount2).forEach { i in
                XCTAssertEqual(run(1, i).context, expected2[i])
            }
            
            let itemCount3 = getItemCount(7)
            let expected3 = try CalendarAdapterContext.create(year: 2023, month: 4, leadingDays: 6, trailingDays: 6)
            
            XCTAssertEqual(itemCount3, expected3.count)
            
            (0 ..< itemCount3).forEach { i in
                XCTAssertEqual(run(7, i).context, expected3[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // === infinite range ===
        setUp(
            initialMonth: try ISO8601Month(year: 2015, month: 2),
            monthRange: Pair(nil, nil))
        
        // dynamic
        do {
            let itemCount1 = getItemCount(0)
            let expected1 = try CalendarAdapterContext.create(year: 2015, month: 1, leadingDays: 4, trailingDays: 0)
            
            XCTAssertEqual(itemCount1, expected1.count)
            
            (0 ..< itemCount1).forEach { i in
                XCTAssertEqual(run(0, i).context, expected1[i])
            }
            
            let itemCount2 = getItemCount(1)
            let expected2 = try CalendarAdapterContext.create(year: 2015, month: 2, leadingDays: 0, trailingDays: 0)
            
            XCTAssertEqual(itemCount2, expected2.count)
            
            (0 ..< itemCount2).forEach { i in
                XCTAssertEqual(run(1, i).context, expected2[i])
            }
            
            let itemCount3 = getItemCount(2)
            let expected3 = try CalendarAdapterContext.create(year: 2015, month: 3, leadingDays: 0, trailingDays: 4)
            
            XCTAssertEqual(itemCount3, expected3.count)
            
            (0 ..< itemCount3).forEach { i in
                XCTAssertEqual(run(2, i).context, expected3[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // fixed
        adapter.displayOption = .fixed
        
        do {
            let itemCount1 = getItemCount(0)
            let expected1 = try CalendarAdapterContext.create(year: 2015, month: 1, leadingDays: 4, trailingDays: 7)
            
            XCTAssertEqual(itemCount1, expected1.count)
            
            (0 ..< itemCount1).forEach { i in
                XCTAssertEqual(run(0, i).context, expected1[i])
            }
            
            let itemCount2 = getItemCount(1)
            let expected2 = try CalendarAdapterContext.create(year: 2015, month: 2, leadingDays: 0, trailingDays: 14)
            
            XCTAssertEqual(itemCount2, expected2.count)
            
            (0 ..< itemCount2).forEach { i in
                XCTAssertEqual(run(1, i).context, expected2[i])
            }
            
            let itemCount3 = getItemCount(2)
            let expected3 = try CalendarAdapterContext.create(year: 2015, month: 3, leadingDays: 0, trailingDays: 11)
            
            XCTAssertEqual(itemCount3, expected3.count)
            
            (0 ..< itemCount3).forEach { i in
                XCTAssertEqual(run(2, i).context, expected3[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
        
        // change current month
        adapter.currentMonth = sep2022
        adapter.displayOption = .dynamic
        
        do {
            let itemCount1 = getItemCount(0)
            let expected1 = try CalendarAdapterContext.create(year: 2022, month: 8, leadingDays: 1, trailingDays: 3)
            
            XCTAssertEqual(itemCount1, expected1.count)
            
            (0 ..< itemCount1).forEach { i in
                XCTAssertEqual(run(0, i).context, expected1[i])
            }
            
            let itemCount2 = getItemCount(1)
            let expected2 = try CalendarAdapterContext.create(year: 2022, month: 9, leadingDays: 4, trailingDays: 1)
            
            XCTAssertEqual(itemCount2, expected2.count)
            
            (0 ..< itemCount2).forEach { i in
                XCTAssertEqual(run(1, i).context, expected2[i])
            }
            
            let itemCount3 = getItemCount(2)
            let expected3 = try CalendarAdapterContext.create(year: 2022, month: 10, leadingDays: 6, trailingDays: 5)
            
            XCTAssertEqual(itemCount3, expected3.count)
            
            (0 ..< itemCount3).forEach { i in
                XCTAssertEqual(run(2, i).context, expected3[i])
            }
        } catch {
            XCTFail("error: \(error)")
        }
    }
    
}

private extension CalendarAdapterContext {
    
    static func create(year: Int, month: Int, leadingDays: Int, trailingDays: Int) throws -> [Self] {
        var res = [CalendarAdapterContext]()
        let mainMonth = try ISO8601Month(year: year, month: month)
        let firstDayOfMain = mainMonth.dateRange.lowerBound
        let firstDayOfNext = mainMonth.dateRange.upperBound
        
        (1 ..< leadingDays+1).forEach { d in
            res.append(Self(date: firstDayOfMain.advanced(by: -d), position: .leading))
        }
        
        let dayCount = try firstDayOfMain.distance(to: firstDayOfNext)
        (0 ..< dayCount).forEach { d in
            res.append(Self(date: firstDayOfMain.advanced(by: d), position: .main))
        }
        
        (0 ..< trailingDays).forEach { d in
            res.append(Self(date: firstDayOfNext.advanced(by: d), position: .trailing))
        }
        
        return res.sorted(by: { $0.date < $1.date })
    }
    
}
