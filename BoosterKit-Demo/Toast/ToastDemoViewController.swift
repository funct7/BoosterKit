//
//  ToastDemoViewController.swift
//  BoosterKit-Demo
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit
import BoosterKit

class ToastDemoViewController: UIViewController {
    
    private typealias AnimParams = ToastController<ImageTextView>.AnimParams
    
    private lazy var _toastController = ToastController<ImageTextView>(
        nib: UINib(nibName: "Toast", bundle: .main),
        params: AnimParams(
            setUp: AnimParams.SetUps.makeDefault(AnimParams.SetUps.makeRounded()),
            animation: AnimParams.Animations.makeAlpha(),
            tearDown: AnimParams.TearDowns.makeDefault()))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _toastController.canvas = view
    }
    
    private let getCount: () -> Int = assign {
        var i = 0
        return { i += 1; return i }
    }

    @IBAction
    private func showToastAction() {
        _toastController.show(text: "\(getCount())")
    }
    
}

extension ImageTextView : StringRenderer {
    
    func renderString(_ string: String) {
        textLabel.text = string
    }
    
}
