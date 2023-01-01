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
    
    private lazy var _toastController = ToastController.makeFixedHPadding()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _toastController.canvas = view
    }
    
    private let getCount: () -> Int = assign {
        var i = 0
        return { i += 1; return i }
    }
    
    @IBAction
    private func _changeToastModeAction(_ sender: UISegmentedControl) {
        _toastController = assign {
            switch sender.selectedSegmentIndex {
            case .SegmentIndex.fixedHPadding: return .makeFixedHPadding()
            case .SegmentIndex.fitToText: return .makeFitToText()
            default: fatalError("unknown index: \(sender.selectedSegmentIndex)")
            }
        }
    }
    
    @IBAction
    private func showToastAction() {
        _toastController.show(text: "\(getCount())")
    }
    
}

private extension Int {
    
    enum SegmentIndex {
        static let fixedHPadding = 0
        static let fitToText = 1
    }
    
}

private extension ToastController where View == ImageTextView {
    
    static func makeFixedHPadding() -> ToastController<View> {
        ToastController(
            nib: UINib(nibName: "Toast", bundle: .main),
            params: AnimParams(
                setUp: AnimParams.SetUps.makeDefault(AnimParams.SetUps.makeRounded()),
                animation: AnimParams.Animations.makeAlpha(),
                tearDown: AnimParams.TearDowns.makeDefault()))
    }
    
    static func makeFitToText() -> ToastController<View> {
        fatalError()
    }
    
}

extension ImageTextView : StringRenderer {
    
    func renderString(_ string: String) {
        textLabel.text = string
    }
    
}
