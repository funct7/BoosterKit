//
//  FixedTimeInterval.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import Foundation

public enum FixedTimeInterval {
    case millisecond(Int)
    case second(Int)
    case minute(Int)
    case hour(Int)
    case day(Int)
    case month(Int)
    case year(Int)
    
    var value: TimeInterval {
        0.0
    }
}
