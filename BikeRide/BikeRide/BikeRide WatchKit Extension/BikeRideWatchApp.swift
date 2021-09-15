//
//  BikeRideWatchApp.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 28/07/2021.
//

import SwiftUI

@main
struct BikeRideWatchApp: App {
    @StateObject private var modelData = ModelDataWatch()
    @StateObject var workoutManager = WorkoutManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentWatchView()
            .environmentObject(modelData)
/*
            StartView()
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
*/
 }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
