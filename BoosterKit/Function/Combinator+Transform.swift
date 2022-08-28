//
//  Combinator+Transform.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import Foundation

public func bindFirst<A, B, R>(_ f: @escaping (A) -> R) -> (A, B) -> R {
    { a, _ in f(a) }
}

public func bindFirst<A, B, R>(_ f: @escaping (A) throws -> R) -> (A, B) throws -> R {
    { a, _ in try f(a) }
}

public func bindLast<A, B, R>(_ f: @escaping (B) -> R) -> (A, B) -> R {
    { _, b in f(b) }
}

public func bindLast<A, B, R>(_ f: @escaping (B) throws -> R) -> (A, B) throws -> R {
    { _, b in try f(b) }
}

public func bindNone<A, R>(_ f: @escaping () -> R) -> (A) -> R {
    { _ in f() }
}

public func bindNone<A, R>(_ f: @escaping () throws -> R) -> (A) throws -> R {
    { _ in try f() }
}

public func bindNone<A, B, R>(_ f: @escaping () -> R) -> (A, B) -> R {
    { _, _ in f() }
}

public func bindNone<A, B, R>(_ f: @escaping () throws -> R) -> (A, B) throws -> R {
    { _, _ in try f() }
}
