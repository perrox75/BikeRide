//
//  ConnectivityWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 02/09/2021.
//

import SwiftUI

struct ConnectivityWatchView: View {
    @EnvironmentObject var modelDataWatch: ModelDataWatch

    var body: some View {
        VStack {
            if modelDataWatch.isPhoneReachable {
                Text("Phone reachable")
            } else {
                Text("Phone not reachabe")
            }
            if modelDataWatch.isInternetReachable {
                Text("Internet reachable")
            } else {
                Text("Internet not reachabe")
            }
        }
    }
}

#if !TEST
struct ConnectivityWatchView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectivityWatchView()
            .environmentObject(ModelDataWatch())
    }
}
#endif
