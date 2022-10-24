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
    /**
     Each month shows only the necessary number of weeks.
     
     For most months, 5 weeks will be shown.
     For months like Feb 2015 or Oct 2022, 4 weeks and 6 weeks will be shown respectively.
     */
    case dynamic
    /**
     Six weeks are shown for all months, and for 4 or 5-week months, days from the following month fill the bottom row(s).
     */
    case fixed
}

// TODO: Generalize
open class CalendarAdapter<Cell> where Cell : UICollectionViewCell {
    
    private var _calendarLayout: CalendarLayout! {
        guard let view = view else { return nil }
        return (view.collectionViewLayout as! CalendarLayout)
    }
    /**
     - Invariant: `view.collectionViewLayout is CalendarLayout`
     */
    @IBOutlet open weak var view: UICollectionView! = nil {
        willSet {
            assert(newValue.collectionViewLayout is CalendarLayout)
        }
        didSet {
            view.dataSource = _adapter
            view.delegate = _adapter
            // layout object needs initial data
            _calendarLayout.invalidateLayoutIfNeeded(dataSet: _dataSet)
            view.reloadData()
        }
    }
    open var viewProvider: AnyCalendarAdapterComponentViewProvider<Cell>
    open var delegate: AnyCalendarAdapterDelegate<Cell>? = nil
    
    private var _dataSet: CalendarLayout.DataSet { .init(displayOption: displayOption, monthRange: monthRange, currentMonth: _currentMonth) }
    open var displayOption: CalendarAdapterDisplayOption = .dynamic {
        didSet {
            _calendarLayout?.invalidateLayoutIfNeeded(dataSet: _dataSet)
            view?.reloadData()
        }
    }
    
    private var _currentMonth: ISO8601Month
    
    private func _alignContentOffsetToCurrentMonth() {
        view.contentOffset.x = assign {
            let pageIndex = monthRange.isInfinite ? 1 : try! monthRange.first!.distance(to: _currentMonth)
            return view.frame.width * CGFloat(pageIndex)
        }
    }
    
    func loadCurrentMonthData(_ newValue: ISO8601Month) {
        if _currentMonth == newValue { return }
        
        switch monthRange.toTuple() {
        case (nil, nil): break
        case (let lowerBound?, nil): precondition(lowerBound <= newValue && lowerBound.timeZone == newValue.timeZone)
        case (nil, let upperBound?): precondition(newValue <= upperBound && upperBound.timeZone == newValue.timeZone)
        case (let lowerBound?, let upperBound?): precondition(lowerBound <= newValue && newValue <= upperBound && lowerBound.timeZone == newValue.timeZone)
        }
        
        _currentMonth = newValue

        guard let _ = view else { return }
        
        _calendarLayout.invalidateLayoutIfNeeded(dataSet: _dataSet)
        if monthRange.isInfinite { view.reloadData() }
    }
    
    /// Updates the displayed month.
    /// - Invariant: `currentMonth` must be within `monthRange` and have the same time zone as the values in `monthRange`.
    open var currentMonth: ISO8601Month {
        get { _currentMonth }
        set {
            loadCurrentMonthData(newValue)
            _alignContentOffsetToCurrentMonth()
        }
    }
    
    /**
     - Note: `first` and `second` form **inclusive** bounds if non-`nil`.
     - Invariant:
        - `first` and `second` must have the same `timeZone` value if non-`nil`.
        - `first` <= `second` if non-`nil`.
        - `currentMonth` must be within `monthRange`.
        
            If a new `monthRange` value does not include `currentMonth`, `currentMonth` is set to the closest value within the new range.
        
            For example, if `currentMonth` is Sep 2022 and `monthRange` is set to [Jan 2023, nil],
            the value of `currentMonth` will be changed to Jan 2023.
     */
    open var monthRange: Pair<ISO8601Month?, ISO8601Month?> {
        willSet {
            if let first = newValue.first, let second = newValue.second {
                precondition(first.timeZone == second.timeZone)
                precondition(first <= second)
            }
        }
        didSet {
            switch monthRange.toTuple() {
            case (let lowerBound?, nil) where _currentMonth < lowerBound: _currentMonth = lowerBound
            case (nil, let upperBound?) where upperBound < _currentMonth: _currentMonth = upperBound
            case (let lowerBound?, let upperBound?):
                if _currentMonth < lowerBound { _currentMonth = lowerBound }
                else if upperBound < _currentMonth { _currentMonth = upperBound }
                else {
                    _calendarLayout?.invalidateLayoutIfNeeded(dataSet: _dataSet)
                    view?.reloadData()
                }
            default:
                _calendarLayout?.invalidateLayoutIfNeeded(dataSet: _dataSet)
                view?.reloadData()
            }
        }
    }
    open func getCell(date: ISO8601Date) -> Cell? { nil }
    open func scroll(to month: ISO8601Month) { }
    
    open func reload() { }
    open func reloadDate(_ date: ISO8601Date) { }
    
    /// Elements are ordered by their selection order, not the natural order of `ISO8601Date`.
    open var selectedDates: [ISO8601Date] = []
    open func toggleSelection(date: ISO8601Date) {
    }
    
    private lazy var _adapter = UICollectionViewAdapter(calendarAdapter: self)
    
    /**
     - Parameters:
        - initialMonth: The initial month to display.
     
            It is a programmer error to provide an `initialMonth` value that falls outside of `monthRange`.
        - monthRange: The range of months to display. If both values are `nil`, the calendar will show from the infinite past to the inifinite future.
     
            `monthRange.first` will be considered to be the lower bound, and `monthRange.second` the upper bound.
     - Precondition:
        - If both values are provided for `monthRange`, `monthRange.first! <= monthRange.second`.!
        - The `initialMonth` value must fall within the provided `monthRange`.
     - Attention: The constructed instance will hold an **unowned reference** to the `viewProvider`.
        It is up to the caller to make sure that `viewProvider` lives throughout the lifecycle of the created `CalendarAdapter` instance
        or provide a new `AnyCalendarAdapterComponentViewProvider` should the `viewProvider` be released somewhere if the lifecycle.
     */
    public init<P>(
        initialMonth: ISO8601Month = .init(),
        monthRange: Pair<ISO8601Month?, ISO8601Month?> = Pair((nil, nil)),
        viewProvider: P)
    where P : CalendarAdapterComponentViewProvider, P.Cell == Cell
    {
        precondition(monthRange.first == nil || monthRange.second == nil || monthRange.first! <= monthRange.second!)
        precondition(monthRange.first != nil ? monthRange.first! <= initialMonth : true)
        precondition(monthRange.second != nil ? initialMonth <= monthRange.second! : true)
        
        self._currentMonth = initialMonth
        self.monthRange = monthRange
        self.viewProvider = .init(viewProvider)
    }
}

public protocol CalendarAdapterComponentViewProvider : AnyObject {
    associatedtype Cell : UICollectionViewCell
    /**
     - Returns: The identifier that is used to dequeue the `Cell`.
        
        The `UICollectionViewCell` that is dequeued from the collection view using the value **MUST** be a type of `Cell`.
     */
    func getCellIdentifier() -> String
    func configure(_ cell: Cell, with context: CalendarAdapterContext)
}

/**
 A type-erased `CalendarAdapterComponentViewProvider`.
 */
open class AnyCalendarAdapterComponentViewProvider<Cell> : CalendarAdapterComponentViewProvider where Cell : UICollectionViewCell {
    
    private let _getCellIdentifier: () -> String
    public func getCellIdentifier() -> String { _getCellIdentifier() }

    private let _configureCellWithContext: (Cell, CalendarAdapterContext) -> Void
    public func configure(_ cell: Cell, with context: CalendarAdapterContext) { _configureCellWithContext(cell, context) }
    
    /**
     - Attention: The constructed instance will hold an **unowned reference** to the `viewProvider`.
        It is up to the caller to make sure that `viewProvider` lives throughout the lifecycle of the created `AnyCalendarAdapterComponentViewProvider` instance.
     */
    public init<P>(_ viewProvider: P) where P : CalendarAdapterComponentViewProvider, P.Cell == Cell {
        self._getCellIdentifier = { [unowned viewProvider] in viewProvider.getCellIdentifier() }
        self._configureCellWithContext = { [unowned viewProvider] in viewProvider.configure($0, with: $1) }
    }
}

public protocol CalendarAdapterDelegate : AnyObject {
    associatedtype Cell : UICollectionViewCell
    /**
     This method is called immediately when the user stops dragging and it is determined which month the calendar will animate to.
     */
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month)
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month)
}

private enum _CollectionViewSection {
    static let prevMonth = 0
    static let currentMonth = 1
    static let nextMonth = 2
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

public struct CalendarAdapterContext : Equatable {
    public enum Position {
        case leading
        case main
        case trailing
    }
    
    public let date: ISO8601Date
    public let position: Position
}
