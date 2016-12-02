//
//  InsigntsDataManager.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import CareKit

class InsightsDataManager {
  let store = CarePlanStoreManager.sharedCarePlanStoreManager.store
  var completionData = [(dateComponent: DateComponents, value: Double)]()
  let gatherDataGroup = DispatchGroup()
  var pulseData = [DateComponents: Double]()
  var temperatureData = [DateComponents: Double]()

  var completionSeries: OCKBarSeries {
    let completionValues = completionData.map({ NSNumber(value:$0.value) })
    
    let completionValueLabels = completionValues
      .map({ NumberFormatter.localizedString(from: $0, number: .percent)})
    
    return OCKBarSeries(
      title: "Training",
      values: completionValues,
      valueLabels: completionValueLabels,
      tintColor: UIColor.darkOrange())
  }

  func fetchDailyCompletion(startDate: DateComponents, endDate: DateComponents) {
    gatherDataGroup.enter()

    store.dailyCompletionStatus(
      with: .intervention,
      startDate: startDate,
      endDate: endDate,
      handler: { (dateComponents, completed, total) in
        let percentComplete = Double(completed) / Double(total)
        self.completionData.append((dateComponents, percentComplete))
      },
      completion: { (success, error) in
        guard success else { fatalError(error!.localizedDescription) }
        self.gatherDataGroup.leave()
    })
  }
  
  func updateInsights(_ completion: ((Bool, [OCKInsightItem]?) -> Void)?) {
    guard let completion = completion else { return }
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
      let startDateComponents = DateComponents.firstDateOfCurrentWeek
      let endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
      
      guard let pulseActivity = self.findActivityWith(ActivityIdentifier.pulse) else { return }
      self.fetchActivityResultsFor(pulseActivity, startDate: startDateComponents,
                                   endDate: endDateComponents) { (fetchedData) in
                                    self.pulseData = fetchedData
      }
      
      guard let temperatureActivity = self.findActivityWith(ActivityIdentifier.temperature) else { return }
      self.fetchActivityResultsFor(temperatureActivity, startDate: startDateComponents,
                                   endDate: endDateComponents) { (fetchedData) in
                                    self.temperatureData = fetchedData
      }

      self.fetchDailyCompletion(startDate: startDateComponents, endDate: endDateComponents)
      
      // Once all data is gathered, process and return it
      self.gatherDataGroup.notify(queue: DispatchQueue.main, execute: {
        let insightItems = self.produceInsightsForAdherence()
        completion(true, insightItems)
      })
    }
  }
  
  func barSeriesFor(data: [DateComponents: Double], title: String, tintColor: UIColor) -> OCKBarSeries {
    let rawValues = completionData.map({ (entry) -> Double? in
      return data[entry.dateComponent]
    })
    
    let values = DataHelpers().normalize(rawValues)
    
    let valueLabels = rawValues.map({ (value) -> String in
      guard let value = value else { return "N/A" }
      return NumberFormatter.localizedString(from: NSNumber(value:value), number: .decimal)
    })
    
    return OCKBarSeries(
      title: title,
      values: values,
      valueLabels: valueLabels,
      tintColor: tintColor)
  }
  
  func produceInsightsForAdherence() -> [OCKInsightItem] {
    let dateStrings = completionData.map({(entry) -> String in
      guard let date = Calendar.current.date(from: entry.dateComponent)
        else { return "" }
      return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    })
    
    let pulseAssessmentSeries = barSeriesFor(data: pulseData, title: "Pulse",
                                             tintColor: UIColor.darkGreen())
    let temperatureAssessmentSeries = barSeriesFor(data: temperatureData, title: "Temperature",
                                                   tintColor: UIColor.darkYellow())
    
    // Create chart from completion and assessment series
    let chart = OCKBarChart(
      title: "Zombie Training Plan",
      text: "Training Compliance and Zombie Risks",
      tintColor: UIColor.green(),
      axisTitles: dateStrings,
      axisSubtitles: nil,
      dataSeries: [completionSeries, temperatureAssessmentSeries, pulseAssessmentSeries])
    
    return [chart]
  }
  
  func findActivityWith(_ activityIdentifier: ActivityIdentifier) -> OCKCarePlanActivity? {
    let semaphore = DispatchSemaphore(value: 0)
    var activity: OCKCarePlanActivity?
    
    DispatchQueue.main.async {
      self.store.activity(forIdentifier: activityIdentifier.rawValue) { success, foundActivity, error in
        activity = foundActivity
        semaphore.signal()
      }
    }
    
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    
    return activity
  }
  
  func fetchActivityResultsFor(_ activity: OCKCarePlanActivity,
                               startDate: DateComponents, endDate: DateComponents,
                               completionClosure: @escaping (_ fetchedData: [DateComponents: Double]) ->()) {
    var fetchedData = [DateComponents: Double]()
    self.gatherDataGroup.enter()

    store.enumerateEvents(
      of: activity,
      startDate: startDate,
      endDate: endDate,
      handler: { (event, stop) in
        if let event = event,
          let result = event.result,
          let value = Double(result.valueString) {
          fetchedData[event.date] = value
        }
      },
      completion: { (success, error) in
        guard success else { fatalError(error!.localizedDescription) }
        completionClosure(fetchedData)
        self.gatherDataGroup.leave()
    })
  }
}
