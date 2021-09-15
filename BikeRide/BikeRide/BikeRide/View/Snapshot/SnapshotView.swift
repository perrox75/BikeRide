//
//  SnapshotView.swift
//  BikeRide
//
//  Created by perrox75 on 17/08/2021.
//

import SwiftUI
import MapKit
import os.log

struct SnapshotView: View, ClassName {
    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.01

    @State private var snapshotImage: UIImage?

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    Image(uiImage: image)
                } else {
                    VStack {
                        Spacer()
                        HStack {
                          Spacer()
                          ProgressView().progressViewStyle(CircularProgressViewStyle())
                          Spacer()
                        }
                        Spacer()
                      }
                      .background(Color(UIColor.secondarySystemBackground))
                }
            }
            .onAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    func generateSnapshot(width: CGFloat, height: CGFloat) {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        // The region the map should display.
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )

        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true

        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                Logger.view.error("Error while generating snapshot: \(error.localizedDescription, privacy: .public)")
                return
            }
            if let snapshot = snapshotOrNil {
                self.snapshotImage = snapshot.image
            }
        }

    }
}
