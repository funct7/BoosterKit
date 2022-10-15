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
        willSet { willChangeValue(for: \.collectionViewContentSize) }
        didSet { didChangeValue(for: \.collectionViewContentSize) }
    }
    open override var collectionViewContentSize: CGSize { _contentSize }

    private var _cachedAttribs = [ISO8601Month : [UICollectionViewLayoutAttributes]]()
    private var _contentRange: Pair<ISO8601Month, ISO8601Month> {
        switch _dataSet.monthRange.toTuple() {
        case (let lowerBound?, let upperBound?):
            return Pair(lowerBound, upperBound)
        case (let lowerBound?, nil) where lowerBound == _dataSet.currentMonth:
            return Pair(lowerBound, lowerBound.advanced(by: 1))
        case (nil, let upperBound?) where upperBound == _dataSet.currentMonth:
            return Pair(upperBound.advanced(by: -1), upperBound)
        default:
            return Pair(_dataSet.currentMonth.advanced(by: -1), _dataSet.currentMonth.advanced(by: 1))
        }
    }
    
    open override func prepare() {
        guard let view = collectionView, let _ = _dataSet else { return }
        
        super.prepare()
        
        let (lowerBound, upperBound) = _contentRange.toTuple()
        let numberOfMonths = try! lowerBound.distance(to: upperBound) + 1
        
        _cachedAttribs = .init(uniqueKeysWithValues: (0 ..< numberOfMonths).map { offset in
            let month = lowerBound.advanced(by: offset)
            
            let attribsList = CGRect
                .make(
                    params: params,
                    weekCount: assign {
                        _dataSet.displayOption == .dynamic
                            ? CalendarAdapter.UICollectionViewAdapter.LayoutPlan.create(month: month).numberOfWeeks
                            : 6
                    },
                    viewSize: view.frame.size)
                .enumerated()
                .map { index, frame in
                    withVar(UICollectionViewLayoutAttributes(forCellWith: IndexPath(indexes: [offset, index]))) {
                        $0.frame = frame.offsetBy(dx: CGFloat(offset) * view.frame.width, dy: 0)
                    }
                }
            
            return (month, attribsList)
        })
        
        _contentSize = CGSize(
            width: CGFloat(numberOfMonths) * view.frame.width,
            height: assign {
                let maxY: CGFloat = assign {
                    switch _dataSet.monthRange.toTuple() {
                    case (.some, .some): return _cachedAttribs.values.map(\.last!.frame.maxY).max()!
                    default: return _cachedAttribs[_dataSet.currentMonth]!.last!.frame.maxY
                    }
                }
                return maxY + params.sectionInset.bottom
            })
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _cachedAttribs.values.reduce([]) { result, attribsList in
            result + attribsList.compactMap { attribs in rect.intersects(attribs.frame) ? attribs : nil }
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _cachedAttribs[_contentRange.first.advanced(by: indexPath.section)]?[indexPath.item]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        false
    }
    
    // MARK: Public
    
    @IBInspectable
    open var topInset: CGFloat {
        get { params.sectionInset.top }
        set { params.sectionInset.top = newValue }
    }
    
    @IBInspectable
    open var rightInset: CGFloat {
        get { params.sectionInset.right }
        set { params.sectionInset.right = newValue }
    }
    
    @IBInspectable
    open var bottomInset: CGFloat {
        get { params.sectionInset.bottom }
        set { params.sectionInset.bottom = newValue }
    }
    
    @IBInspectable
    open var leftInset: CGFloat {
        get { params.sectionInset.left }
        set { params.sectionInset.left = newValue }
    }
    
    @IBInspectable
    open var itemSize: CGSize {
        get { params.itemSize }
        set { params.itemSize = newValue }
    }
    
    @IBInspectable
    open var spacing: CGSize {
        get { params.spacing }
        set { params.spacing = newValue }
    }
    
    /**
     A `String` representation of `params.alignment.horizontal`.
     
     Check `CalendarLayout.Mode.RawValue` for possible values.
     */
    @IBInspectable
    open var horizontalAlignment: String {
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
    open var verticalAlignment: String {
        get { params.alignment.vertical.toRawValue() }
        set {
            guard let aligment = try? Mode.from(rawValue: newValue) else { return }
            params.alignment.vertical = aligment
        }
    }
    
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
    public dynamic var sectionHeight: CGFloat { 0.0 }
    
    /**
     The x-axis `Span` for each weekday.
     
     Use this as a guide when implementing a weekday view for the calendar.
     - Invariant: `weekdaySpans.count == 7`
     */
    @objc
    public dynamic var weekdaySpans: [Span] { [] }
    
    // MARK: Internal
    
    private var _dataSet: DataSet!
    func invalidateLayoutIfNeeded(dataSet: DataSet) {
        let shouldInvalidate = _dataSet != dataSet
        _dataSet = dataSet
        if shouldInvalidate { invalidateLayout() }
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
    
    struct DataSet : Equatable {
        let displayOption: CalendarAdapterDisplayOption
        let monthRange: Pair<ISO8601Month?, ISO8601Month?>
        let currentMonth: ISO8601Month
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
        let minContentSize = minContentSize(weekCount: Int(weekCount), params: params)
        
        return zip(
            horizontalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.width - minContentSize.width),
            verticalValues(params: params, weekCount: Int(weekCount), remainingSpace: viewSize.height - minContentSize.height))
            .map { hor, ver in CGRect(x: hor.start, y: ver.start, width: hor.length, height: ver.length) }
    }
    
    static private func minContentSize(weekCount: Int, params: CalendarLayout.Params) -> CGSize {
        CGSize(
            width: params.sectionInset.horizontal + params.itemSize.width * 7 + params.spacing.width * 6,
            height: params.sectionInset.vertical + params.itemSize.height * CGFloat(weekCount) + params.spacing.height * CGFloat(weekCount - 1))
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
