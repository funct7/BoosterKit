//
//  CalendarLayoutTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/25.
//

import XCTest
import BoosterKit
import UIKit

class CalendarLayoutTests : XCTestCase {
    
    private var collectionView: UICollectionView!
    private var adapter: CalendarAdapter<TestCalendarAdapterCell>!
    private var sut: CalendarLayout!
    
    private func setUp(
        params: CalendarLayout.Params,
        frame: CGRect,
        initialMonth: ISO8601Month = .init(),
        monthRange: Pair<ISO8601Month?, ISO8601Month?> = Pair(nil, nil))
    {
        sut = withVar(CalendarLayout()) { $0!.params = params }
        collectionView = .init(
            frame: frame,
            collectionViewLayout: sut)
        adapter = .init(
            initialMonth: initialMonth,
            monthRange: monthRange,
            viewProvider: TestCalendarAdapterComponentViewProvider())
        adapter.view = collectionView
    }
    
    func test_contentSize_top() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        
        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)
        
        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)
        
        sut.mode = .top
        
        // displayOption - dynamic
        adapter.displayOption = .dynamic
        
        // frame > content height
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short5week)
        
        adapter.currentMonth = sep2022.advanced(by: 1)
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short6week)
        
        // frame < content height
        sut.params.itemSize = .tall
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)
        
        adapter.currentMonth = sep2022
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall5week)
        
        // displayOption - fixed
        adapter.displayOption = .fixed
        
        // frame > content height
        sut.params.itemSize = .short
        adapter.currentMonth = sep2022
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short6week)
        
        adapter.currentMonth = sep2022.advanced(by: 1)
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short6week)
        
        // frame < content height
        sut.params.itemSize = .tall
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short6week)
        
        adapter.currentMonth = sep2022
        
        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .short6week)
    }
    
    func test_contentSize_fill() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)

        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)

        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)

        sut.mode = .fill

        // dynamic
        adapter.displayOption = .dynamic

        // frame > content height
        sut.params.itemSize = .short

        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        adapter.currentMonth = sep2022.advanced(by: 1)

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        // frame < content height
        sut.params.itemSize = .tall

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)

        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall5week)

        // fixed
        adapter.displayOption = .fixed

        // frame > content height
        sut.params.itemSize = .short
        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        adapter.currentMonth = sep2022.advanced(by: 1)

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        // frame < content height
        sut.params.itemSize = .tall

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)

        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)
    }

    func test_contentSize_spread() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)

        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)

        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)

        sut.mode = .spread

        // dynamic
        adapter.displayOption = .dynamic

        // frame > content height
        sut.params.itemSize = .short
        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        adapter.currentMonth = sep2022.advanced(by: 1)

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        // frame < content height
        sut.params.itemSize = .tall

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)

        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall5week)

        // fixed
        adapter.displayOption = .fixed

        // frame > content height
        sut.params.itemSize = .short
        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        adapter.currentMonth = sep2022.advanced(by: 1)

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, frame.size.height)

        // frame < content height
        sut.params.itemSize = .tall

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)

        adapter.currentMonth = sep2022

        XCTAssertEqual(sut.collectionViewContentSize.width, frame.size.width * 3)
        XCTAssertEqual(sut.collectionViewContentSize.height, .tall6week)
    }
    
    func test_contentSize_sectionHeight_observation() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        
        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)
        
        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)
        
        var contentSizeList = [CGSize]()
        var sectionHeightList = [CGFloat]()
        
        let contentObsToken = sut.observe(\.collectionViewContentSize, options: [.initial, .new]) { contentSizeList.append($1.newValue!) }
        let heightObsToken = sut.observe(\.sectionHeight, options: [.initial, .new]) { sectionHeightList.append($1.newValue!) }
        let _ = [contentObsToken, heightObsToken] // code inserted to suppress unused value compiler warning
        
        let width = frame.width * 3
        
        // dynamic, top, 5 week
        XCTAssertEqual(contentSizeList.count, 1)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .short5week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // dynamic, top, 6 week
        adapter.currentMonth = sep2022.advanced(by: 1)
        
        XCTAssertEqual(contentSizeList.count, 2)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .short6week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // fixed, fill
        adapter.displayOption = .fixed
        sut.mode = .fill
        
        XCTAssertEqual(contentSizeList.count, 4)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: frame.height))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // fixed, fill, tall items
        sut.params.itemSize = .tall
        XCTAssertEqual(contentSizeList.count, 5)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .tall6week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // dynamic, top, 5 week, tall items
        adapter.displayOption = .dynamic
        sut.mode = .top
        adapter.currentMonth = sep2022
        XCTAssertEqual(contentSizeList.count, 8)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .tall5week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // dynamic, fill, 5 week
        sut.mode = .fill
        sut.params.itemSize = .short
        XCTAssertEqual(contentSizeList.count, 10)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: frame.height))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        zip(contentSizeList, sectionHeightList).forEach { XCTAssertEqual($0.height, $1) }
    }
    
}

private extension UIEdgeInsets {
    
    static let test = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    var vertical: CGFloat { top + bottom }
    
}

private extension CGSize {
    
    static let short = CGSize(width: 51, height: 40)
    static let tall  = CGSize(width: 51, height: 50)
    
}

private extension CGFloat {
    
    static let weekdayHeight: Self = 40
    
    static let short5week = UIEdgeInsets.test.vertical + weekdayHeight + CGSize.short.height * 5
    static let short6week = UIEdgeInsets.test.vertical + weekdayHeight + CGSize.short.height * 6
    
    static let tall5week = UIEdgeInsets.test.vertical + weekdayHeight + CGSize.tall.height * 5
    static let tall6week = UIEdgeInsets.test.vertical + weekdayHeight + CGSize.tall.height * 6
    
}

extension CGSize {
    
    enum Device {
        static let iPhone11 = CGSize(width: 414, height: 896)
        static let iPhone12 = CGSize(width: 390, height: 844)
        static let iPhone12Mini = CGSize(width: 375, height: 812)
        static let iPhone12ProMax = CGSize(width: 428, height: 926)
        static let iPhoneSE2 = CGSize(width: 375, height: 667)
    }
    
}
