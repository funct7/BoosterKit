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
    
    public var value: TimeInterval {
        switch self {
        case .millisecond(let count): return TimeInterval(count) * ._secInMillis
        case .second(let count): return TimeInterval(count)
        case .minute(let count): return TimeInterval(count) * ._secInMin
        case .hour(let count): return TimeInterval(count) * ._secInHour
        case .day(let count): return TimeInterval(count) * ._secInDay
        }
    }
}

private extension TimeInterval {
    static var _secInMillis = 0.001
    static var _secInMin = 60.0
    static var _secInHour = _secInMin * 60
    static var _secInDay = _secInHour * 24
}
