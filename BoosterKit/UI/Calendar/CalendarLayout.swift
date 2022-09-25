//
//  CalendarLayout.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/25.
//

import UIKit

open class CalendarLayout : UICollectionViewLayout {
    
    /**
     The base parameters to guide the layout.
     
     These values are the **minimum** guidelines for layout,
     and each property will be given different priority based on which `mode` is assigned.
     */
    open var params: Params!
    
    open var mode: Mode = .centered
    
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
     `Mode` determines how days are laid out in the calendar by giving different priority to the item size, spacing, padding, and frame.
     */
    enum Mode {
        /**
         Gives priority to item size and spacing.
         
         Adjusts the calendar frame to fit days and spacing.
         The monthly padding will be stretched to fill any remaininng space if the calendar frame is fixed to a size bigger than the layout content size.
         */
        case centered
        /**
         Gives priority to spacing and padding.
         
         Fits days and spacing to the frame size.
         Days will be stretched to fill any remaininng space after layout.
         */
        case fill
        /**
         Gives priority to item size and padding.
         
         Fits days and spacing to the frame size.
         The spacing between days and weeks will be stretched to fill any remaininng space after layout.
         */
        case spread
    }
    
}

extension CalendarLayout {
    
    public var sectionHeight: CGFloat { 0.0 }
    
    open override var collectionViewContentSize: CGSize {
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
