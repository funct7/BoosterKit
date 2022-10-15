//
//  Span.swift
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
public final class Span : NSObject {
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

public extension Span {
    
    convenience init(start: CGFloat, length: CGFloat) {
        self.init(start: start, end: start + length)
    }
    
    func withStart(_ value: CGFloat) -> Span { Span(start: value, end: end) }
    
    func withLength(_ value: CGFloat) -> Span { Span(start: start, length: value) }
    
    func withEnd(_ value: CGFloat) -> Span { Span(start: start, end: value) }
    
    func offset(by value: CGFloat) -> Span { Span(start: start + value, end: end + value) }
    
    var length: CGFloat { end - start }
    
}

extension Span {
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Span else { return false }
        return start == object.start
            && end == object.end
    }
    
}
