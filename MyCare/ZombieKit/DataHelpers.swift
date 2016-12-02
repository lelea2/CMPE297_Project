//
//  DataHelpers.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import Foundation

class DataHelpers {
  
  func normalize(_ values: [Double?]) -> [NSNumber] {
    let valuesWithDefaults = values.map({ (value) -> Double in
      guard let value = value else { return 0.0 }
      return value
    })
    
    guard let maxValue = valuesWithDefaults.max() , maxValue > 0.0 else {
      return valuesWithDefaults.map({ NSNumber(value:$0) })
    }
    
    return valuesWithDefaults.map({NSNumber(value: $0 / maxValue)})
  }
  
}
