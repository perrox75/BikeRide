//
//  ImageListView.swift
//  BikeRide
//
//  Created by perrox75 on 17/08/2021.
//

import SwiftUI

struct ImageListView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        Image(uiImage: modelData.cloudFiles[1].snapshotImages[0])
    }
}

#if !TEST
struct ImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ImageListView()
            .environmentObject(ModelData())
    }
}
#endif
