//
//  PairExtensionTests.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/09/20.
//

import XCTest
import BoosterKit

class PairExtensionTests : XCTestCase {
    
    func test_patternMatch() {
        let tuple1 = (1, "one"),
            tuple2 = ("two", 2),
            tuple3 = (10.0, 42),
            
            tuple1_1 = (2, "two"),
            tuple2_1 = ("one", 1),
            tuple3_1 = (42.0, 10)
        
        let pair1 = Pair(tuple1),
            pair2 = Pair(tuple2),
            pair3 = Pair(tuple3)
        
        switch pair1 {
        // Swift grammar has no "tuple-literal", so this is impossible.
        // https://stackoverflow.com/q/73787950
//        case (2, "two"): XCTFail("pattern match failed")
        // These are tuple expressions.
        case tuple1_1: XCTFail("pattern match failed")
        case tuple1: return
        default: XCTFail("pattern match failed")
        }
        
        switch pair2 {
        case tuple2_1: XCTFail("pattern match failed")
        case tuple2: break
        default: XCTFail("pattern match failed")
        }
        
        switch pair3 {
        case tuple3_1: XCTFail("pattern match failed")
        case tuple3: break
        default: XCTFail("pattern match failed")
        }
    }
    
}
