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
        _calendarAdapter.currentMonth = _calendarAdapter.currentMonth.advanced(by: -1)
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func currentMonthAction(_ sender: UIButton) {
        _calendarAdapter.currentMonth = ISO8601Month()
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func nextMonthAction(_ sender: UIButton) {
        _calendarAdapter.currentMonth = _calendarAdapter.currentMonth.advanced(by: 1)
        updateCurrentMonthButton(month: _calendarAdapter.currentMonth)
    }
    
    @IBAction func changeDisplayOptionAction(_ sender: UISegmentedControl) {
        _calendarAdapter.displayOption = [.dynamic, .fixed][sender.selectedSegmentIndex]
    }
    
    @IBAction func changeHorizontalAligmentAction(_ sender: UISegmentedControl) {
        calendarLayout.params.alignment.horizontal = [.packed, .filled, .spread][sender.selectedSegmentIndex]
    }
    
    @IBAction func changeVerticalAligmentAction(_ sender: UISegmentedControl) {
        calendarLayout.params.alignment.vertical = [.packed, .filled, .spread][sender.selectedSegmentIndex]
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
