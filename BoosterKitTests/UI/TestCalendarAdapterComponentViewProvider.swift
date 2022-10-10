//
//  TestCalendarAdapterComponentViewProvider.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/24.
//

import UIKit
import BoosterKit

class TestCalendarAdapterComponentViewProvider : CalendarAdapterComponentViewProvider {
    func getCell(collectionView: UICollectionView, for context: CalendarAdapterContext) -> TestCalendarAdapterCell {
        withVar(TestCalendarAdapterCell()) {
            $0.context = context
        }
    }
}
