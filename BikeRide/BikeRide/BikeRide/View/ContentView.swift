//
//  ContentView.swift
//  BikeRide
//
//  Created by perrox75 on 28/07/2021.
//

import SwiftUI

import MapKit

struct ContentView: View {
    @State private var selection: Tab = .cloudFiles

    enum Tab {
        case cloudFiles
        case connectivity
        case snapshot
    }

    var body: some View {
        TabView(selection: $selection) {
            CloudFileListView()
                .tabItem {
                    Label("Cloud", systemImage: "externaldrive.badge.icloud")
                }
                .tag(Tab.cloudFiles)
            ConnectivityView()
                .tabItem {
                    Label("Connectivity", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(Tab.connectivity)
/*
            SnapshotView(location: coordinates)
                .tabItem {
                    Label("Connectivity", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(Tab.snapshot)
 */
        }
/*
        .onAppear(perform: registerForPushNotifications)
*/
    }

/*
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert,.sound,.badge]) { granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                getNotificationSettings()
        }
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
        print("Notification settings: \(settings)")
      }
    }
*/
}

#if !TEST
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
#endif
