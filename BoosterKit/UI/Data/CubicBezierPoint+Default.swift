//
//  CubicBezierPoint+Default.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public extension CubicBezierPoint {

    /**
     Cubic Bézier timing points, courtesy of [easings.net](https://easings.net/#)
     */
    enum Defaults {   
        static public let linear = CubicBezierPoint(point1: .zero, point2: CGPoint(1.0))
    }
    
}

public extension CubicBezierPoint.Defaults {
    
    static let easeInCubic = CubicBezierPoint(point1: CGPoint(x: 0.32, y: 0), point2: CGPoint(x: 0.67, y: 0))
    
    static let easeOutCubic = CubicBezierPoint(point1: CGPoint(x: 0.33, y: 1), point2: CGPoint(x: 0.68, y: 1))
    
    static let easeInOutCubic = CubicBezierPoint(point1: CGPoint(x: 0.65, y: 0), point2: CGPoint(x: 0.35, y: 1))
    
}
