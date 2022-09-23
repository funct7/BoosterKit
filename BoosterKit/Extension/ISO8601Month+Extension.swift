//
//  ISO8601Month+Extension.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/20.
//

import Foundation

public extension ISO8601Month {
    
    init(date: ISO8601Date) {
        self = .init(date: date.instantRange.lowerBound, timeZone: date.timeZone)
    }
    
}

public extension ISO8601Month {
    
    var dateRange: Range<ISO8601Date> {
        let lowerBound = ISO8601Date(date: instantRange.lowerBound, timeZone: timeZone)
        let upperBound = ISO8601Date(date: instantRange.upperBound, timeZone: timeZone)
        return lowerBound ..< upperBound
    }
    
}
