//
//  Pair.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/09/18.
//

import Foundation

public struct Pair<First, Second> {
    public var first: First
    public var second: Second

    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }
}

public extension Pair {
    
    init(_ tuple: (First, Second)) {
        self.init(tuple.0, tuple.1)
    }
    
    static func section(_ first: First) -> (Second) -> Pair<First, Second> {
        { second in Pair(first, second) }
    }
    
}

public extension Pair {
    
    func toTuple() -> (First, Second) { (first, second) }
    
}

extension Pair : Equatable where First : Equatable, Second : Equatable { }

extension Pair : Hashable where First : Hashable, Second : Hashable { }

extension Pair : Encodable where First : Encodable, Second : Encodable { }

extension Pair : Decodable where First : Decodable, Second : Decodable { }
