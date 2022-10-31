//
//  CalendarAdapterDelegate.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/31.
//

import UIKit

public protocol CalendarAdapterDelegate : AnyObject {
    associatedtype Cell : UICollectionViewCell
    /**
     This method is called immediately when the user stops dragging and it is determined which month the calendar will animate to.
     */
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month)
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month)
}

/**
 A type-erased `CalendarAdapterDelgate`.
 */
open class AnyCalendarAdapterDelegate<Cell> : CalendarAdapterDelegate where Cell : UICollectionViewCell {
    
    private let _willChangeMonth: (CalendarAdapter<Cell>, ISO8601Month, ISO8601Month) -> Void
    open func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month) { _willChangeMonth(presenter, oldValue, newValue) }
    
    private let _didChangeMonth: (CalendarAdapter<Cell>, ISO8601Month, ISO8601Month) -> Void
    open func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month) { _didChangeMonth(presenter, oldValue, newValue) }
    
    /**
     - Note: The constructed `AnyCalendarAdapterDelegate` instance will **NOT** hold a strong reference to the provided `delegate`.
        As a result, invoking methods will have no effect if the `delegate` is released.
     */
    public init<D>(_ delegate: D) where D : CalendarAdapterDelegate, D.Cell == Cell {
        self._willChangeMonth = { [weak delegate] in delegate?.calendarPresenter($0, willChangeMonthFrom: $1, to: $2) }
        self._didChangeMonth = { [weak delegate] in delegate?.calendarPresenter($0, didChangeMonthFrom: $1, to: $2) }
    }
}
