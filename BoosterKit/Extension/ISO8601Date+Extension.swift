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

public extension ISO8601Date {
    
    /**
     - Throws: `BoosterKitError.illegalArgument` - `day` doesn't exist for the given month.
     */
    init(month: ISO8601Month, day: Int) throws {
        let firstDay = ISO8601Date(date: month.instantRange.lowerBound, timeZone: month.timeZone)
        let targetDay = firstDay.advanced(by: day - 1)
        guard targetDay.month == month else { throw BoosterKitError.illegalArgument }
        self = targetDay
    }
    
}