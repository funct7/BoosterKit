//
//  ISO8601Date.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import Foundation

public struct ISO8601Date {
    
    public var timeZone: TimeZone {
        didSet {
            _dateFormatter.timeZone = timeZone
        }
    }
    private let _range: Range<Date>
    private let _dateFormatter: ISO8601DateFormatter
    
    /**
     - Precondition: Each provided date component must be valid; i.e. providing `2022`, `9`, `31` will throw an error because there is no Sep 31st.
     - Throws: `BoosterKitError.illegalArgument`
     */
    public init(year: Int, month: Int, day: Int, timeZone: TimeZone = .autoupdatingCurrent) throws {
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        let dc = DateComponents(year: year, month: month, day: day)
        
        guard let date = cal.date(from: dc) else { throw BoosterKitError.illegalArgument }
        
        guard dc == cal.dateComponents([.year, .month, .day,], from: date) else { throw BoosterKitError.illegalArgument }
        
        self.timeZone = timeZone
        self._range = (date ..< date.adding(.day(1)))
        self._dateFormatter = .with(timeZone: timeZone)
    }
    
    public init(date: Date = Date(), timeZone: TimeZone = .autoupdatingCurrent) {
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        let dc = cal.dateComponents([.year, .month, .day], from: date)
        let midnight = cal.date(from: dc)!
        
        self.timeZone = timeZone
        self._range = (midnight ..< midnight.adding(.day(1)))
        self._dateFormatter = .with(timeZone: timeZone)
    }
    
    /**
     - Parameter string: `yyyyMMdd`, `yyyy-MM-dd` formatted `String`.
     - Throws:`BoosterKitError.illegalArgument` -  `String` with an unsupported format.
     */
    public init(string: String, timeZone: TimeZone = .autoupdatingCurrent) throws {
        let dateFormatter = ISO8601DateFormatter.with(timeZone: timeZone)
        
        guard let date = dateFormatter.date(from: string) else { throw BoosterKitError.illegalArgument }
        
        self.timeZone = timeZone
        self._range = (date ..< date.adding(.day(1)))
        self._dateFormatter = dateFormatter
    }
    
}

public extension ISO8601Date {
    
    var instantRange: Range<Date> { _range }
    
    func contains(instant: Date) -> Bool { instantRange.contains(instant) }
    
}

extension ISO8601Date : Equatable {
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        return lhs._range == rhs._range
            && lhs.timeZone == rhs.timeZone
    }
    
}

extension ISO8601Date : Comparable {
    
    public static func < (lhs: ISO8601Date, rhs: ISO8601Date) -> Bool {
        lhs._range.lowerBound < rhs._range.lowerBound
    }
    
}


extension ISO8601Date {
    
    public func advanced(by n: Int) -> ISO8601Date {
        ISO8601Date(date: instantRange.lowerBound.adding(.day(n)), timeZone: timeZone)
    }
    
    /**
     - Throws:
        - `BoosterKitError.illegalArgument`: The `timeZone` of `other` has a different UTC offset
            from the `timeZone` value of  the instance on which the method is called.
     */
    public func distance(to other: ISO8601Date) throws -> Int {
        guard timeZone.secondsFromGMT() == other.timeZone.secondsFromGMT()
        else { throw BoosterKitError.illegalArgument }
        
        let cal = withVar(Calendar(identifier: .gregorian)) { $0.timeZone = timeZone }
        return cal.dateComponents([.day], from: instantRange.lowerBound, to: other.instantRange.lowerBound).day!
    }
    
}

extension ISO8601Date : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_range.hashValue)
        hasher.combine(timeZone.hashValue)
    }
    
}

extension ISO8601Date : CustomStringConvertible {
    
    public var description: String { _dateFormatter.string(from: _range.lowerBound) }
    
}

private extension ISO8601DateFormatter {
    
    static func with(timeZone: TimeZone) -> ISO8601DateFormatter {
        withVar(ISO8601DateFormatter()) {
            $0.formatOptions = [.withFullDate, .withDashSeparatorInDate,]
            $0.timeZone = timeZone
        }
    }
    
}
