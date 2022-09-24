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
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            switch calendarAdapter.monthRange.toTuple() {
            case let (lowerBound?, upperBound?):
                return try! lowerBound.distance(to: upperBound) + 1
            case (let someBound?, nil), (nil, let someBound?):
                return calendarAdapter.currentMonth == someBound ? 2 : 3
            default:
                return 3
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            precondition((0...2).contains(section))
            
            let month = calendarAdapter.currentMonth.advanced(by: section - 1)
            
            if _cache[month] == nil { _cache[month] = .create(month: month) }
            
            return Int(_cache[month]!.numberOfDays)
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            calendarAdapter.viewProvider.getCell(
                collectionView: collectionView,
                for: _getLayoutContext(indexPath: indexPath))
        }
        
        private func _getLayoutContext(indexPath: IndexPath) -> CalendarAdapterContext {
            fatalError()
        }
        
    }
    
}

extension CalendarAdapter.UICollectionViewAdapter {
    
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
