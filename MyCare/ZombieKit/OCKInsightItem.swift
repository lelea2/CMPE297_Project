//
//  OKInsightItem.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import CareKit

extension OCKInsightItem {
  static func emptyInsightsMessage() -> OCKInsightItem {
    let text = "You haven't entered any data, or reports are in process. (Or you're a zombie?)"
    return OCKMessageItem(title: "No Insights", text: text,
                          tintColor: UIColor.darkOrange(), messageType: .tip)
  }
}
