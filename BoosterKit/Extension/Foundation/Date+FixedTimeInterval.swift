//
//  Date+FixedTimeInterval.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/17.
//

import Foundation

extension Date {
    
    func adding(_ fixedTimeInterval: FixedTimeInterval) -> Date { addingTimeInterval(fixedTimeInterval.value) }
    
}
