//
//  CalendarAdapter.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/13.
//

import UIKit

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
            precondition(newValue.collectionViewLayout is CalendarLayout)
        }
        didSet {
            view.dataSource = _adapter
            view.delegate = _adapter
            // layout object needs initial data
            _calendarLayout.invalidateLayoutIfNeeded(context: _layoutContext)
            view.reloadData()
        }
    }
    open var viewProvider: AnyCalendarAdapterComponentViewProvider<Cell>
    open var delegate: AnyCalendarAdapterDelegate<Cell>? = nil
    
    private var _layoutContext: CalendarLayout.Context { .init(displayOption: displayOption, monthRange: monthRange, focusMonth: _focusMonth) }
    open var displayOption: CalendarAdapterDisplayOption = .dynamic {
        didSet {
            _calendarLayout?.invalidateLayoutIfNeeded(context: _layoutContext)
            view?.reloadData()
        }
    }
    
    private var _focusMonth: ISO8601Month
    
    private func _adjustVisibleRectToFocusMonth() {
        guard let view = view else { return }
        
        let pageIndex: Int = assign {
            switch monthRange.toTuple() {
            case (let lowerBound?, nil) where lowerBound == _focusMonth:
                return 0
            case (let lowerBound?, .some):
                return try! lowerBound.distance(to: _focusMonth)
            default:
                return 1
            }
        }
        view.contentOffset.x = view.frame.width * CGFloat(pageIndex)
    }
    
    func loadFocusMonth(_ newValue: ISO8601Month) {
        if _focusMonth == newValue { return }
        
        switch monthRange.toTuple() {
        case (nil, nil): break
        case (let lowerBound?, nil): precondition(lowerBound <= newValue && lowerBound.timeZone == newValue.timeZone)
        case (nil, let upperBound?): precondition(newValue <= upperBound && upperBound.timeZone == newValue.timeZone)
        case (let lowerBound?, let upperBound?): precondition(lowerBound <= newValue && newValue <= upperBound && lowerBound.timeZone == newValue.timeZone)
        }
        
        _focusMonth = newValue

        guard let _ = view else { return }
        
        _calendarLayout.invalidateLayoutIfNeeded(context: _layoutContext)
        if monthRange.isInfinite { view.reloadData() }
    }
    
    /// Updates the displayed month.
    /// - Invariant: `currentMonth` must be within `monthRange` and have the same time zone as the values in `monthRange`.
    open var currentMonth: ISO8601Month {
        get { _focusMonth }
        set {
            loadFocusMonth(newValue)
            _adjustVisibleRectToFocusMonth()
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
            // TODO: Refactor
            switch monthRange.toTuple() {
            case (let lowerBound?, nil) where _focusMonth < lowerBound:
                currentMonth = lowerBound
                
            case (nil, let upperBound?) where upperBound < _focusMonth:
                currentMonth = upperBound
                
            case (let lowerBound?, let upperBound?):
                if _focusMonth < lowerBound { currentMonth = lowerBound }
                else if upperBound < _focusMonth { currentMonth = upperBound }
                else {
                    _calendarLayout?.invalidateLayoutIfNeeded(context: _layoutContext)
                    view?.reloadData()
                    if let _ = view { _adjustVisibleRectToFocusMonth() }
                }
            default:
                _calendarLayout?.invalidateLayoutIfNeeded(context: _layoutContext)
                view?.reloadData()
                if let _ = view { _adjustVisibleRectToFocusMonth() }
            }
        }
    }
    
    /**
     - Throws: `BoosterKitError.illegalArgument`: `date.timeZone != currentMonth.timeZone`
     - Returns: The visible cell for `date`. `nil` if `date` is not a visible date for `currentMonth`.
     */
    open func getCell(date: ISO8601Date) throws -> Cell? {
        guard date.timeZone == currentMonth.timeZone else { throw BoosterKitError.illegalArgument }
        guard
            let _ = view,
            let indexPath = try _adapter.getVisibleIndexPath(date: date),
            let cell = view.cellForItem(at: indexPath)
        else { return nil }
        
        return (cell as! Cell)
    }
    
    /**
     Animates the visible bounds to show `month`.
     
     If `month` is the same as `currentMonth` or is out of range, the method does nothing.
     
     - Throws: `BoosterKitError.illegalArgument`: `month.timeZone != currentMonth.timeZone`
     */
    open func scroll(to month: ISO8601Month) throws {
        guard month.timeZone == currentMonth.timeZone else { throw BoosterKitError.illegalArgument }
        
        let relation = try! MonthToRangeRelation.from(month: month, range: monthRange)
        
        if [.lessThan, .greaterThan].contains(relation) { return }
        if month == currentMonth { return }
        
        if monthRange.isFinite {
            let dataSourceRange = _adapter.getDataSourceRange()
            
            loadFocusMonth(month)
            view.setContentOffset(
                assign {
                    let targetIndex = try! dataSourceRange.lowerBound.distance(to: month)
                    return CGPoint(x: view.frame.width * CGFloat(targetIndex), y: 0)
                },
                animated: true)
        } else {
            let isPast = month < currentMonth
            loadFocusMonth(month)
            
            let (animStartIndex, targetIndex): (Int, Int) = assign {
                if relation == .minBound { return (1, 0) }
                return isPast ? (2, 1) : (0, 1)
            }
            
            view.contentOffset.x = view.frame.width * CGFloat(animStartIndex)
            view.setContentOffset(CGPoint(x: view.frame.width * CGFloat(targetIndex), y: 0), animated: true)
        }
    }
    
    /**
     Re-binds the calendar cells to the data set of the current month.
     
     - Note: Since `CalendarLayout` is designed for a UI where only a single month is displayed,
        there is no use-case where the programmer needs to reload any other month than the current one.
        
        If there should be support for multiple months, please raise an issue at [the GitHub page](https://github.com/funct7/BoosterKit/issues)
     */
    open func reload() {
        view?.reloadData()
    }
    
    /**
     Re-binds the calendar cell to the data for `date`.
     
     If `date` is not a date that is currently displayed, this method does nothing.
     
     - Parameters:
        - date: The date whose cells is to be refreshed.
     
     - Throws: `BoosterKitError.illegalArgument` `date` has time zone that is different than `currentMonth`.
     
     - Note: Since `CalendarLayout` is designed for a UI where only a single month is displayed,
        there is no use-case where the programmer needs to reload any other month than the current one.
        
        If there should be support for dates that are not shown for the current month, please raise an issue at [the GitHub page](https://github.com/funct7/BoosterKit/issues)
     */
    open func reloadDate(_ date: ISO8601Date) throws {
        guard date.timeZone == currentMonth.timeZone else { throw BoosterKitError.illegalArgument }
        guard let indexPath = try _adapter.getVisibleIndexPath(date: date) else { return }
        view?.reloadItems(at: [indexPath])
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
        or provide a new `AnyCalendarAdapterComponentViewProvider` should the `viewProvider` be released at some point in the lifecycle.
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
        
        self._focusMonth = initialMonth
        self.monthRange = monthRange
        self.viewProvider = .init(viewProvider)
    }
    
}
