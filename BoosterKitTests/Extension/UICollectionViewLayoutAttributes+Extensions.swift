//
//  UICollectionViewLayoutAttributes+Extensions.swift
//  BoosterKitTests
//
//  Created by Josh Woomin Park on 2022/10/09.
//

import UIKit

extension Array where Element : UICollectionViewLayoutAttributes {
    
    func attributes(at indices: [Int]) -> Element? {
        first(where: { [Int]($0.indexPath) == indices })
    }
    
}
