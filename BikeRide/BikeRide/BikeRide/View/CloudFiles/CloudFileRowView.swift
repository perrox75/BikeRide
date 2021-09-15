//
//  CloudFileRowView.swift
//  BikeRide
//
//  Created by perrox75 on 10/08/2021.
//

import SwiftUI

struct CloudFileRowView: View {
    @EnvironmentObject var modelData: ModelData
    var cloudFile: CloudFile

    var body: some View {
        Button(action: {
            modelData.objectWillChange.send()
            cloudFile.downloadFile()
            }) {
            Image(systemName: cloudFile.isLocal  ? "icloud.fill" : "icloud")
                .foregroundColor(cloudFile.isLocal ? Color.green : Color.gray)
        }
        Text(cloudFile.filename)
    }

    init(cloudFile: CloudFile) {
        self.cloudFile = cloudFile
    }
}

#if !TEST
struct CloudFileRow_Previews: PreviewProvider {
    static let cloudFile01 = CloudFile(cloudURL: URL(string: "file://route01.gpx"))
    static let cloudFile02 = CloudFile(cloudURL: URL(string: "file://route02.gpx"))

    static var previews: some View {
        CloudFileDetailView(cloudFile: cloudFile01)
        CloudFileDetailView(cloudFile: cloudFile02)
    }
}
#endif
