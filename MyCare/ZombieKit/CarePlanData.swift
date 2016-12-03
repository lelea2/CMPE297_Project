//
//  CarePlanData.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import CareKit

enum ActivityIdentifier: String {
  case cardio
  case outdoorWalk = "Outdoor Walk"
  case limberUp = "Limber Up"
  case drinkWater = "Drink Water"
  case pulse
  case temperature
}

class CarePlanData: NSObject {
    let carePlanStore: OCKCarePlanStore
    let contacts =
        [OCKContact(contactType: .personal,
                name: "Kareen Dao",
                relation: "Friend",
                tintColor: nil,
                phoneNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                messageNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                emailAddress: "ktest@test.com",
                monogram: "KD",
                image: nil),
         OCKContact(contactType: .personal,
                    name: "Tiffany Dao",
                    relation: "Sister",
                    tintColor: nil,
                    phoneNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                    messageNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                    emailAddress: "tdtest@test.com",
                    monogram: "TD",
                    image: nil),
         OCKContact(contactType: .careTeam,
                name: "Jane Do",
                relation: "Therapist",
                tintColor: nil,
                phoneNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                messageNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                emailAddress: "jdo@test.com",
                monogram: "JD",
                image: nil),
         OCKContact(contactType: .careTeam,
                name: "Dr Sammantha Green",
                relation: "Veterinarian",
                tintColor: nil,
                phoneNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                messageNumber: CNPhoneNumber(stringValue: "800-123-4567"),
                emailAddress: "dr.sg@test.com",
                monogram: "SG",
                image: nil)]

    class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
        return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek, occurrencesPerDay: occurencesPerDay)
    }

    init(carePlanStore: OCKCarePlanStore) {
        self.carePlanStore = carePlanStore
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let walkingActivity = OCKCarePlanActivity(
            identifier: ActivityIdentifier.outdoorWalk.rawValue,
            groupIdentifier: nil,
            type: .intervention,
            title: "Daily Walking",
            text: "30 Minutes",
            tintColor: UIColor.green(),
            instructions: "Take a leisurely walk after lunch",
            imageURL: nil,
            schedule: OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 1, 1, 1, 1, 1, 2]),
            resultResettable: true,
            userInfo: nil)

        let cardioActivity = OCKCarePlanActivity(
          identifier: ActivityIdentifier.cardio.rawValue,
          groupIdentifier: nil,
          type: .intervention,
          title: "Cardio",
          text: "60 Minutes",
          tintColor: UIColor.blue(),
          instructions: "Jog at a moderate pace for an hour. If there isn't an actual one, imagine a horde of zombies behind you.",
          imageURL: nil,
          schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 2),
          resultResettable: true,
          userInfo: nil)
    
        let limberUpActivity = OCKCarePlanActivity(
          identifier: ActivityIdentifier.limberUp.rawValue,
          groupIdentifier: nil,
          type: .intervention,
          title: "Limber Up",
          text: "Stretch Regularly",
          tintColor: UIColor.purple(),
          instructions: "Stretch and warm up muscles in your arms, legs and back before any expected burst of activity. This is especially important if, for example, you're heading down a hill to inspect a Hostess truck.",
          imageURL: nil,
          schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 6),
          resultResettable: true,
          userInfo: nil)
        
        let targetPracticeActivity = OCKCarePlanActivity(
          identifier: ActivityIdentifier.drinkWater.rawValue,
          groupIdentifier: nil,
          type: .intervention,
          title: "Drink Water",
          text: "Drink cup of water every 2 hours",
          tintColor: UIColor.pink(),
          instructions: "Make sure you have enough water yo!",
          imageURL: nil,
          schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 8),
          resultResettable: true,
          userInfo: nil)
    
        let pulseActivity = OCKCarePlanActivity
          .assessment(withIdentifier: ActivityIdentifier.pulse.rawValue,
                      groupIdentifier: nil,
                      title: "Pulse",
                      text: "Do you have one?",
                      tintColor: UIColor.darkGreen(),
                      resultResettable: true,
                      schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                      userInfo: ["ORKTask": AssessmentTaskFactory.makePulseAssessmentTask()])
    
        let temperatureActivity = OCKCarePlanActivity
          .assessment(withIdentifier: ActivityIdentifier.temperature.rawValue,
                      groupIdentifier: nil,
                      title: "Temperature",
                      text: "Oral",
                      tintColor: UIColor.darkYellow(),
                      resultResettable: true,
                      schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                      userInfo: ["ORKTask": AssessmentTaskFactory.makeTemperatureAssessmentTask()])
        super.init()
        for activity in [walkingActivity, cardioActivity, limberUpActivity, targetPracticeActivity, pulseActivity, temperatureActivity] {
            add(activity: activity)
        }
    }
  
    func add(activity: OCKCarePlanActivity) {
        carePlanStore.activity(forIdentifier: activity.identifier) {
            [weak self] (success, fetchedActivity, error) in
            guard success else { return }
            guard let strongSelf = self else { return }
            if let _ = fetchedActivity { return }
            strongSelf.carePlanStore.add(activity, completion: { _ in })
        }
    }
}

extension CarePlanData {
    func generateDocumentWith(chart: OCKChart?) -> OCKDocument {
        let intro = OCKDocumentElementParagraph(content: "See, I'm taking care of myself!")
    
        var documentElements: [OCKDocumentElement] = [intro]
        if let chart = chart {
            documentElements.append(OCKDocumentElementChart(chart: chart))
        }
        let document = OCKDocument(title: "Re: My activity", elements: documentElements)
        document.pageHeader = "Weekly Inside"
        return document
    }
}
