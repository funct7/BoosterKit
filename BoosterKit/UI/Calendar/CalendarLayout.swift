//
//  CalendarLayout.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/25.
//

import UIKit

open class CalendarLayout : UICollectionViewLayout {
    
    open var weekdayHeight: CGFloat = 40.0
    
    /**
     The base parameters to guide the layout.
     
     These values are the **minimum** guidelines for layout,
     and each property will be given different priority based on which `mode` is assigned.
     */
    open var params: Params!
    
    open var mode: Mode = .top
    
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
    
        public init(
            sectionInset: UIEdgeInsets = .zero,
            itemSize: CGSize,
            spacing: CGSize = .zero)
        {
            self.sectionInset = sectionInset
            self.itemSize = itemSize
            self.spacing = spacing
        }
    }
    
    /**
     `Mode` determines how days are laid out vertically in the calendar by giving different priority to the item size, spacing, padding, and frame.
     
     `top` will be content oriented--i.e. days will be laid out maintaining their size and spacing--whereas
     `fill` and `spread` will be frame oriented. See each case for more details.
     
     In any case, the minimum content height will be maintained, which is the sum of `weekdayHeight` and values of `params`
     applied to the number of weeks that is determined by `CalendarAdapter.displayOption`.
     It is up to the client to adjust the frame of the collection view by observing changes to `sectionHeight` or `collectionViewContentSize` which is available via KVO.
     */
    enum Mode {
        /**
         Gives priority to the item size and spacing.
         
         Days will be laid out along the top of the section below the top padding and space will be left at the bottom if the frame is bigger than the content.
         */
        case top
        /**
         Gives priority to spacing and padding.
         
         Vertical padding and item spacing will be maintained while the item height is expanded to fill the frame.
         */
        case fill
        /**
         Gives priority to item size and padding.
         
         Vertical padding and item height will be maintained while the item spacing is expanded to fill the frame.
         */
        case spread
    }
    
}

extension CalendarLayout {
    
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
