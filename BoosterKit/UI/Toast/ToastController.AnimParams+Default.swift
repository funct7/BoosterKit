//
//  ToastController.AnimParams+Default.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public extension ToastController.AnimParams {
    
    static func makeDefault() -> Self {
        self.init(
            setUp: SetUps.makeDefault(),
            animation: Animations.makeAlpha(),
            tearDown: TearDowns.makeDefault())
    }
    
}
