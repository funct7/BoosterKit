//
//  ISO8601Date+Extension.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/20.
//

import Foundation

private extension Set where Element == Calendar.Component {
    
    static var subDayComponents: Self { [.hour, .minute, .second, .nanosecond,] }
    
}

public extension ISO8601Date {
    
    /// - Parameter components: The components to request. `Calendar.Component` items that are smaller than `.day`
    ///     will be ignored--e.g. `.hour`, `.minute`, etc.
    /// - Returns: Requested `components` with `timeZone`.
    func dateComponents(_ components: Set<Calendar.Component>) -> DateComponents {
        withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
            .dateComponents(
                withVar(components) {
                    $0.subtract(.subDayComponents)
                    $0.insert(.timeZone)
                },
                from: instantRange.lowerBound)
    }
    
    var month: ISO8601Month {
        .init(date: self)
    }
    
}
