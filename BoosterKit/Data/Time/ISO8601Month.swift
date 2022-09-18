//
//  ISO8601Month.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import Foundation

public struct ISO8601Month {
    
    public init(year: UInt, month: UInt, timeZone: TimeZone = .autoupdatingCurrent) throws {
        
    }
    
    public init(date: Date = Date(), timeZone: TimeZone = .autoupdatingCurrent) {
        
    }
    
    public init(string: String) throws {
        
    }
    
}

public extension ISO8601Month {
    
    var timeZone: TimeZone { .autoupdatingCurrent }
    
    var instantRange: Range<Date> { Date() ..< Date() }
    
    func contains(instant: Date) -> Bool {
        true
    }
    
    func contains(date: ISO8601Date) -> Bool {
        true
    }
    
}

extension ISO8601Month : CustomStringConvertible {
    
    public var description: String { "" }
    
}

extension ISO8601Month : Equatable { }

extension ISO8601Month : Hashable { }
