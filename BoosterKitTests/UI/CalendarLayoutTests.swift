//
//  CalendarLayoutTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/25.
//

import XCTest
@testable import BoosterKit
import UIKit
import Nimble

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
        
        // fixed, filled
        adapter.displayOption = .fixed
        sut.params.alignment.vertical = .filled
        
        XCTAssertEqual(contentSizeList.count, 4)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: frame.height))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // fixed, filled, tall items
        sut.params.itemSize = .tall
        XCTAssertEqual(contentSizeList.count, 5)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .tall6week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // dynamic, top, 5 week, tall items
        adapter.displayOption = .dynamic
        sut.params.alignment.vertical = .packed
        adapter.currentMonth = sep2022
        XCTAssertEqual(contentSizeList.count, 8)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: .tall5week))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        // dynamic, filled, 5 week
        sut.params.alignment.vertical = .filled
        sut.params.itemSize = .short
        XCTAssertEqual(contentSizeList.count, 10)
        XCTAssertEqual(contentSizeList.last, CGSize(width: width, height: frame.height))
        XCTAssertEqual(contentSizeList.count, sectionHeightList.count)
        
        zip(contentSizeList, sectionHeightList).forEach { XCTAssertEqual($0.height, $1) }
    }
    
    func test_weekdaySpans() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        setUp(
            params: .init(itemSize: .short),
            frame: CGRect(origin: .zero, size: .Device.iPhone12),
            initialMonth: sep2022)
        
        var weekdaySpansList = [[ColumnSpan]]()
        let obsToken = sut.observe(\.weekdaySpans, options: [.initial, .new]) { weekdaySpansList.append($1.newValue!) }
        let _ = [obsToken] // code to silence compiler warning about unused reference
        
        do { // h-align: .packed
            let expected = [
                ColumnSpan(start: 16.5, end: 67.5),
                ColumnSpan(start: 67.5, end: 118.5),
                ColumnSpan(start: 118.5, end: 169.5),
                ColumnSpan(start: 169.5, end: 220.5),
                ColumnSpan(start: 220.5, end: 271.5),
                ColumnSpan(start: 271.5, end: 322.5),
                ColumnSpan(start: 322.5, end: 373.5),
            ]
            XCTAssertEqual(sut.weekdaySpans, expected)
            expect(weekdaySpansList).to(equal([expected]))
        }
        
        do { // h-align: .filled, section insets - 7, spacing - 2
            sut.params.sectionInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            sut.params.spacing.width = 2
            sut.params.alignment.horizontal = .filled
            
            let expected = [
                ColumnSpan(start: 7, end: 59),
                ColumnSpan(start: 61, end: 113),
                ColumnSpan(start: 115, end: 167),
                ColumnSpan(start: 169, end: 221),
                ColumnSpan(start: 223, end: 275),
                ColumnSpan(start: 277, end: 329),
                ColumnSpan(start: 331, end: 383),
            ]
            XCTAssertEqual(sut.weekdaySpans, expected)
            expect(weekdaySpansList).to(haveCount(2))
            expect(weekdaySpansList.last).to(equal(expected))
        }
        
        do { // h-align: .spread, section insets - 16, item width - 40 -> spacing: 13
            sut.params.alignment.horizontal = .spread
            sut.params.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            sut.params.itemSize.width = 40
            
            let expected = [
                ColumnSpan(start: 16, end: 56),
                ColumnSpan(start: 69, end: 109),
                ColumnSpan(start: 122, end: 162),
                ColumnSpan(start: 175, end: 215),
                ColumnSpan(start: 228, end: 268),
                ColumnSpan(start: 281, end: 321),
                ColumnSpan(start: 334, end: 374),
            ]
            XCTAssertEqual(sut.weekdaySpans, expected)
            expect(weekdaySpansList).to(haveCount(3))
            expect(weekdaySpansList.last).to(equal(expected))
        }
    }
    
    func test_contentSize_packedVertical() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        
        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)
        
        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)
        
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
    
    func test_contentSize_filledVertical() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)

        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)

        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)

        sut.params.alignment.vertical = .filled

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

    func test_contentSize_spreadVertical() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)

        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)

        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)

        sut.params.alignment.vertical = .spread

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
    
    private typealias LayoutPlan = CalendarAdapter<TestCalendarAdapterCell>.UICollectionViewAdapter.LayoutPlan
    
    func test_layoutAttributesForElementInRect() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        
        let frame = CGRect(
            x: 0, y: 0,
            width: CGSize.Device.iPhone12.width,
            height: 320)
        
        setUp(
            params: .init(sectionInset: .test, itemSize: .short),
            frame: frame,
            initialMonth: sep2022)
        
        let page1 = CGRect(origin: .zero, size: frame.size),
            page2 = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height),
            page3 = CGRect(x: frame.width * 2, y: 0, width: frame.width, height: frame.height)
        
        func getRect(_ pageIndex: Int) -> [CGRect] {
            let weekCountList = (-1 ... 1).map { LayoutPlan.create(month: sep2022.advanced(by: $0)).numberOfWeeks }
            return CGRect
                .make(params: sut.params, weekCount: weekCountList[pageIndex], viewSize: frame.size)
                .map { frame in withVar(frame) { $0.origin.x += CGFloat(pageIndex) * frame.width } }
        }
        
        // displayOption - dynamic
        do { // mode: (.packed, .packed)
            expect((self.sut.layoutAttributesForElements(in: page1) ?? []).map(\.frame)).to(beCloseTo(getRect(0), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page2) ?? []).map(\.frame)).to(beCloseTo(getRect(1), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page3) ?? []).map(\.frame)).to(beCloseTo(getRect(2), within: 0.1))
            
            // H:|-16->=0-[SUN: 51][MON: 51][TUE: 51][WED: 51][THU: 51][FRI: 51][SAT: 51]->=0-16-| -> 0.5
            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<35) else { return XCTFail() }
                
                // V:|-16-[WEEK1: 40][WEEK2: 40][WEEK3: 40][WEEK4: 40][WEEK5: 40]->=16-|
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16.5, y: 16), size: .short), within: 0.1))    // week 1, sun
                expect(attribs.attributes(at: [0, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 67.5, y: 56), size: .short), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [0, 26])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 271.5, y: 136), size: .short), within: 0.1)) // week 4, fri
                expect(attribs.attributes(at: [0, 34])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 322.5, y: 176), size: .short), within: 0.1)) // week 5, sat
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page3) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                // V:|-16-[WEEK1: 40][WEEK2: 40][WEEK3: 40][WEEK4: 40][WEEK5: 40][WEEK6: 40]->=0-16-|
                expect(attribs.attributes(at: [2, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796.5, y: 16), size: .short), within: 0.1))    // week 1, sun
                expect(attribs.attributes(at: [2, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 847.5, y: 56), size: .short), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [2, 33])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1051.5, y: 176), size: .short), within: 0.1)) // week 5, fri
                expect(attribs.attributes(at: [2, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1102.5, y: 216), size: .short), within: 0.1)) // week 6, sat
            } else {
                XCTFail("expected a non-nil array")
            }
        }

        do { // mode: (.packed, .filled), v-spacing: 2
            sut.params.alignment.vertical = .filled
            sut.params.spacing.height = 2
            
            expect((self.sut.layoutAttributesForElements(in: page1) ?? []).map(\.frame)).to(beCloseTo(getRect(0), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page2) ?? []).map(\.frame)).to(beCloseTo(getRect(1), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page3) ?? []).map(\.frame)).to(beCloseTo(getRect(2), within: 0.1))

            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<35) else { return XCTFail() }
                
                // V:|-16-[WEEK1: >=40]-2-[WEEK2: >=40]-2-[WEEK3: >=40]-2-[WEEK4: >=40]-2-[WEEK5: >=40]-16-|
                let expectedSize = CGSize(width: 51, height: 56)
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16.5, y: 16), size: expectedSize), within: 0.1))    // week 1, sun
                expect(attribs.attributes(at: [0, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 67.5, y: 74), size: expectedSize), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [0, 26])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 271.5, y: 190), size: expectedSize), within: 0.1)) // week 4, fri
                expect(attribs.attributes(at: [0, 34])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 322.5, y: 248), size: expectedSize), within: 0.1)) // week 5, sat
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page3) {
                guard attribs.indices.contains(0) && attribs.indices.contains(41) else { return XCTFail() }
                
                // |-16-[WEEK1: >=40]-2-[WEEK2: >=40]-2-[WEEK3: >=40]-2-[WEEK4: >=40]-2-[WEEK5: >=40]-2-[WEEK6: >=40]-16-|
                let expectedSize = CGSize(width: 51, height: 46.33333333)
                expect(attribs.attributes(at: [2, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796.5, y: 16), size: expectedSize), within: 0.1))             // week 1, sun
                expect(attribs.attributes(at: [2, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 847.5, y: 64.33333333), size: expectedSize), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [2, 33])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1051.5, y: 209.33333334), size: expectedSize), within: 0.1)) // week 5, fri
                expect(attribs.attributes(at: [2, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1102.5, y: 257.66666667), size: expectedSize), within: 0.1)) // week 6, sat
            } else {
                XCTFail("expected a non-nil array")
            }
        }
        
        do { // mode: (.packed, .spread), v-spacing: 2
            sut.params.alignment.vertical = .spread
            
            expect((self.sut.layoutAttributesForElements(in: page1) ?? []).map(\.frame)).to(beCloseTo(getRect(0), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page2) ?? []).map(\.frame)).to(beCloseTo(getRect(1), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page3) ?? []).map(\.frame)).to(beCloseTo(getRect(2), within: 0.1))

            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<35) else { return XCTFail() }
                
                // V:|-16-[WEEK1: 40]->=2-[WEEK2: 40]->=2-[WEEK3: 40]->=2-[WEEK4: 40]->=2-[WEEK5: 40]-16-| -> spacing: 22
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16.5, y: 16), size: .short), within: 0.1))    // week 1, sun
                expect(attribs.attributes(at: [0, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 67.5, y: 78), size: .short), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [0, 26])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 271.5, y: 202), size: .short), within: 0.1)) // week 4, fri
                expect(attribs.attributes(at: [0, 34])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 322.5, y: 264), size: .short), within: 0.1)) // week 5, sat
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page3) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                // V:|-16-[WEEK1: 40]->=2-[WEEK2: 40]->=2-[WEEK3: 40]->=2-[WEEK4: 40]->=2-[WEEK5: 40]->=2-[WEEK6: 40]16-| -> spacing: 9.6
                expect(attribs.attributes(at: [2, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796.5, y: 16), size: .short), within: 0.1))      // week 1, sun
                expect(attribs.attributes(at: [2, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 847.5, y: 65.6), size: .short), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [2, 33])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1051.5, y: 214.4), size: .short), within: 0.1)) // week 5, fri
                expect(attribs.attributes(at: [2, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1102.5, y: 264), size: .short), within: 0.1))   // week 6, sat
            } else {
                XCTFail("expected a non-nil array")
            }
        }
        
        // displayOption - fixed
        adapter.displayOption = .fixed
        do { // mode: (.filled, .filled), 40x40, h-spacing: 2, v-spacing: 2
            sut.params.alignment = .init(horizontal: .filled, vertical: .filled)
            sut.params.spacing = .init(width: 2, height: 2)
            sut.params.itemSize.width = 40
            
            // H:|-16-[S: >=40]-2-[M: >=40]-2-[T: >=40]-2-[W: >=40]-2-[T: >=40]-2-[F: >=40]-2-[S: >=40]-16-|
            // V:|-16-[WEEK1: >=40]-2-[WEEK2: >=40]-2-[WEEK3: >=40]-2-[WEEK4: >=40]-2-[WEEK5: >=40]-2-[WEEK6: >=40]-16-|
            let expectedSize = CGSize(width: 49.42857142, height: 46.33333333)
            expect((self.sut.layoutAttributesForElements(in: page1) ?? []).map(\.frame)).to(beCloseTo(getRect(0), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page2) ?? []).map(\.frame)).to(beCloseTo(getRect(1), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page3) ?? []).map(\.frame)).to(beCloseTo(getRect(2), within: 0.1))
            
            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16, y: 16), size: expectedSize), within: 0.1))                      // week 1, sun
                expect(attribs.attributes(at: [0, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 67.42857142, y: 64.33333333), size: expectedSize), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [0, 33])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 273.1428571, y: 209.33333334), size: expectedSize), within: 0.1))  // week 5, fri
                expect(attribs.attributes(at: [0, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 324.57142858, y: 257.66666667), size: expectedSize), within: 0.1)) // week 6, sat
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page3) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                expect(attribs.attributes(at: [2, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796, y: 16), size: expectedSize), within: 0.1))
                expect(attribs.attributes(at: [2, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1104.57142858, y: 257.66666667), size: expectedSize), within: 0.1))
            } else {
                XCTFail("expected a non-nil array")
            }
        }
        
        do { // mode: (.spread, .spread), width: 40, h-spacing: 2, v-spacing: 2
            sut.params.alignment = .init(horizontal: .spread, vertical: .spread)
            
            // H:|-16-[S: 40]->=2-[M: 40]->=2-[T: 40]->=2-[W: 40]->=2-[T: 40]->=2-[F: 40]->=2-[S: 40]-16-| -> 13
            // V:|-16-[WEEK1: 40]->=2-[WEEK2: 40]->=2-[WEEK3: 40]->=2-[WEEK4: 40]->=2-[WEEK5: 40]->=2-[WEEK6: 40]-16-| -> 9.6
            let expectedSize = CGSize(width: 40, height: 40)
            expect((self.sut.layoutAttributesForElements(in: page1) ?? []).map(\.frame)).to(beCloseTo(getRect(0), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page2) ?? []).map(\.frame)).to(beCloseTo(getRect(1), within: 0.1))
            expect((self.sut.layoutAttributesForElements(in: page3) ?? []).map(\.frame)).to(beCloseTo(getRect(2), within: 0.1))
            
            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16, y: 16), size: expectedSize), within: 0.1))      // week 1, sun
                expect(attribs.attributes(at: [0, 8])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 69, y: 65.6), size: expectedSize), within: 0.1))    // week 2, mon
                expect(attribs.attributes(at: [0, 33])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 281, y: 214.4), size: expectedSize), within: 0.1)) // week 5, fri
                expect(attribs.attributes(at: [0, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 334, y: 264), size: expectedSize), within: 0.1))   // week 6, sat
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page3) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                expect(attribs.attributes(at: [2, 0])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796, y: 16), size: expectedSize), within: 0.1))
                expect(attribs.attributes(at: [2, 41])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 1114, y: 264), size: expectedSize), within: 0.1))
            } else {
                XCTFail("expected a non-nil array")
            }
        }
        
        // oversized pages
        do {
            sut.params.spacing = .zero
            sut.params.sectionInset = .zero
            sut.params.alignment = .init(horizontal: .packed, vertical: .filled)
            sut.params.itemSize = CGSize(width: 50, height: 50)
            adapter.view.frame.size = CGSize(width: 300, height: 270)
            
            // H:|[S][M][T][W][T][F]| ([S]) - saturday spills over to the next page and overlaps the sunday of the next month
            // V:|[W1][W2][W3][W4][W5][W6]| - week 6 spills over the view frame
            if let attribs = sut.layoutAttributesForElements(in: page1) {
                guard attribs.indices == (0..<36) else { return XCTFail() }
                
                let expectedSize = CGSize(width: 50, height: 50)
                expect(attribs.attributes(at: [0, 0])?.frame).to(beCloseTo(CGRect(origin: .zero, size: expectedSize), within: 0.1))                 // week 1, sun
                expect(attribs.attributes(at: [0, 7])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 50, y: 50), size: expectedSize), within: 0.1)) // week 2, mon (only 6 days fit in the view frame)
                expect(attribs.attributes(at: [0, 28])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 200, y: 200), size: expectedSize), within: 0.1))    // week 5, thu
                expect(attribs.attributes(at: [0, 35])?.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 250, y: 250), size: expectedSize), within: 0.1))    // week 6, fri
            } else {
                XCTFail("expected a non-nil array")
            }
            
            if let attribs = sut.layoutAttributesForElements(in: page2) {
                guard attribs.indices == (0..<42) else { return XCTFail() }
                
                // next page still starts at the correct position
                expect(attribs.filter { $0.frame.origin.x == 300 }).to(haveCount(12)) // prev month saturdays + current month sundays
            } else {
                XCTFail("expected a non-nil array")
            }
        }
    }
    
    func test_layoutAttributesForItemAtIndexPath() throws {
        let sep2022 = try ISO8601Month(year: 2022, month: 9)
        
        setUp(
            params: .init(itemSize: .short),
            frame: .init(origin: .zero, size: .Device.iPhone12),
            initialMonth: sep2022)
        
        // infinite range
        if let attribs = sut.layoutAttributesForItem(at: IndexPath(indexes: [0, 0])) {
            expect(attribs.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 16.5, y: 0), size: .short), within: 0.1))
        } else {
            XCTFail()
        }
        
        if let attribs = sut.layoutAttributesForItem(at: IndexPath(indexes: [1, 10])) {
            expect(attribs.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 559.5, y: 40), size: .short), within: 0.1))
        } else {
            XCTFail()
        }
        
        if let attribs = sut.layoutAttributesForItem(at: IndexPath(indexes: [2, 0])) {
            expect(attribs.frame).to(beCloseTo(CGRect(origin: CGPoint(x: 796.5, y: 0), size: .short), within: 0.1))
        } else {
            XCTFail()
        }
        
        XCTAssertNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [3, 0])))
        
        // infinite range bounded on one-side
        adapter.monthRange = Pair(nil, sep2022)
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [0, 0])))
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [1, 0])))
        XCTAssertNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [2, 0])))
        
        adapter.currentMonth = sep2022.advanced(by: -1)
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [0, 0])))
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [1, 0])))
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [2, 0])))
        
        // finite range
        adapter.monthRange = Pair(sep2022.advanced(by: -1), sep2022)
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [0, 0])))
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [1, 0])))
        XCTAssertNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [2, 0])))
        
        adapter.currentMonth = sep2022
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [0, 0])))
        XCTAssertNotNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [1, 0])))
        XCTAssertNil(sut.layoutAttributesForItem(at: IndexPath(indexes: [2, 0])))
    }
    
    func test_shouldInvalidateLayoutForBoundsChange() {
        let initialFrame = CGRect(origin: .zero, size: CGSize(width: 390, height: 320))
                                  
        setUp(
            params: CalendarLayout.Params(itemSize: .short),
            frame: initialFrame)
        
        // v-align .packed is unaffected by height changes
        sut.params.alignment.horizontal = [.filled, .packed, .spread].randomElement()!
        sut.params.alignment.vertical = .packed
        
        XCTAssertTrue(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.width = 400 }))
        XCTAssertFalse(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.height = 30 }))
        XCTAssertFalse(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.height = 390 }))
        
        // otherwise, invalidated
        sut.params.alignment.vertical = [.filled, .spread].randomElement()!
        XCTAssertTrue(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.width = 400 }))
        XCTAssertTrue(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.height = 30 }))
        XCTAssertTrue(sut.shouldInvalidateLayout(forBoundsChange: withVar(initialFrame) { $0.size.height = 390 }))
    }
    
}

private extension UIEdgeInsets {
    static let test = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    var vertical: CGFloat { top + bottom }
    var horizontal: CGFloat { left + right }
}

private extension CGSize {
    
    static let short = CGSize(width: 51, height: 40)
    static let tall  = CGSize(width: 51, height: 50)
    
}

private extension CGFloat {
    
    static let short5week = UIEdgeInsets.test.vertical + CGSize.short.height * 5
    static let short6week = UIEdgeInsets.test.vertical + CGSize.short.height * 6
    
    static let tall5week = UIEdgeInsets.test.vertical + CGSize.tall.height * 5
    static let tall6week = UIEdgeInsets.test.vertical + CGSize.tall.height * 6
    
}

private extension CGRect {
    
    static func make(params: CalendarLayout.Params, weekCount: UInt, viewSize: CGSize) -> [CGRect] {
        let minContentSize = minContentSize(weekCount: Int(weekCount), params: params)
        
        return zip(
            horizontalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.width - minContentSize.width),
            verticalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.height - minContentSize.height))
            .map { hor, ver in CGRect(x: hor.0, y: ver.0, width: hor.1, height: ver.1) }
    }
    
    static private func minContentSize(weekCount: Int, params: CalendarLayout.Params) -> CGSize {
        CGSize(
            width: params.sectionInset.horizontal + params.itemSize.width * 7 + params.spacing.width * 6,
            height: params.sectionInset.vertical + params.itemSize.height * CGFloat(weekCount) + params.spacing.height * CGFloat(weekCount - 1))
    }
    
    static private func originX(weekdayIndex: Int, leftInset: CGFloat, itemWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        leftInset + itemWidth * CGFloat(weekdayIndex) + spacing * CGFloat(max(weekdayIndex-1, 0))
    }
    
    static private func originY(weekIndex: Int, topInset: CGFloat, itemHeight: CGFloat, spacing: CGFloat) -> CGFloat {
        topInset + itemHeight * CGFloat(weekIndex) + spacing * CGFloat(max(weekIndex-1, 0))
    }
    
    /// - Returns: A list of `($ORIGIN_X, $WIDTH)` tuples.
    static private func horizontalValues(params: CalendarLayout.Params, weekCount: Int, remainingSpace: CGFloat) -> [(CGFloat, CGFloat)] {
        let defaultLayout = (0 ..< weekCount).flatMap(bindNone {
            (0 ..< 7).map { (originX(weekdayIndex: $0, leftInset: params.sectionInset.left, itemWidth: params.itemSize.width, spacing: params.spacing.width), params.itemSize.width) }
        })
        
        if remainingSpace <= 0.0 {
            return defaultLayout
        } else {
            switch params.alignment.horizontal {
            case .packed:
                let extraLeftInset = remainingSpace * 0.5
                return defaultLayout.map { x, width in (x + extraLeftInset, width) }
            case .filled:
                let extraWidth = remainingSpace / 7
                return defaultLayout.enumerated()
                    .map { i, values in (values.0 + extraWidth * CGFloat(i % 7), values.1 + extraWidth) }
            case .spread:
                let extraSpace = remainingSpace / 6
                return defaultLayout.enumerated()
                    .map { i, values in (values.0 + extraSpace * CGFloat(i % 7), values.1) }
            }
        }
    }
    
    /// - Returns: A list of `($ORIGIN_Y, $HEIGHT)` tuples.
    static private func verticalValues(params: CalendarLayout.Params, weekCount: Int, remainingSpace: CGFloat) -> [(CGFloat, CGFloat)] {
        let defaultLayout = (0 ..< weekCount).flatMap { weekIndex in
            (0 ..< 7).map(bindNone { (originY(weekIndex: Int(weekIndex), topInset: params.sectionInset.top, itemHeight: params.itemSize.height, spacing: params.spacing.height), params.itemSize.height) })
        }
        
        if remainingSpace <= 0.0 {
            return defaultLayout
        } else {
            switch params.alignment.vertical {
            case .packed: return defaultLayout
            case .filled:
                let extraHeight = remainingSpace / CGFloat(weekCount)
                return defaultLayout.enumerated()
                    .map { i, values in (values.0 + extraHeight * CGFloat(i/7), values.1 + extraHeight) }
            case .spread:
                let extraSpace = remainingSpace / CGFloat(weekCount - 1)
                return defaultLayout.enumerated()
                    .map { i, values in (values.0 + extraSpace * CGFloat(i/7), values.1) }
            }
        }

    }
    
}
