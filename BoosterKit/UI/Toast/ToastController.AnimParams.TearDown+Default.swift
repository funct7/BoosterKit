//
//  ToastController.AnimParams.TearDown+Default.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public extension ToastController.AnimParams {
    
    enum TearDowns {
        static public func makeDefault(_ otherTearDown: TearDown? = nil) -> TearDown {
            return {
                $1.removeFromSuperview()
                otherTearDown?($0, $1)
            }
        }
    }
    
}
