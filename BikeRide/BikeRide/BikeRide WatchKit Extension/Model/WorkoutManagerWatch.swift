//
//  WorkoutManagerWatch.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import Foundation
import HealthKit
import CoreLocation

class WorkoutManager: NSObject, ObservableObject {

    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }

    @Published var showingSummaryView: Bool = false {
        didSet {
            // Sheet dismissed
            if showingSummaryView == false {
                resetWorkout()
            }

        }
    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var locationManager: CLLocationManager?
    var routeBuilder: HKWorkoutRouteBuilder?

    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnery: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    // State control
    @Published var running = false

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }

    func endWorkout() {
        session?.end()

        // Save route information
        guard let workout = workout else { return }
        routeBuilder?.finishRoute(with: workout, metadata: nil) { (newRoute, _) in
            guard newRoute != nil else {
                // Handle error
                return
            }
        }

        showingSummaryView = true
    }

    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            builder = session?.associatedWorkoutBuilder()

        } catch {
            // Handle any exception
            return
        }

        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        session?.delegate = self
        builder?.delegate = self

        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (_, _) in
            // Workout has started
        }

        // Location support
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    }

    func requestAuthorization() {
        let typesToShare: Set = [HKQuantityType.workoutType()]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (_, _) in
            // Handle error

        }
    }

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnery = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        locationManager = nil
        routeBuilder = nil
        activeEnery = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {

        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (_, _) in
                self.builder?.finishWorkout { (workout, _) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        return
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        return
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            updateForStatistics(statistics)
        }
    }
}

extension WorkoutManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Filter the raw data
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }

        guard !filteredLocations.isEmpty else {
            return
        }

        routeBuilder?.insertRouteData(filteredLocations) { (success, _) in
            if !success {
                // Handle errors
            }
        }
    }
}
