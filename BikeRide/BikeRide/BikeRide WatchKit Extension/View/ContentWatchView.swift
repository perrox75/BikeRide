//
//  ContentWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 28/07/2021.
//

import SwiftUI

struct ContentWatchView: View {
    @EnvironmentObject var modelDataWatch: ModelDataWatch

    @State private var selection: Tab = .localFiles

    enum Tab {
        case localFiles
        case connectivity
    }

    var body: some View {
        TabView(selection: $selection) {
            LocalFileListWatchView()
                .tabItem {
                    Label("Local", systemImage: "externaldrive")
                }
                .tag(Tab.localFiles)
            ConnectivityWatchView()
                .tabItem {
                    Label("Connectivity", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(Tab.connectivity)
        }
    }
}

#if !TEST
struct ContentWatchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentWatchView()
    }
}
#endif
