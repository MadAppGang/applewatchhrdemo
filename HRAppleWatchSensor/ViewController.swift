//
//  ViewController.swift
//  HRAppleWatchSensor
//
//  Created by Sergii Kostanian on 10/17/18.
//  Copyright © 2018 MAG. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    let healthStore = HKHealthStore()
    var observerQuery: HKObserverQuery?
    
    let typesToShare: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKSampleType.workoutType()
    ]
    
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request access
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in 
            // Handle errors
        }
    }
    
    @IBAction func startSession(_ sender: Any) {
        
        // Create Workout Configuration
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .running
        workoutConfiguration.locationType = .outdoor
        
        // Start watch app with created Workout Configuration 
        healthStore.startWatchApp(with: workoutConfiguration) { [weak self] (success, error) in
            self?.observeHeartRateSamples()
        }
    }
    
    func observeHeartRateSamples() {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
              
        if let observerQuery = observerQuery {
            healthStore.stop(observerQuery)
        }
        
        observerQuery = HKObserverQuery(sampleType: heartRateSampleType, predicate: nil) { (_, _, _) in
            
            self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    return
                }
                
                DispatchQueue.main.async {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    print("Heart Rate Sample: \(heartRate)")
                }
            }
        }
        
        healthStore.execute(observerQuery!)
    }
    
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, _) in
            completionHandler(results?[0] as? HKQuantitySample)
        }
        
        healthStore.execute(query)
    }
}

