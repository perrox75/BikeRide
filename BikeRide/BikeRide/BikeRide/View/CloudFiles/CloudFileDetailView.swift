//
//  CloudFileDetailView2.swift
//  BikeRide
//
//  Created by perrox75 on 16/08/2021.
//

import SwiftUI
import MapKit

extension View {
    func snapshot() -> SnapshotImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let image = renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        return SnapshotImage(image: image)
    }
}

struct CloudFileDetailView: View {
    @EnvironmentObject var modelData: ModelData

    @State private var rect: CGRect = .zero

    var cloudFile: CloudFile
    var cloudFileIndex: Int {
        modelData.cloudFiles.firstIndex(where: { $0.id == cloudFile.id })!
    }

    var view: some View {
        MapView(cloudFile: cloudFile)
    }

    var body: some View {
        VStack {
            Text(cloudFile.filename)
            view
            HStack {
                Button(action: {modelData.sendGpx(gpx: modelData.cloudFiles[cloudFileIndex].gpx) }) {
                    Text("Transfer to watch")
                }.disabled(!modelData.isWatchReachable)
            }
        }
        /*
        .onAppear {
            cloudFile.generateSnapshot()
        }
        */
    }
}

#if !TEST
struct CloudFileDetailView2_Previews: PreviewProvider {
    static var previews: some View {
        let cloudFile = CloudFile(cloudURL: nil)
        CloudFileDetailView(cloudFile: cloudFile)
    }
}
#endif
