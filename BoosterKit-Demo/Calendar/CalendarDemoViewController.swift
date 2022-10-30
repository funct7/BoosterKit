//
//  CalendarDemoViewController.swift
//  BoosterKit-Demo
//
//  Created by Josh Woomin Park on 2022/10/13.
//

import UIKit
import BoosterKit

class CalendarDemoViewController : UIViewController {
    
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var currentMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet var weekdayLabels: [UILabel]!
    @IBOutlet weak var calendarView: UICollectionView! {
        didSet { _calendarAdapter.view = calendarView }
    }
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    
    private var _sectionHeightObserveToken: NSKeyValueObservation!
    private var _weekdaySpansObserveToken: NSKeyValueObservation!
    @IBOutlet weak var calendarLayout: CalendarLayout!
    private lazy var _viewProvider = DemoCalendarAdapterComponentViewProvider()
    private lazy var _calendarAdapter = CalendarAdapter(viewProvider: _viewProvider)
    
    private var _monthRange: Pair<ISO8601Month?, ISO8601Month?> = Pair(nil, nil) {
        didSet {
            bindMonthRange()
            _calendarAdapter.monthRange = _monthRange
            _calendarAdapter.reload()
        }
    }
    @IBOutlet weak var lowerBoundSwitch: UISwitch!
    @IBOutlet weak var lowerBoundSlider: UISlider!
    @IBOutlet weak var lowerBoundLabel: UILabel!
    
    @IBOutlet weak var upperBoundSwitch: UISwitch!
    @IBOutlet weak var upperBoundSlider: UISlider!
    @IBOutlet weak var upperBoundLabel: UILabel!
    
    @IBOutlet weak var topInsetLabel: UILabel!
    @IBOutlet weak var topInsetStepper: UIStepper!
    @IBOutlet weak var rightInsetLabel: UILabel!
    @IBOutlet weak var rightInsetStepper: UIStepper!
    @IBOutlet weak var bottomInsetLabel: UILabel!
    @IBOutlet weak var bottomInsetStepper: UIStepper!
    @IBOutlet weak var leftInsetLabel: UILabel!
    @IBOutlet weak var leftInsetStepper: UIStepper!
    
    @IBOutlet weak var hSpacingLabel: UILabel!
    @IBOutlet weak var hSpacingStepper: UIStepper!
    
    @IBOutlet weak var vSpacingLabel: UILabel!
    @IBOutlet weak var vSpacingStepper: UIStepper!
    
    private var _needsInitialLayout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _calendarAdapter.delegate = AnyCalendarAdapterDelegate(self)
        _sectionHeightObserveToken = calendarLayout.observe(
            \.sectionHeight,
            options: [.new])
        { [weak calendarViewHeight] _, change in
            calendarViewHeight?.constant = change.newValue!
        }
        _weekdaySpansObserveToken = calendarLayout.observe(
            \.weekdaySpans,
            options: [.new])
        { [unowned self] _, change in
            zip(self.weekdayLabels, change.newValue!).forEach { label, span in
                label.frame.origin.x = span.start
                label.frame.size.width = span.length
            }
        }
        
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _needsInitialLayout = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if _needsInitialLayout {
            // This MUST be called at least once before the VC appears on screen.
            _calendarAdapter.currentMonth = _calendarAdapter.currentMonth
        }
    }
    
}

extension CalendarDemoViewController {
    
    func updateCurrentMonthButton(month: ISO8601Month) {
        currentMonthButton.setTitle("\(month)", for: .normal)
    }
    
    @IBAction func prevMonthAction(_ sender: UIButton) {
        try! _calendarAdapter.scroll(to: _calendarAdapter.currentMonth.advanced(by: -1))
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func currentMonthAction(_ sender: UIButton) {
        try! _calendarAdapter.scroll(to: ISO8601Month())
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func nextMonthAction(_ sender: UIButton) {
        try! _calendarAdapter.scroll(to: _calendarAdapter.currentMonth.advanced(by: 1))
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func changeDisplayOptionAction(_ sender: UISegmentedControl) {
        _calendarAdapter.displayOption = [.dynamic, .fixed][sender.selectedSegmentIndex]
    }
    
    func bindMonthRange() {
        if let lowerBound = _monthRange.first {
            let now = ISO8601Month(),
                diff = try! now.distance(to: lowerBound)
            
            lowerBoundSwitch.isOn = true
            lowerBoundSlider.isEnabled = true
            lowerBoundSlider.setNeedsLayout() // this is needed to update the slider appearance. Check out: https://developer.apple.com/forums/thread/658526
            lowerBoundSlider.value = Float(diff)
            lowerBoundLabel.text = "\(lowerBound)"
        } else {
            lowerBoundSwitch.isOn = false
            lowerBoundSlider.isEnabled = false
            lowerBoundSlider.setNeedsLayout()
            lowerBoundLabel.text = "-"
        }
        
        if let upperBound = _monthRange.second {
            let now = ISO8601Month(),
                diff = try! now.distance(to: upperBound)
            
            upperBoundSwitch.isOn = true
            upperBoundSlider.isEnabled = true
            upperBoundSlider.setNeedsLayout()
            upperBoundSlider.value = Float(diff)
            upperBoundLabel.text = "\(upperBound)"
        } else {
            upperBoundSwitch.isOn = false
            upperBoundSlider.isEnabled = false
            upperBoundSlider.setNeedsLayout()
            upperBoundLabel.text = "-"
        }
    }
    
    @IBAction func toggleLowerBoundAction(_ sender: UISwitch) {
        _monthRange.first = sender.isOn ? ISO8601Month() : nil
    }
    
    @IBAction func lowerBoundChangeAction(_ sender: UISlider) {
        guard let _ = _monthRange.first else { preconditionFailure() }
        _monthRange.first = ISO8601Month().advanced(by: Int(sender.value))
    }
    
    @IBAction func toggleUpperBoundAction(_ sender: UISwitch) {
        _monthRange.second = sender.isOn ? ISO8601Month() : nil
    }
    
    @IBAction func upperBoundChangeAction(_ sender: UISlider) {
        guard let _ = _monthRange.second else { preconditionFailure() }
        _monthRange.second = ISO8601Month().advanced(by: Int(sender.value))
    }
    
    @IBAction func changeHorizontalAligmentAction(_ sender: UISegmentedControl) {
        calendarLayout.params.alignment.horizontal = [.packed, .filled, .spread][sender.selectedSegmentIndex]
    }
    
    @IBAction func changeVerticalAligmentAction(_ sender: UISegmentedControl) {
        calendarLayout.params.alignment.vertical = [.packed, .filled, .spread][sender.selectedSegmentIndex]
    }
    
    @IBAction func changeInsetAction(_ sender: UIStepper) {
        calendarLayout.params.sectionInset = withVar(calendarLayout.params.sectionInset) {
            switch sender {
            case topInsetStepper: $0.top = CGFloat(sender.value)
            case rightInsetStepper: $0.right = CGFloat(sender.value)
            case bottomInsetStepper: $0.bottom = CGFloat(sender.value)
            case leftInsetStepper: $0.left = CGFloat(sender.value)
            default: assertionFailure("unknown sender: \(sender)")
            }
        }
        
        let _ = withVar(calendarLayout.params.sectionInset) {
            topInsetLabel.text = "\(Int($0.top))"
            rightInsetLabel.text = "\(Int($0.right))"
            bottomInsetLabel.text = "\(Int($0.bottom))"
            leftInsetLabel.text = "\(Int($0.left))"
        }
    }
    
    @IBAction func changeSpacingAction(_ sender: UIStepper) {
        calendarLayout.params.spacing = withVar(calendarLayout.params.spacing) {
            switch sender {
            case hSpacingStepper: $0.width = CGFloat(sender.value)
            case vSpacingStepper: $0.height = CGFloat(sender.value)
            default: assertionFailure("unknown sender: \(sender)")
            }
        }
        
        let _ = withVar(calendarLayout.params.spacing) {
            hSpacingLabel.text = "\(Int($0.width))"
            vSpacingLabel.text = "\(Int($0.height))"
        }
    }
    
}

extension CalendarDemoViewController : CalendarAdapterDelegate {
    
    typealias Cell = CalendarDayCell
    
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, willChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month) {
        updateCurrentMonthButton(month: newValue)
        calendarViewHeight.constant = calendarLayout.sectionHeight(month: newValue)
    }
    
    func calendarPresenter(_ presenter: CalendarAdapter<Cell>, didChangeMonthFrom oldValue: ISO8601Month, to newValue: ISO8601Month) {
        
    }
    
}

class DemoCalendarAdapterComponentViewProvider : CalendarAdapterComponentViewProvider {
    
    typealias Cell = CalendarDayCell
    
    func getCellIdentifier() -> String { "\(CalendarDayCell.self)" }
    
    func configure(_ cell: Cell, with context: CalendarAdapterContext) {
        cell.label.alpha = context.position == .main ? 1.0 : 0.3
        cell.label.text = "\(context.date.dateComponents([.day]).day!)"
        cell.selectionView.isHidden = true
    }
    
}

class CalendarDayCell : UICollectionViewCell {
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionView.layer.cornerRadius = selectionView.frame.width * 0.5
    }
}
