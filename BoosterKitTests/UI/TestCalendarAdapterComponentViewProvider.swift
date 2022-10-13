//
//  TestCalendarAdapterComponentViewProvider.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/24.
//

import UIKit
import BoosterKit

class TestCalendarAdapterComponentViewProvider : CalendarAdapterComponentViewProvider {
    
    typealias Cell = TestCalendarAdapterCell
    
    func getCellIdentifier() -> String { "\(TestCalendarAdapterCell.self)" }
    
    func configure(_ cell: TestCalendarAdapterCell, with context: CalendarAdapterContext) {
        cell.context = context
    }
    
}
