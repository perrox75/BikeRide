//
//  ConnectivityView.swift
//  BikeRide
//
//  Created by perrox75 on 10/08/2021.
//

import SwiftUI

struct ConnectivityView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack {
            if modelData.isWatchReachable {
                Text("Watch reachable")
            } else {
                Text("Watch not reachabe")
            }
        }
    }
}

#if !TEST
struct ConnectivityView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectivityView()
            .environmentObject(ModelData())
    }
}
#endif
