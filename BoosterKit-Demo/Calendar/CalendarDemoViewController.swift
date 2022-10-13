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
    @IBOutlet weak var calendarView: UICollectionView! {
        didSet { _calendarAdapter.view = calendarView }
    }
    @IBOutlet weak var calendarLayout: CalendarLayout!
    private let _calendarAdapter = CalendarAdapter(viewProvider: DemoCalendarAdapterComponentViewProvider())
    
    @IBAction func prevMonthAction(_ sender: UIButton) {
        _calendarAdapter.currentMonth = _calendarAdapter.currentMonth.advanced(by: -1)
    }
    
    @IBAction func currentMonthAction(_ sender: UIButton) {
        _calendarAdapter.currentMonth = ISO8601Month()
    }
    
    @IBAction func nextMonthAction(_ sender: UIButton) {
        _calendarAdapter.currentMonth = _calendarAdapter.currentMonth.advanced(by: 1)
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
