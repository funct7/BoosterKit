//
//  CGPoint+Extension.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/30.
//

import UIKit

public extension CGPoint {
    
    init(_ fillValue: Int) {
        self.init(x: fillValue, y: fillValue)
    }
    
    init(_ fillValue: CGFloat) {
        self.init(x: fillValue, y: fillValue)
    }
    
    init(_ fillValue: Double) {
        self.init(x: fillValue, y: fillValue)
    }
    
}
