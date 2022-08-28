//
//  ToastController.AnimParams.SetUp+Default.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public extension ToastController.AnimParams {
    
    enum SetUps {
        
        static func makeDefault(_ otherSetUp: SetUp? = nil) -> SetUp {
            makeInset(makeAlpha(otherSetUp))
        }
        
        static func makeInset(
            hInset: CGFloat,
            bottomInset: CGFloat,
            _ otherSetUp: SetUp? = nil) -> SetUp
        {
            return { canvas, toastView in
                canvas.addSubview(toastView)
                
                NSLayoutConstraint.activate([
                    toastView.leadingAnchor.constraint(equalTo: canvas.leadingAnchor, constant: hInset),
                    canvas.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: hInset),
                    canvas.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: bottomInset),
                ])
                
                canvas.layoutIfNeeded()
                
                otherSetUp?(canvas, toastView)
            }
        }
        
        static func makeInset(_ otherSetUp: SetUp? = nil) -> SetUp {
            makeInset(hInset: 16.0, bottomInset: 8.0, otherSetUp)
        }
        
        static func makeAlpha(value: CGFloat, _ otherSetUp: SetUp? = nil) -> SetUp {
            return {
                $1.alpha = value
                otherSetUp?($0, $1)
            }
        }
        
        static func makeAlpha(_ otherSetUp: SetUp? = nil) -> SetUp {
            makeAlpha(value: 0.0, otherSetUp)
        }
        
    }
    
}
