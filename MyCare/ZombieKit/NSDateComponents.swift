//
//  NSDateComponents.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import Foundation

extension DateComponents {
  static var firstDateOfCurrentWeek: DateComponents {
    var beginningOfWeek: NSDate?
    
    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    gregorian?.locale = Locale.current
    gregorian!.range(of: .weekOfYear, start: &beginningOfWeek, interval: nil, for: Date())
    let dateComponents = gregorian?.components([.era, .year, .month, .day],
                                               from: beginningOfWeek! as Date)
    return dateComponents!
  }
}
