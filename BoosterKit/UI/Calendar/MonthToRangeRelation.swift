//
//  MonthToRangeRelation.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/29.
//

import Foundation

enum MonthToRangeRelation : Equatable {
    case lessThan
    case minBound
    case withinBounds
    case maxBound
    case greaterThan
    /// A special case where the range spans a single month, and the provided month is that single month.
    case equal
    
    /**
     - Precondition: `range.first <= range.second` if both are provided.
     - Throws: `BoosterKitError.illegalArgument`: The `timeZone` of provided months are not the same.
     */
    static func from(month: ISO8601Month, range: Pair<ISO8601Month?, ISO8601Month?>) throws -> Self {
        assert(range.any({ $0 == nil }) || range.first! <= range.second!)
        
        guard Set([month, range.first, range.second].compactMap(\.?.timeZone)).count < 2
        else { throw BoosterKitError.illegalArgument }
        
        switch range.toTuple() {
        case let (lowerBound?, upperBound?) where lowerBound == upperBound:
            if month < lowerBound { return .lessThan }
            if upperBound < month { return .greaterThan }
            return .equal
            
        case let (lowerBound?, upperBound?):
            if month < lowerBound { return .lessThan }
            if month == lowerBound { return .minBound }
            if month == upperBound { return .maxBound }
            if upperBound < month { return .greaterThan }
            return .withinBounds
            
        case let (lowerBound?, nil):
            if month < lowerBound { return .lessThan }
            if month == lowerBound { return .minBound }
            return .withinBounds
            
        case let (nil, upperBound?):
            if month == upperBound { return .maxBound }
            if upperBound < month { return .greaterThan }
            return .withinBounds
            
        case (nil, nil):
            return .withinBounds
        }
    }
}
