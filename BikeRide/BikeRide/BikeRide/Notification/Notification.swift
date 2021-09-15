//
//  Notification.swift
//  BikeRide
//
//  Created by perrox75 on 19/08/2021.
//

import Foundation
import NotificationCenter

class NotificationCenter: NSObject, ObservableObject {
    var dumbData: UNNotificationResponse?
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationCenter: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        dumbData = response
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {

    }
}
