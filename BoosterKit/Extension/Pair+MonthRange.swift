//
//  Pair+MonthRange.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/24.
//

import Foundation

extension Pair where First == ISO8601Month?, Second == ISO8601Month? {
    
    var isInfinite: Bool { any({ $0 == nil }) }
    
}
