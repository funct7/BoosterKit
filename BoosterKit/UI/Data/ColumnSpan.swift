//
//  ColumnSpan.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/10.
//

import UIKit

/**
 A value object representing the span of a column.
 
 - Todo: Replace with a struct version.
 - Invariant: `start <= end`
 */
public final class ColumnSpan : NSObject {
    public let start: CGFloat
    public let end: CGFloat
    
    /**
     - Precondition: `start <= end`
     */
    public init(start: CGFloat, end: CGFloat) {
        assert(start <= end)
        self.start = start
        self.end = end
    }
}

public extension ColumnSpan {
    
    var width: CGFloat { end - start }
    
}
