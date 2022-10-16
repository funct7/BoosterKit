//
//  Pair+Extension.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/20.
//

import Foundation

public extension Pair where First : Equatable, Second : Equatable {
    
    static func ~= (pattern: (First, Second), value: Pair) -> Bool {
        pattern.0 == value.first && pattern.1 == value.second
    }
    
}

public extension Pair where First == Second {
    
    func both(_ predicate: (First) -> Bool) -> Bool {
        predicate(first) && predicate(second)
    }
    
    func any(_ predicate: (First) -> Bool) -> Bool {
        predicate(first) || predicate(second)
    }
    
}
