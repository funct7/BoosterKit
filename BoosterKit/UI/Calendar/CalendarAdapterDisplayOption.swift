//
//  CalendarAdapterDisplayOption.swift
//  BoosterKit
//
//  Created by Josh Woomin Park on 2022/10/31.
//

import Foundation

/**
 A flag that determines how many weeks should be displayed.
 */
public enum CalendarAdapterDisplayOption {
    /**
     Each month shows only the necessary number of weeks.
     
     For most months, 5 weeks will be shown.
     For months like Feb 2015 or Oct 2022, 4 weeks and 6 weeks will be shown respectively.
     */
    case dynamic
    /**
     Six weeks are shown for all months, and for 4 or 5-week months, days from the following month fill the bottom row(s).
     */
    case fixed
}
