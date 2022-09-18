//
//  ISO8601Month.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import Foundation

public struct ISO8601Month {
    
    public let timeZone: TimeZone
    public let instantRange: Range<Date>
    public let description: String
    
    public init(year: Int, month: Int, timeZone: TimeZone = .autoupdatingCurrent) throws {
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        let dc = DateComponents(year: year, month: month)
        
        guard let lowerBound = cal.date(from: dc) else { throw BoosterKitError.illegalArgument }
        
        let validator = cal.dateComponents([.year, .month], from: lowerBound)
        
        guard validator.year == year, validator.month == month else { throw BoosterKitError.illegalArgument }
        
        guard let upperBound = cal.date(from: withVar(dc) { $0.month! += 1 }) else { throw BoosterKitError.illegalArgument }
        
        self.instantRange = (lowerBound ..< upperBound)
        self.timeZone = timeZone
        self.description = ISO8601DateFormatter.makeMonthInstance(timeZone: timeZone).string(from: lowerBound)
    }
    
    public init(date: Date = Date(), timeZone: TimeZone = .autoupdatingCurrent) {
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        let dc = cal.dateComponents([.year, .month], from: date)
        
        let lowerBound = cal.date(from: dc)!
        let upperBound = cal.date(from: withVar(dc) { $0.month! += 1 })!
        
        self.instantRange = (lowerBound ..< upperBound)
        self.timeZone = timeZone
        self.description = ISO8601DateFormatter.makeMonthInstance(timeZone: timeZone).string(from: lowerBound)
    }
    
    public init(string: String, timeZone: TimeZone = .autoupdatingCurrent) throws {
        let df = ISO8601DateFormatter.makeMonthInstance(timeZone: timeZone)
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        
        guard let lowerBound = df.date(from: string) else { throw BoosterKitError.illegalArgument }
        
        let upperBound = cal.date(from: assign {
            withVar(cal.dateComponents([.year, .month], from: lowerBound)) { $0.month! += 1 }
        })!
        
        self.instantRange = (lowerBound ..< upperBound)
        self.timeZone = timeZone
        self.description = df.string(from: lowerBound)
    }
    
}

public extension ISO8601Month {
    
    func contains(instant: Date) -> Bool { instantRange.contains(instant) }
    
    func contains(date: ISO8601Date) -> Bool {
        instantRange.contains(date.instantRange.lowerBound)
            && instantRange.contains(date.instantRange.upperBound)
    }
    
}

extension ISO8601Month : CustomStringConvertible { }

extension ISO8601Month : Equatable { }

extension ISO8601Month : Hashable { }

private extension ISO8601DateFormatter {
    
    static func makeMonthInstance(timeZone: TimeZone) -> ISO8601DateFormatter {
        withVar(ISO8601DateFormatter()) {
            $0.formatOptions = [.withYear, .withMonth, .withDashSeparatorInDate,]
            $0.timeZone = timeZone
       }
    }
    
}