//
//  CalendarAdapterComponentViewProvider.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/31.
//

import UIKit

public protocol CalendarAdapterComponentViewProvider : AnyObject {
    associatedtype Cell : UICollectionViewCell
    /**
     - Returns: The identifier that is used to dequeue the `Cell`.
        
        The `UICollectionViewCell` that is dequeued from the collection view using the value **MUST** be a type of `Cell`.
     */
    func getCellIdentifier() -> String
    func configure(_ cell: Cell, with context: CalendarDateContext)
}

/**
 A type-erased `CalendarAdapterComponentViewProvider`.
 */
open class AnyCalendarAdapterComponentViewProvider<Cell> : CalendarAdapterComponentViewProvider where Cell : UICollectionViewCell {
    
    private let _getCellIdentifier: () -> String
    public func getCellIdentifier() -> String { _getCellIdentifier() }

    private let _configureCellWithContext: (Cell, CalendarDateContext) -> Void
    public func configure(_ cell: Cell, with context: CalendarDateContext) { _configureCellWithContext(cell, context) }
    
    /**
     - Attention: The constructed instance will hold an **unowned reference** to the `viewProvider`.
        It is up to the caller to make sure that `viewProvider` lives throughout the lifecycle of the created `AnyCalendarAdapterComponentViewProvider` instance.
     */
    public init<P>(_ viewProvider: P) where P : CalendarAdapterComponentViewProvider, P.Cell == Cell {
        self._getCellIdentifier = { [unowned viewProvider] in viewProvider.getCellIdentifier() }
        self._configureCellWithContext = { [unowned viewProvider] in viewProvider.configure($0, with: $1) }
    }
}
