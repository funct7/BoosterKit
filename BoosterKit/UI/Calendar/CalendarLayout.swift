//
//  CalendarLayout.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/25.
//

import UIKit

/**
 - Note: Supports horizontal scrolling only.
 - Todo: Support vertical scrolling.
 */
open class CalendarLayout : UICollectionViewLayout {
    
    // MARK: Inherited
    
    private var _contentSize: CGSize = .zero {
        willSet {
            if _contentSize != newValue {
                willChangeValue(for: \.collectionViewContentSize)
            }
        }
        didSet {
            if _contentSize != oldValue {
                didChangeValue(for: \.collectionViewContentSize)
            }
        }
    }
    open override var collectionViewContentSize: CGSize { _contentSize }

    private var _cachedAttribs = [ISO8601Month : [UICollectionViewLayoutAttributes]]() {
        didSet { _updateWeekdaySpansIfNeeded() }
    }
    
    open override func prepare() {
        guard let view = collectionView, let _ = _context else { return }
        
        super.prepare()
        
        let (lowerBound, upperBound) = _context.contentRange.toTuple()
        let numberOfMonths = try! lowerBound.distance(to: upperBound) + 1
        
        _cachedAttribs = .init(uniqueKeysWithValues: (0 ..< numberOfMonths).map { offset in
            let month = lowerBound.advanced(by: offset)
            
            let attribsList = CGRect
                .make(
                    params: params,
                    weekCount: _context.displayOption.numberOfWeeks(month: month),
                    viewSize: view.frame.size)
                .enumerated()
                .map { index, frame in
                    withVar(UICollectionViewLayoutAttributes(forCellWith: IndexPath(indexes: [offset, index]))) {
                        $0.frame = frame.offsetBy(dx: CGFloat(offset) * view.frame.width, dy: 0)
                    }
                }
            
            return (month, attribsList)
        })
        
        _currentSectionHeight = _getSectionHeight(month: _context.focusMonth)
        
        _contentSize = CGSize(
            width: CGFloat(numberOfMonths) * view.frame.width,
            height: assign {
                switch _context.monthRange.toTuple() {
                case (.some, .some): return _cachedAttribs.values.map(\.last!.frame.maxY).max()! + params.sectionInset.bottom
                default: return sectionHeight
                }
            })
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _cachedAttribs.values.reduce([]) { result, attribsList in
            result + attribsList.compactMap { attribs in rect.intersects(attribs.frame) ? attribs : nil }
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _cachedAttribs[_context.contentRange.first.advanced(by: indexPath.section)]?[indexPath.item]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let currentBounds = collectionView?.bounds else { return true }
        
        if params.alignment.vertical == .packed
            && currentBounds.width == newBounds.width
            && currentBounds.height != newBounds.height
        { return false }
        
        return true
    }
    
    // MARK: Public
    
    /**
     The base parameters to guide the layout.
     
     These values are the **minimum** guidelines for layout,
     and each property will be given different priority based on which `alignment` is assigned.
     */
    open var params: Params {
        didSet {
            if params != oldValue { invalidateLayout() }
        }
    }
    
    @objc
    open dynamic var sectionHeight: CGFloat { _currentSectionHeight }
    
    /**
     Calculates the section height given the current layout parameters.
     */
    open func sectionHeight(month: ISO8601Month) -> CGFloat {
        let minHeight = CGSize.minContentSize(
            layoutParams: params,
            weekCount: _context.displayOption.numberOfWeeks(month: month)).height
        
        switch params.alignment.vertical {
        case .packed: return minHeight
        case .filled, .spread: return max(minHeight, collectionView?.frame.height ?? 0)
        }
    }
    
    /**
     The x-axis `Span` for each weekday.
     
     Use this as a guide when implementing a weekday view for the calendar.
     - Invariant: After items have been laid out at least once, `weekdaySpans.count == 7`.
     */
    @objc
    open private(set) dynamic var weekdaySpans: [Span] = []
    
    // MARK: Internal
    
    private var _context: Context!
    func invalidateLayoutIfNeeded(context: Context) {
        // rollback to non-optimized version if bugs appear
        enum FollowUp { case invalidateLayout, updateCurrentSectionHeight, ignore }
        
        let followUp: FollowUp = assign {
            guard let _context = _context else { return .invalidateLayout }
            if _context.displayOption != context.displayOption { return .invalidateLayout }
            if _context.monthRange != context.monthRange { return .invalidateLayout }
            
            switch context.monthRange.toTuple() {
            case (.some, .some): return _context.focusMonth != context.focusMonth
                ? .updateCurrentSectionHeight
                : .ignore
            default: return _context.focusMonth != context.focusMonth
                ? .invalidateLayout
                : .ignore
            }
        }
        _context = context
        
        switch followUp {
        case .invalidateLayout: invalidateLayout()
        case .updateCurrentSectionHeight: _currentSectionHeight = _getSectionHeight(month: _context.focusMonth)
        case .ignore: return
        }
    }
    
    // MARK: Private
    
    private func _updateWeekdaySpansIfNeeded() {
        guard let _ = _context,
              let attribsList = _cachedAttribs[_context.contentRange.first]
        else { return }
        
        let newValue = attribsList[0...6].map { Span(start: $0.frame.minX, end: $0.frame.maxX) }
        
        if newValue != weekdaySpans { weekdaySpans = newValue }
    }
    
    private var _currentSectionHeight: CGFloat = 0.0 {
        willSet {
            if _currentSectionHeight != newValue {
                willChangeValue(for: \.sectionHeight)
            }
        }
        didSet {
            if _currentSectionHeight != oldValue {
                didChangeValue(for: \.sectionHeight)
            }
        }
    }
    
    /**
     - Precondition: `_cachedAttribs.keys.contains(month)`.
     - Note: This method has no side-effects.
        It is up to the caller to make sure `_cachedAttribs` correctly reflects the current layout state.
     - Returns: The section height for `month` (including section insets).
     */
    private func _getSectionHeight(month: ISO8601Month) -> CGFloat {
        assert(_cachedAttribs.keys.contains(month))
        return _cachedAttribs[_context.focusMonth]!.last!.frame.maxY + params.sectionInset.bottom
    }
    
    // MARK: Initializer
    
    public init(params: Params) {
        self.params = params
        super.init()
    }
    
    convenience override init() {
        self.init(params: Params(itemSize: .zero))
    }
    
    required public init?(coder: NSCoder) {
        self.params = Params(itemSize: .zero)
        super.init(coder: coder)
    }
    
}

// MARK: Name-spaced types

public extension CalendarLayout {
    
    struct Params : Equatable {
        /**
         The padding applied to each month section.
         
         The values will be applied only to the calendar area--i.e. the area showing weekdays will **NOT** be affected,
         but only the area below--and each section will have its own padding.
         */
        public var sectionInset: UIEdgeInsets
        public var itemSize: CGSize
        public var spacing: CGSize
        public var alignment: Alignment
    
        public init(
            sectionInset: UIEdgeInsets = .zero,
            itemSize: CGSize,
            spacing: CGSize = .zero,
            alignment: Alignment = Alignment(horizontal: .packed, vertical: .packed))
        {
            self.sectionInset = sectionInset
            self.itemSize = itemSize
            self.spacing = spacing
            self.alignment = alignment
        }
    }
    
    /**
     `Mode` determines how days are laid out vertically in the calendar by giving different priority to the item size, spacing, padding, and frame.
     
     `packed` will be content oriented--i.e. days will be laid out maintaining their size and spacing--whereas
     `fill` and `spread` will be frame oriented. See each case for more details.
     
     In any case, the minimum content height will be maintained, which is the sum of `weekdayHeight` and values of `params`
     applied to the number of weeks that is determined by `CalendarAdapter.displayOption`.
     It is up to the client to adjust the frame of the collection view by observing changes to `sectionHeight` or `collectionViewContentSize` which is available via KVO.
     
     For the content width, the minium content width will be maintained, just like the content height,
     but each month section is guaranteed to start with an x-axis offset that is a multiple of the collection view frame width;
     i.e. if the `itemSize.width` is too big to fit in the collection view width, days will be drawn past the section inset on the right and possibly overlap with the next month,
     but the left portion of each month is guaranteed to start at the correct position.
     */
    enum Mode {
        /**
         Gives priority to the item size and spacing.
         
         For horizontal alignment days will be center alignment, and there may be more horizontal section insets than specified if the frame width is bigger than the laid out content.
         For vertical alignment days will be laid out along the top of the section below the top padding and space will be left at the bottom if the frame is bigger than the content.
         */
        case packed
        /**
         Gives priority to spacing and padding.
         
         Section insets and item spacing will be maintained while the item size is expanded to fill the frame.
         */
        case filled
        /**
         Gives priority to item size and padding.
         
         Section insets and item size will be maintained while the item spacing is expanded to fill the frame.
         */
        case spread
    }
    
    struct Alignment : Equatable {
        public var horizontal: Mode
        public var vertical: Mode
        
        public init(horizontal: Mode, vertical: Mode) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
    
}

extension CalendarLayout {
    
    struct Context : Equatable {
        let displayOption: CalendarAdapterDisplayOption
        let monthRange: Pair<ISO8601Month?, ISO8601Month?>
        let focusMonth: ISO8601Month
    }
    
}

extension CalendarLayout.Context {
    
    var contentRange: Pair<ISO8601Month, ISO8601Month> {
        switch monthRange.toTuple() {
        case (let lowerBound?, let upperBound?):
            return Pair(lowerBound, upperBound)
        case (let lowerBound?, nil) where lowerBound == focusMonth:
            return Pair(lowerBound, lowerBound.advanced(by: 1))
        case (nil, let upperBound?) where upperBound == focusMonth:
            return Pair(upperBound.advanced(by: -1), upperBound)
        default:
            return Pair(focusMonth.advanced(by: -1), focusMonth.advanced(by: 1))
        }
    }
    
}

// MARK: Interface Builder support

public extension CalendarLayout {
    
    @IBInspectable
    var topInset: CGFloat {
        get { params.sectionInset.top }
        set { params.sectionInset.top = newValue }
    }
    
    @IBInspectable
    var rightInset: CGFloat {
        get { params.sectionInset.right }
        set { params.sectionInset.right = newValue }
    }
    
    @IBInspectable
    var bottomInset: CGFloat {
        get { params.sectionInset.bottom }
        set { params.sectionInset.bottom = newValue }
    }
    
    @IBInspectable
    var leftInset: CGFloat {
        get { params.sectionInset.left }
        set { params.sectionInset.left = newValue }
    }
    
    @IBInspectable
    var itemSize: CGSize {
        get { params.itemSize }
        set { params.itemSize = newValue }
    }
    
    @IBInspectable
    var spacing: CGSize {
        get { params.spacing }
        set { params.spacing = newValue }
    }
    
    /**
     A `String` representation of `params.alignment.horizontal`.
     
     Check `CalendarLayout.Mode.RawValue` for possible values.
     */
    @IBInspectable
    var horizontalAlignment: String {
        get { params.alignment.horizontal.toRawValue() }
        set {
            guard let alignment = try? Mode.from(rawValue: newValue) else { return }
            params.alignment.horizontal = alignment
        }
    }
    
    /**
     A `String` representation of `params.alignment.vertical`.
     
     Check `CalendarLayout.Mode.RawValue` for possible values.
     */
    @IBInspectable
    var verticalAlignment: String {
        get { params.alignment.vertical.toRawValue() }
        set {
            guard let aligment = try? Mode.from(rawValue: newValue) else { return }
            params.alignment.vertical = aligment
        }
    }
    
}

public extension CalendarLayout.Mode {
    
    enum RawValue {
        static let packed = "packed"
        static let filled = "filled"
        static let spread = "spread"
    }
    
    func toRawValue() -> String {
        switch self {
        case .packed: return RawValue.packed
        case .filled: return RawValue.filled
        case .spread: return RawValue.spread
        }
    }
    
    static func from(rawValue: String) throws -> Self {
        switch rawValue {
        case RawValue.packed: return .packed
        case RawValue.filled: return .filled
        case RawValue.spread: return .spread
        default: throw BoosterKitError.illegalArgument
        }
    }
}
    
private extension CGRect {
    
    static func make(params: CalendarLayout.Params, weekCount: UInt, viewSize: CGSize) -> [CGRect] {
        let minContentSize = CGSize.minContentSize(layoutParams: params, weekCount: weekCount)
        
        return zip(
            horizontalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.width - minContentSize.width),
            verticalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.height - minContentSize.height))
            .map { hor, ver in CGRect(x: hor.start, y: ver.start, width: hor.length, height: ver.length) }
    }
    
    static private func originX(weekdayIndex: Int, leftInset: CGFloat, itemWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        leftInset + itemWidth * CGFloat(weekdayIndex) + spacing * CGFloat(weekdayIndex)
    }
    
    static private func originY(weekIndex: Int, topInset: CGFloat, itemHeight: CGFloat, spacing: CGFloat) -> CGFloat {
        topInset + itemHeight * CGFloat(weekIndex) + spacing * CGFloat(weekIndex)
    }
    
    /// - Returns: A list of `($ORIGIN_X, $WIDTH)` tuples.
    static private func horizontalValues(params: CalendarLayout.Params, weekCount: Int, remainingSpace: CGFloat) -> [Span] {
        let defaultLayout = (0 ..< weekCount).flatMap(bindNone {
            (0 ..< 7).map { Span(start: originX(weekdayIndex: $0, leftInset: params.sectionInset.left, itemWidth: params.itemSize.width, spacing: params.spacing.width), length: params.itemSize.width) }
        })
        
        if remainingSpace <= 0.0 {
            return defaultLayout
        } else {
            switch params.alignment.horizontal {
            case .packed:
                let extraLeftInset = remainingSpace * 0.5
                return defaultLayout.map { span in span.offset(by: extraLeftInset) }
            case .filled:
                let extraWidth = remainingSpace / 7
                return defaultLayout.enumerated()
                    .map { i, span in Span(start: span.start + extraWidth * CGFloat(i % 7), length: span.length + extraWidth) }
            case .spread:
                let extraSpace = remainingSpace / 6
                return defaultLayout.enumerated()
                    .map { i, span in span.offset(by: extraSpace * CGFloat(i % 7)) }
            }
        }
    }
    
    /// - Returns: A list of `($ORIGIN_Y, $HEIGHT)` tuples.
    static private func verticalValues(params: CalendarLayout.Params, weekCount: Int, remainingSpace: CGFloat) -> [Span] {
        let defaultLayout = (0 ..< weekCount).flatMap { weekIndex in
            (0 ..< 7).map(bindNone { Span(start: originY(weekIndex: Int(weekIndex), topInset: params.sectionInset.top, itemHeight: params.itemSize.height, spacing: params.spacing.height), length: params.itemSize.height) })
        }
        
        if remainingSpace <= 0.0 {
            return defaultLayout
        } else {
            switch params.alignment.vertical {
            case .packed: return defaultLayout
            case .filled:
                let extraHeight = remainingSpace / CGFloat(weekCount)
                return defaultLayout.enumerated()
                    .map { i, span in Span(start: span.start + extraHeight * CGFloat(i/7), length: span.length + extraHeight) }
            case .spread:
                let extraSpace = remainingSpace / CGFloat(weekCount - 1)
                return defaultLayout.enumerated()
                    .map { i, span in span.offset(by: extraSpace * CGFloat(i/7)) }
            }
        }
    }
    
}

private extension CGSize {

    static func minContentSize(layoutParams: CalendarLayout.Params, weekCount: UInt) -> CGSize {
        CGSize(
            width: layoutParams.sectionInset.horizontal + layoutParams.itemSize.width * 7 + layoutParams.spacing.width * 6,
            height: layoutParams.sectionInset.vertical + layoutParams.itemSize.height * CGFloat(weekCount) + layoutParams.spacing.height * CGFloat(weekCount - 1))
    }
    
}

private extension CalendarAdapterDisplayOption {
    
    func numberOfWeeks(month: ISO8601Month) -> UInt {
        switch self {
        case .fixed: return 6
        case .dynamic: return CalendarAdapter.UICollectionViewAdapter.LayoutPlan.create(month: month).numberOfWeeks
        }
    }
    
}