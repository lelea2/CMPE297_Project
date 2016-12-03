//
//  AssessmentTaskFactory.swift
//  MyCare
//
//  Created by Dao, Khanh on 12/2/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//

import ResearchKit
import HealthKit

//Healthkit assessment
struct AssessmentTaskFactory {

    static func makeGlucoseAssessmentTask() -> ORKTask {
        // Get the localized strings to use for the task.
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!
        let unit = HKUnit(from: "mg/dL")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)

        // Create a question.
        let title = NSLocalizedString("Input your blood glucose", comment: "")
        let questionStep = ORKQuestionStep(identifier: "GlucoseStep", title: title, answer: answerFormat)
        questionStep.isOptional = false

        // Create an ordered task with a single question.
        return ORKOrderedTask(identifier: "GlucoseTask", steps: [questionStep])
    }

    static func makePulseAssessmentTask() -> ORKTask {
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let unit = HKUnit(from: "count/min")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .integer)
        
        // Create a question.
        let title = "Measure the number of beats per minute."
        let text = "Place two fingers on your wrist and count how many beats you feel in 15 seconds.  Multiply this number by 4. If the result is 0, you are a zombie."
        let questionStep = ORKQuestionStep(identifier: "PulseStep", title: title, text: text, answer: answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question
        return ORKOrderedTask(identifier: "PulseTask", steps: [questionStep])
    }
  
    static func makeTemperatureAssessmentTask() -> ORKTask {
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
        let unit = HKUnit(from: "degF")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        // Create a question.
        let title = "Take temperature orally."
        let text = "Temperatures in the range of 99-103°F are an early sign of possible infection. Temperatures over 103°F generally indicate early stages of transformation. Temperatures below 90°F indicate you have died and are currently a zombie."
        let questionStep = ORKQuestionStep(identifier: "TemperatureStep", title: title, text: text, answer: answerFormat)
        questionStep.isOptional = false

        // Create an ordered task with a single question
        return ORKOrderedTask(identifier: "TemperatureTask", steps: [questionStep])
    }
}
