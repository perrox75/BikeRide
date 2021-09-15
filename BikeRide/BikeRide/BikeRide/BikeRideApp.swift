//
//  BikeRideApp.swift
//  BikeRide
//
//  Created by perrox75 on 28/07/2021.
//

import SwiftUI

import UserNotifications
import os.log

@main

struct BikeRideApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @StateObject private var modelData = ModelData()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ClassName {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Logger.app.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        return true
    }

    // No callback in simulator
    // -- must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.app.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        Logger.app.debug("Device Token: \(token, privacy: .public)")
}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.app.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        Logger.app.error("Error while registering for remote notifications: \(error.localizedDescription, privacy: .public)")
    }
}
