//
//  CalendarAdapter.UICollectionViewAdapter.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/19.
//

import UIKit

extension CalendarAdapter {
    
    class UICollectionViewAdapter : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where Cell : UICollectionViewCell {
        
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
            
            return calendarAdapter.viewProvider.getCell(
                collectionView: collectionView,
                for: CalendarAdapterContext(date: date, position: assign {
                    let sectionMonth = _getMonth(section: indexPath.section)
                    if date.month < sectionMonth {
                        return .leading
                    } else if date.month == sectionMonth {
                        return .main
                    } else {
                        return .trailing
                    }
                }))
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
    
    func _getMonth(section: Int) -> ISO8601Month {
        switch calendarAdapter.monthRange.toTuple() {
        case let (lowerBound?, _):
            return lowerBound.advanced(by: section)
        case let (nil, upperBound?):
            if upperBound == calendarAdapter.currentMonth {
                let offset = section + 1 - _numberOfSections()
                return upperBound.advanced(by: offset)
            } else {
                fallthrough
            }
            
        case (nil, nil):
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
