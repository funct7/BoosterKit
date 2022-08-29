//
//  BoosterKitError.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/30.
//

import Foundation

public enum BoosterKitError : Error {
    case illegalArgument
    case invalidState
    case cause(Error)
    case unknown(String?)
}
