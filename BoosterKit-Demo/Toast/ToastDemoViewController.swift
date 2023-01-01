//
//  ToastDemoViewController.swift
//  BoosterKit-Demo
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit
import BoosterKit

class ToastDemoViewController: UIViewController {
    
    @IBOutlet weak var modeSelector: UISegmentedControl!
    
    private typealias AnimParams = ToastController<ImageTextView>.AnimParams
    
    private var _toastCounter: Int = 0 {
        didSet {
            // _toastController must be alive until tear down anim is completed
            modeSelector.isEnabled = _toastCounter == 0
        }
    }
    private lazy var _toastController = ToastController.makeFixedHPadding() {
        didSet {
            _setUpToastController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setUpToastController()
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
        _toastController.show(text: "Message: \(getCount())")
    }
    
    private func _setUpToastController() {
        _toastController.canvas = view
        
        _toastController.addSetUpContext { [unowned self] in
            self._toastCounter += 1
        }
        _toastController.addTearDownContext { [unowned self] in
            self._toastCounter -= 1
        }
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
        ToastController(
            nib: UINib(nibName: "Toast", bundle: .main),
            params: AnimParams(
                setUp: AnimParams.SetUps.makeSafeAreaInset(
                    hInset: nil,
                    bottomInset: 0.0,
                    AnimParams.SetUps.makeAlpha(AnimParams.SetUps.makeRounded())),
                animation: AnimParams.Animations.makeAlpha(),
                tearDown: AnimParams.TearDowns.makeDefault()))
    }
    
    func addSetUpContext(_ context: @escaping () -> Void) {
        params.setUp = { [setUp = params.setUp] in
            context()
            setUp($0, $1)
        }
    }
    
    func addTearDownContext(_ context: @escaping () -> Void) {
        params.tearDown = { [tearDown = params.tearDown] in
            context()
            tearDown($0, $1)
        }
    }
    
}

extension ImageTextView : StringRenderer {
    
    func renderString(_ string: String) {
        textLabel.text = string
    }
    
}
