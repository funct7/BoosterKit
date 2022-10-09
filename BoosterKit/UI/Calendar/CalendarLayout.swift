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
    
    open var weekdayHeight: CGFloat = 40.0
    
    /**
     The base parameters to guide the layout.
     
     These values are the **minimum** guidelines for layout,
     and each property will be given different priority based on which `mode` is assigned.
     */
    open var params: Params!
    
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
    
    @objc
    public dynamic var sectionHeight: CGFloat { 0.0 }
    
    open override dynamic var collectionViewContentSize: CGSize {
        .zero
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        nil
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        nil
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        nil
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        nil
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        false
    }
    
}
