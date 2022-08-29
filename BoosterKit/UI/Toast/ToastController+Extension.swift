//
//  ToastController+Extension.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/30.
//

import UIKit

public extension ToastController {
    
    /// - Precondition: The first object in the provided NIB must be an instance of `View`.
    convenience init(nib: UINib, params: AnimParams) {
        assert(nib.instantiate(withOwner: nil)[0] is View)
        
        self.init(
            toastViewFactory: { nib.instantiate(withOwner: nil)[0] as! View },
            params: params)
    }
    
}
