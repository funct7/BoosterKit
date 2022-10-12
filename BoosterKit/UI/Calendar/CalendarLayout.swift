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
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        nil
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        nil
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
    open var params: Params
    
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
    
    struct Params {
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
    
    struct Alignment {
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
