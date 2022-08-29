//
//  ToastController.AnimParams.Animation+Default.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public extension ToastController.AnimParams {
    
    enum Animations {
        static public func makeAlpha(_ otherAnim: Animation? = nil) -> Animation {
            return {
                $1.alpha = 1.0
                otherAnim?($0, $1)
            }
        }
    }
    
}
