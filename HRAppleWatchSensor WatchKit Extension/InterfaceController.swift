//
//  InterfaceController.swift
//  HRAppleWatchSensor WatchKit Extension
//
//  Created by Sergii Kostanian on 10/17/18.
//  Copyright © 2018 MAG. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var hrLabel: WKInterfaceLabel!
    
    let healthStore = HKHealthStore()

    @IBAction func startSession() {
        
        // Create Workout Configuration
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .running
        workoutConfiguration.locationType = .outdoor

        let workoutSession = try! HKWorkoutSession(healthStore: healthStore,
                                               configuration: workoutConfiguration)
        
        // Retrieve builder
        let builder = workoutSession.associatedWorkoutBuilder()
        
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: workoutConfiguration)
        builder.delegate = self
        
        // Start session and builder
        workoutSession.startActivity(with: Date())
        builder.beginCollection(withStart: Date(), completion: { (success, error) in
            // Handle error
        })
        
        extensionDelegate?.workoutSession = workoutSession
    }
    
    @IBAction func stopSession() {
        extensionDelegate?.workoutSession?.end()

        let builder = extensionDelegate?.workoutSession?.associatedWorkoutBuilder()
        builder?.endCollection(withEnd: Date(), completion: { (success, error) in
            // Handle error
        })
        
        extensionDelegate?.workoutSession = nil
        
        hrLabel.setText("--")
    }
}

extension InterfaceController: HKLiveWorkoutBuilderDelegate {
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        if collectedTypes.contains(heartRateType) {
            let updatedStatistics = workoutBuilder.statistics(for: heartRateType)
            let heartRate = updatedStatistics?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
            
            hrLabel.setText("\(Int(heartRate ?? 0))")
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
