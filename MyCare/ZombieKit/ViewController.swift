//View controller for tab view
//
//  Created by Dao, Khanh on 11/22/16.
//  Copyright © 2016 cmpe297. All rights reserved.
//


import UIKit
import ResearchKit
import CareKit
import HealthKit

class ViewController: UITabBarController {
    fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
    fileprivate let carePlanData: CarePlanData
    fileprivate var symptomTrackerViewController: OCKSymptomTrackerViewController? = nil
    fileprivate var insightsViewController: OCKInsightsViewController? = nil
    fileprivate var insightChart: OCKBarChart? = nil

    required init?(coder aDecoder: NSCoder) {
        carePlanData = CarePlanData(carePlanStore: carePlanStoreManager.store)
        super.init(coder: aDecoder)
        carePlanStoreManager.delegate = self
        carePlanStoreManager.updateInsights()
        let infoStack = createInfoStack()
        let mealStack = createMealStack()
        let careCardStack = createCareCardStack()
        let symptomTrackerStack = createSymptomTrackerStack()
        let insightsStack = createInsightsStack()
        let connectStack = createConnectStack()
        self.viewControllers = [infoStack,
                                mealStack,
                                careCardStack,
                                symptomTrackerStack,
                                insightsStack,
                                connectStack]
        tabBar.tintColor = UIColor.pink()
        tabBar.barTintColor = UIColor.lightGreen()
    }


    //Render my own info
    fileprivate func createInfoStack() -> UINavigationController {
        let viewController = ProfileViewController()
        viewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        return UINavigationController(rootViewController : viewController)
    }

    //Render food intake
    //Render my own info
    fileprivate func createMealStack() -> UINavigationController {
        let viewController = FoodViewController()
        viewController.tabBarItem = UITabBarItem(title: "Meal", image: UIImage(named: "journal"), selectedImage: UIImage(named: "journal"))
        return UINavigationController(rootViewController : viewController)
    }


    //Render care card
    fileprivate func createCareCardStack() -> UINavigationController {
        let viewController = OCKCareCardViewController(carePlanStore: carePlanStoreManager.store)
        viewController.maskImage = UIImage(named: "heart")
        viewController.smallMaskImage = UIImage(named: "small-heart")
        viewController.maskImageTintColor = UIColor.red()
        viewController.tabBarItem = UITabBarItem(title: "Care Card", image: UIImage(named: "carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.title = "Care Card"
        return UINavigationController(rootViewController: viewController)
    }

    //Render systom tracking
    fileprivate func createSymptomTrackerStack() -> UINavigationController {
        let viewController = OCKSymptomTrackerViewController(carePlanStore: carePlanStoreManager.store)
        viewController.delegate = self
        viewController.progressRingTintColor = UIColor.blue()
        symptomTrackerViewController = viewController
        viewController.tabBarItem = UITabBarItem(title: "Symptom", image: UIImage(named: "symptoms"), selectedImage: UIImage.init(named: "symptoms-filled"))
        viewController.title = "Symptom"
        return UINavigationController(rootViewController: viewController)
    }

    //Render for insight creation
    fileprivate func createInsightsStack() -> UINavigationController {
        let viewController = OCKInsightsViewController(insightItems: [OCKInsightItem.emptyInsightsMessage()],
                                                   headerTitle: "Zombie Check", headerSubtitle: "")
        insightsViewController = viewController
        viewController.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "insights"), selectedImage: UIImage.init(named: "insights-filled"))
        viewController.title = "Insights"
        return UINavigationController(rootViewController: viewController)
    }

    //Render for connect to medical
    fileprivate func createConnectStack() -> UINavigationController {
        let viewController = OCKConnectViewController(contacts: carePlanData.contacts)
        viewController.delegate = self
        viewController.tabBarItem = UITabBarItem(title: "Connect", image: UIImage(named: "connect"), selectedImage: UIImage.init(named: "connect-filled"))
        viewController.title = "Connect"
        return UINavigationController(rootViewController: viewController)
    }
}

/************************************** Start Extend function *****************************/
// MARK: - OCKSymptomTrackerViewControllerDelegate
extension ViewController: OCKSymptomTrackerViewControllerDelegate {
    func symptomTrackerViewController(_ viewController: OCKSymptomTrackerViewController,
                                    didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        guard let userInfo = assessmentEvent.activity.userInfo,
            let task: ORKTask = userInfo["ORKTask"] as? ORKTask else { return }
    
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
    
        present(taskViewController, animated: true, completion: nil)
    }
}

// MARK: - ORKTaskViewControllerDelegate
extension ViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith
        reason: ORKTaskViewControllerFinishReason, error: Error?) {
        defer {
            dismiss(animated: true, completion: nil)
        }
    
        guard reason == .completed else { return }
        guard let symptomTrackerViewController = symptomTrackerViewController,
            let event = symptomTrackerViewController.lastSelectedAssessmentEvent else { return }
        let carePlanResult = carePlanStoreManager.buildCarePlanResultFrom(taskResult: taskViewController.result)
        carePlanStoreManager.store.update(event, with: carePlanResult, state: .completed) {
            success, _, error in
            if !success {
                print(error?.localizedDescription)
            }
        }
    }
}

// MARK: - CarePlanStoreManagerDelegate
extension ViewController: CarePlanStoreManagerDelegate {
    func carePlanStore(_ store: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem]) {
        if let trainingPlan = (insights.filter { $0.title == "Care Plan" }.first) {
            insightChart = trainingPlan as? OCKBarChart
        }
        insightsViewController?.items = insights
    }
}

// MARK: - OCKConnectViewControllerDelegate
extension ViewController: OCKConnectViewControllerDelegate {
    func connectViewController(_ connectViewController: OCKConnectViewController,
                             didSelectShareButtonFor contact: OCKContact,
                             presentationSourceView sourceView: UIView) {
        let document = carePlanData.generateDocumentWith(chart: insightChart)
        let activityViewController = UIActivityViewController(activityItems: [document.htmlContent],
                                                          applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
