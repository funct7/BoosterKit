//
//  CalendarAdapter.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/13.
//

import UIKit

/**
 A flag that determines the display behavior when `CalendarAdapter` displays a 6-week month.
 */
public enum CalendarAdapterDisplayOption {
    /// The height of the `UICollectionView` expands while `Cell` heights are fixed.
    case flexibleMonthHeight
    /// The height of the `UICollectionView` is fixed while `Cell` height shrinks.
    case flexibleDayHeight
    /// Both the height of tthe `UICollectionView` and `Cell` are fixed.
    ///
    /// Six weeks are shown for all months, and for 5-week months, the following month fills the bottom row.
    case fillNextMonth
}

// TODO: Generalize
open class CalendarAdapter<Cell> where Cell : UICollectionViewCell {
    
    @IBOutlet open weak var view: UICollectionView? = nil
    open var viewProvider: AnyCalendarAdapterComponentViewProvider<Cell>
    open var delegate: AnyCalendarAdapterDelegate<Cell>? = nil
    open var displayOption: CalendarAdapterDisplayOption = .flexibleMonthHeight
    
    open var currentMonth: Month {
        get { fatalError() }
        set { }
    }
//    open var monthRange:
    open func getCell(date: ISO8601Date) -> Cell? { nil }
    open func scroll(to month: Month) { }
    
    /// Elements are ordered by their selection order, not the natural order of `ISO8601Date`.
    open var selectedDates: [ISO8601Date] {
        get { fatalError() }
        set { }
    }
    open func toggleSelection(date: ISO8601Date) {
    }
    
    /**
     - Attention: The constructed instance will hold an **unowned reference** to the `viewProvider`.
        It is up to the caller to make sure that `viewProvider` lives throughout the lifecycle of the created `CalendarAdapter` instance
        or provide a new `AnyCalendarAdapterComponentViewProvider` should the `viewProvider` be released somewhere if the lifecycle.
     */
    public init<P>(viewProvider: P) where P : CalendarAdapterComponentViewProvider, P.Cell == Cell {
        self.viewProvider = .init(viewProvider)
    }
}

public protocol CalendarAdapterComponentViewProvider : AnyObject {
    associatedtype Cell : UICollectionViewCell
    func cellForContext(_ context: CalendarAdapterContext) -> Cell
    func decorationViewForWeekday(_ weekday: Weekday) -> UIView?
    func headerViewForWeekday(_ weekday: Weekday) -> UIView?
}

/**
 A type-erased `CalendarAdapterComponentViewProvider`.
 */
open class AnyCalendarAdapterComponentViewProvider<Cell> : CalendarAdapterComponentViewProvider where Cell : UICollectionViewCell {

    private let _cellForContext: (CalendarAdapterContext) -> Cell
    open func cellForContext(_ context: CalendarAdapterContext) -> Cell { _cellForContext(context) }
    
    private let _decorationViewForWeekday: (Weekday) -> UIView?
    open func decorationViewForWeekday(_ weekday: Weekday) -> UIView? { _decorationViewForWeekday(weekday) }
    
    private let _headerViewForWeekday: (Weekday) -> UIView?
    open func headerViewForWeekday(_ weekday: Weekday) -> UIView? { _headerViewForWeekday(weekday) }
    
    /**
     - Attention: The constructed instance will hold an **unowned reference** to the `viewProvider`.
        It is up to the caller to make sure that `viewProvider` lives throughout the lifecycle of the created `AnyCalendarAdapterComponentViewProvider` instance.
     */
    public init<P>(_ viewProvider: P) where P : CalendarAdapterComponentViewProvider, P.Cell == Cell {
        self._cellForContext = { [unowned viewProvider] in viewProvider.cellForContext($0) }
        self._decorationViewForWeekday = { [unowned viewProvider] in viewProvider.decorationViewForWeekday($0) }
        self._headerViewForWeekday = { [unowned viewProvider] in viewProvider.headerViewForWeekday($0) }
    }
}

public protocol CalendarAdapterDelegate : AnyObject {
    associatedtype Cell : UICollectionViewCell
    /**
     This method is called immediately when the user stops dragging and it is determined which month the calendar will animate to.
     */
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: Month, to newValue: Month)
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: Month, to newValue: Month)
}

/**
 A type-erased `CalendarAdapterDelgate`.
 */
open class AnyCalendarAdapterDelegate<Cell> : CalendarAdapterDelegate where Cell : UICollectionViewCell {
    
    private let _willChangeMonth: (CalendarAdapter<Cell>, Month, Month) -> Void
    open func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: Month, to newValue: Month) { _willChangeMonth(presenter, oldValue, newValue) }
    
    private let _didChangeMonth: (CalendarAdapter<Cell>, Month, Month) -> Void
    open func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: Month, to newValue: Month) { _didChangeMonth(presenter, oldValue, newValue) }
    
    /**
     - Note: The constructed `AnyCalendarAdapterDelegate` instance will **NOT** hold a strong reference to the provided `delegate`.
        As a result, invoking methods will have no effect if the `delegate` is released.
     */
    public init<D>(_ delegate: D) where D : CalendarAdapterDelegate, D.Cell == Cell {
        self._willChangeMonth = { [weak delegate] in delegate?.calendarPresenter($0, willChangeMonthFrom: $1, to: $2) }
        self._didChangeMonth = { [weak delegate] in delegate?.calendarPresenter($0, didChangeMonthFrom: $1, to: $2) }
    }
}

public struct Month : Equatable { }

public struct ISO8601Date : Equatable { }

public struct CalendarAdapterContext { }

public enum Weekday {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}
