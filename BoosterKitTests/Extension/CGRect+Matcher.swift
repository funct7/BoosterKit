//
//  CGRect+Matcher.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/10/09.
//

import UIKit
import Nimble
import BoosterKit

extension CGRect {
    
    func isCloseTo(_ other: CGRect, within delta: CGFloat) -> Bool {
        abs(origin.x - other.origin.x) < delta
            && abs(origin.y - other.origin.y) < delta
            && abs(width - other.width) < delta
            && abs(height - other.height) < delta
    }
    
}

func beCloseTo(_ expectedRect: CGRect, within delta: CGFloat) -> Predicate<CGRect> {
    return Predicate.define { expr in
        let errorMessage = "be close to <\(stringify(expectedRect))> (within \(stringify(delta)))"
        let actualValue = try expr.evaluate()
        
        return PredicateResult(
            bool: assign {
                guard let actualValue = actualValue else { return false }
                return actualValue.isCloseTo(expectedRect, within: delta)
            },
            message: .expectedCustomValueTo(errorMessage, actual: "<\(stringify(actualValue))>"))
    }
}

func beCloseTo(
    _ expectedValues: [CGRect],
    within delta: CGFloat) -> Predicate<[CGRect]>
{
    let errorMessage = "be close to <\(stringify(expectedValues))> (each within \(stringify(delta)))"
    return Predicate.simple(errorMessage) { actualExpression in
        guard let actualValues = try actualExpression.evaluate() else {
            return .doesNotMatch
        }

        if actualValues.count != expectedValues.count {
            return .doesNotMatch
        }
        
        if zip(actualValues, expectedValues).contains(where: { !$0.isCloseTo($1, within: delta) }) {
            return .doesNotMatch
        }
        
        return .matches
    }
}
