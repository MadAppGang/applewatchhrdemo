//
//  ExtensionDelegate.swift
//  HRAppleWatchSensor WatchKit Extension
//
//  Created by Sergii Kostanian on 10/17/18.
//  Copyright © 2018 MAG. All rights reserved.
//

import WatchKit
import HealthKit
import WatchConnectivity

let extensionDelegate = WKExtension.shared().delegate as? ExtensionDelegate

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    let session = WCSession.default
    var workoutSession: HKWorkoutSession?

    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activate()
    }

    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
                
        // Create session
        workoutSession = try! HKWorkoutSession(healthStore: HKHealthStore(),
                                            configuration: workoutConfiguration)
        
        // Retrieve builder
        let builder = workoutSession?.associatedWorkoutBuilder()
                
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: HKHealthStore(), workoutConfiguration: workoutConfiguration)
        builder?.delegate = self
        
        // Start session and builder
        workoutSession?.startActivity(with: Date())
        builder?.beginCollection(withStart: Date(), completion: { (success, error) in
            // Handle error
        })
    }
}

extension ExtensionDelegate: HKLiveWorkoutBuilderDelegate {
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        if collectedTypes.contains(heartRateType) {
            let updatedStatistics = workoutBuilder.statistics(for: heartRateType)
            
            print(updatedStatistics?.mostRecentQuantity() ?? "")
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}


extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
