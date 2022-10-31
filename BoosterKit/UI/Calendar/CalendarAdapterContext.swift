//
//  CalendarAdapterContext.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/31.
//

import Foundation

public struct CalendarAdapterContext : Equatable {
    public enum Position {
        case leading
        case main
        case trailing
    }
    
    public let date: ISO8601Date
    public let position: Position
}
