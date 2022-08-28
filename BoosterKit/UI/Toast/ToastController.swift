//
//  ToastController.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/08/29.
//

import UIKit

public class ToastController<View> where View : UIView, View : StringRenderer {
    
    public weak var canvas: UIView?
    public var toastViewFactory: () -> View
    public var params: AnimParams
    
    private var _instances: Set<_ToastFSM> = []
    
    public func show(text: String) {
        _instances.insert(withVar(_ToastFSM(controller: self, text: text)) {
            $0.transition()
        })
    }
    
//    TODO: Implement if a quick unanimated hide is needed
//    func hide() {
//
//    }
    
    public init(toastViewFactory: @escaping () -> View, params: AnimParams) {
        self.toastViewFactory = toastViewFactory
        self.params = params
    }
    
}

public extension ToastController {
    
    struct AnimParams {
        public typealias Animation = (_ canvas: UIView, _ toastView: View) -> Void
        public typealias SetUp = Animation
        public typealias TearDown = Animation
        
        public var animDuration: TimeInterval
        public var displayDuration: TimeInterval
        public var cubicBezierPoints: CubicBezierPoint
        public var setUp: SetUp
        public var animation: Animation
        public var tearDown: TearDown

        public init(
            animDuration: TimeInterval = 0.35,
            displayDuration: TimeInterval = 1.0,
            cubicBezierPoints: CubicBezierPoint = .easeOut,
            setUp: @escaping SetUp,
            animation: @escaping Animation,
            tearDown: @escaping TearDown)
        {
            self.animDuration = animDuration
            self.displayDuration = displayDuration
            self.cubicBezierPoints = cubicBezierPoints
            
            self.setUp = setUp
            self.animation = animation
            self.tearDown = tearDown
        }
    }
    
}

private extension ToastController {
        
    final class _ToastFSM {
    
        enum State {
            case idle
            case show
            case hold
            case hide
        }
        
        private var _state: State {
            didSet {
                switch (oldValue, _state) {
                case (.idle, .show):
                    _animator.pausesOnCompletion = true
                    _animator.startAnimation()
                case (.show, .hold):
                    RunLoop.current.add(_timer, forMode: .default)
                case (.hold, .hide):
                    _animator.isReversed = true
                    _animator.startAnimation()
                default: return
                }
            }
        }
        private var _animator: UIViewPropertyAnimator!
        private var _token: NSKeyValueObservation!
        private var _timer: Timer!
        private let _completion: (_ToastFSM) -> Void
        
        func transition() {
            switch _state {
            case .idle: _state = .show
            case .show: _state = .hold
            case .hold: _state = .hide
            case .hide: _completion(self)
            }
        }
        
        private func _initialize(animParams: ToastController.AnimParams, canvas: UIView, toastView: View) {
            self._animator = UIViewPropertyAnimator(
                duration: animParams.animDuration,
                controlPoint1: animParams.cubicBezierPoints.point1,
                controlPoint2: animParams.cubicBezierPoints.point2,
                animations: { [animParams, canvas, toastView] in
                    animParams.animation(canvas, toastView)
                })
            self._token = _animator.observe(\.isRunning, options: [.new, .old]) { _, changes in
                switch (changes.oldValue, changes.newValue) {
                case (true, false): self.transition()
                default: return
                }
            }
            self._timer = Timer(
                fire: Date().addingTimeInterval(animParams.animDuration + animParams.displayDuration),
                interval: 0,
                repeats: false,
                block: bindNone { [unowned self] in
                    self.transition()
                })
        }
        
        init(animParams: ToastController.AnimParams,
             canvas: UIView,
             toastView: View,
             completion: @escaping (_ToastFSM) -> Void)
        {
            self._state = .idle
            self._completion = { [tearDown = animParams.tearDown, weak canvas, weak toastView] in
                if let canvas = canvas, let toastView = toastView {
                    tearDown(canvas, toastView)
                }
                completion($0)
            }
            self._initialize(animParams: animParams, canvas: canvas, toastView: toastView)
            
            animParams.setUp(canvas, toastView)
        }
    }
    
}

extension ToastController._ToastFSM : Hashable {
    
    static func == (lhs: ToastController<View>._ToastFSM, rhs: ToastController<View>._ToastFSM) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
}

private extension ToastController._ToastFSM {
    
    convenience init(controller: ToastController, text: String) {
        precondition(controller.canvas != nil)
        
        self.init(
            animParams: controller.params,
            canvas: controller.canvas!,
            toastView: withVar(controller.toastViewFactory()) { $0.renderString(text) },
            completion: { [unowned controller] in
                controller._instances.remove($0)
            })
    }
    
}
