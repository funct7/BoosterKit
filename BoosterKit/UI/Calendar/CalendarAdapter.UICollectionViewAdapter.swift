//
//  CalendarAdapter.UICollectionViewAdapter.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/19.
//

import UIKit

extension CalendarAdapter {
    
    class UICollectionViewAdapter : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where Cell : UICollectionViewCell {
        
        private var _viewProvider: AnyCalendarAdapterComponentViewProvider<Cell> { calendarAdapter.viewProvider }
        unowned let calendarAdapter: CalendarAdapter<Cell>

        init(calendarAdapter: CalendarAdapter<Cell>) {
            self.calendarAdapter = calendarAdapter
        }
        
        private var _cache: [ISO8601Month : LayoutPlan] = [:]
        
        func numberOfSections(in collectionView: UICollectionView) -> Int { _numberOfSections() }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let month = _getMonth(section: section)
            
            if _cache[month] == nil { _cache[month] = .create(month: month) }
            
            switch calendarAdapter.displayOption {
            case .dynamic:
                return Int(_cache[month]!.numberOfWeeks * 7)
            case .fixed:
                return 42
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let date = _getDate(indexPath: indexPath)
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: _viewProvider.getCellIdentifier(),
                for: indexPath)
                as! Cell
            
            _viewProvider.configure(cell, with: CalendarDateContext(date: date, position: assign {
                let sectionMonth = _getMonth(section: indexPath.section)
                if date.month < sectionMonth {
                    return .leading
                } else if date.month == sectionMonth {
                    return .main
                } else {
                    return .trailing
                }
            }))
            
            return cell
        }
        
        private var _targetPageIndex: Int? = nil
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            if let _ = _targetPageIndex { _resolveMonthChange(scrollView: scrollView) }
        }
        
        private func _startMonthChange(scrollView: UIScrollView, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let pageWidth = scrollView.frame.width
            let pageIndex = Int(targetContentOffset.pointee.x / pageWidth)
            let currentMonth = calendarAdapter.currentMonth
            let targetMonth = _getMonth(section: pageIndex)
            
            if currentMonth == targetMonth { return }
            
            calendarAdapter.delegate?.calendarPresenter(calendarAdapter, willChangeMonthFrom: currentMonth, to: targetMonth)
            
            _targetPageIndex = pageIndex
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            _startMonthChange(scrollView: scrollView, targetContentOffset: targetContentOffset)
        }
        
        private func _resolveMonthChange(scrollView: UIScrollView) {
            guard let targetPageIndex = _targetPageIndex else { return }
            
            let targetMonth = _getMonth(section: targetPageIndex)
            let currentMonth = calendarAdapter.currentMonth
            
            calendarAdapter.loadFocusMonth(targetMonth)
            
            let _ = withVar(scrollView.frame.width) { pageWidth in
                guard calendarAdapter.monthRange.isInfinite else { return }
                
                let shouldAdjustOffset: Bool = assign {
                    let isTargetMinPage = targetMonth == calendarAdapter.monthRange.first,
                        isCurrentMinPage = currentMonth == calendarAdapter.monthRange.first
                    return !(isTargetMinPage || isCurrentMinPage)
                }
                
                guard shouldAdjustOffset else { assert((0...1).contains(targetPageIndex), "invalid page index: \(targetPageIndex)"); return }
                
                switch targetPageIndex {
                case 0: scrollView.contentOffset.x += pageWidth
                case 2: scrollView.contentOffset.x -= pageWidth
                default: assertionFailure("invalid page index: \(targetPageIndex)")
                }
            }
            
            _targetPageIndex = nil
            
            calendarAdapter.delegate?.calendarPresenter(calendarAdapter, didChangeMonthFrom: currentMonth, to: targetMonth)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            _resolveMonthChange(scrollView: scrollView)
        }
        
    }
    
}

extension CalendarAdapter.UICollectionViewAdapter {
    
//    static var weekdayViewID: String { "WEEKDAY_VIEW" }
    
    struct LayoutPlan : Hashable {
        let leadingDays: UInt
        let numberOfDays: UInt
        let numberOfWeeks: UInt
        let trailingDays: UInt
        
        static func create(month: ISO8601Month) -> Self {
            let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = month.timeZone }
            let firstDay = ISO8601Date(date: month.instantRange.lowerBound, timeZone: month.timeZone)
            let nextMonthFirstDay = ISO8601Date(date: month.instantRange.upperBound, timeZone: month.timeZone)
            
            let leadingDays = cal.dateComponents([.weekday], from: firstDay.instantRange.lowerBound).weekday! - 1
            let numberOfDays = try! firstDay.distance(to: nextMonthFirstDay)
            let numberOfWeeks = (leadingDays + numberOfDays + 7 - 1) / 7
            let trailingDays: Int = assign {
                let lastDay = nextMonthFirstDay.advanced(by: -1)
                return 7 - cal.dateComponents([.weekday], from: lastDay.instantRange.lowerBound).weekday!
            }
            
            return LayoutPlan(
                leadingDays: UInt(leadingDays),
                numberOfDays: UInt(numberOfDays),
                numberOfWeeks: UInt(numberOfWeeks),
                trailingDays: UInt(trailingDays))
        }
    }

}

extension CalendarAdapter.UICollectionViewAdapter {
    
    /**
     - Parameters:
        - date: The date whose visible index path to fetch.
     
     - Precondition: `date.timeZone` is the same as the time zone currently used by the class.
     - Returns: `nil` if `date` is not visible or is out of range.
     */
    func getVisibleIndexPath(date: ISO8601Date) throws -> IndexPath? {
        assert(date.timeZone == calendarAdapter.currentMonth.timeZone)
        
        let currentMonth = calendarAdapter.currentMonth
        let layoutPlan = LayoutPlan.create(month: currentMonth)
        let lowerBound = currentMonth.dateRange.lowerBound.advanced(by: -Int(layoutPlan.leadingDays))
        let upperBound: ISO8601Date = assign {
            switch calendarAdapter.displayOption {
            case .dynamic:
                return currentMonth.dateRange.upperBound.advanced(by: Int(layoutPlan.trailingDays) - 1)
            case .fixed:
                return lowerBound.advanced(by: 41)
            }
        }
        
        guard (lowerBound...upperBound).contains(date) else { return nil }
        
        return IndexPath(indexes: [
            _getSection(month: currentMonth)!,
            try! lowerBound.distance(to: date)
        ])
    }
    
    /// - Returns: The range of `ISO8601Month` that matches the bounds of the current data set of `UICollectionView`.
    func getDataSourceRange() -> ClosedRange<ISO8601Month> {
        assert(_numberOfSections() > 0)
        return (_getMonth(section: 0) ... _getMonth(section: _numberOfSections() - 1))
    }
    
}

private extension CalendarAdapter.UICollectionViewAdapter {

    func _numberOfSections() -> Int {
        switch calendarAdapter.monthRange.toTuple() {
        case let (lowerBound?, upperBound?):
            return try! lowerBound.distance(to: upperBound) + 1
        case (let someBound?, nil), (nil, let someBound?):
            return calendarAdapter.currentMonth == someBound ? 2 : 3
        default:
            return 3
        }
    }
    
    /**
     - Returns: The section of `month` as the collection view would show it.
        `nil` may be returned even if `month` is within range of the `CalendarAdapter`.
     */
    func _getSection(month: ISO8601Month) -> Int? {
        assert(month.timeZone == calendarAdapter.currentMonth.timeZone)
        
        let dataSourceRange = getDataSourceRange()
        guard dataSourceRange.contains(month) else { return nil }
        return try! dataSourceRange.lowerBound.distance(to: month)
    }
    
    func _getMonth(section: Int) -> ISO8601Month {
        switch calendarAdapter.monthRange.toTuple() {
        case let (lowerBound?, _?):
            return lowerBound.advanced(by: section)
        case let (lowerBound?, nil) where lowerBound == calendarAdapter.currentMonth:
            return lowerBound.advanced(by: section)
        case let (nil, upperBound?) where upperBound == calendarAdapter.currentMonth:
            return upperBound.advanced(by: section - 1)
        default:
            precondition((0...2).contains(section))
            return calendarAdapter.currentMonth.advanced(by: section - 1)
        }
    }
    
    func _getDate(indexPath: IndexPath) -> ISO8601Date {
        let month = _getMonth(section: indexPath.section)
        
        assert(_cache[month] != nil)
        
        let offset = indexPath.item - Int(_cache[month]!.leadingDays)
        return month.dateRange.lowerBound.advanced(by: offset)
    }
    
}
