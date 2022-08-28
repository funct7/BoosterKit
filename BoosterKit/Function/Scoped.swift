//
//  Scoped.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/28.
//

import Foundation

public func assign<T>(_ block: () -> T) -> T { block() }

public func assign<T>(_ block: () throws -> T) throws -> T { try block() }

public func assign<T>(_ reader: ((T) -> Void) -> Void) -> T {
    var result: T!
    reader({ result = $0 })
    return result
}

public func withVar<T>(_ value: T, then: (inout T) -> Void) -> T {
    var value = value
    then(&value)
    return value
}

public func withVar<T, A>(_ value: T, _ keyPath: KeyPath<T, A>, then: (inout T, A) -> Void) -> T {
    var value = value
    then(&value, value[keyPath: keyPath])
    return value
}

public func withVar<T, A, B>(_ value: T, _ keyPath1: KeyPath<T, A>, _ keyPath2: KeyPath<T, B>, then: (inout T, A, B) -> Void) -> T {
    var value = value
    then(&value, value[keyPath: keyPath1], value[keyPath: keyPath2])
    return value
}
