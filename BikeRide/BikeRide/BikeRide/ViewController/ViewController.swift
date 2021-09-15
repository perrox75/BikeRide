//
//  ViewController.swift
//  BikeRide
//
//  Created by perrox75 on 13/08/2021.
//

import Foundation
import MapKit
import SwiftUI
import os.log

struct GenerateRoutingImage {

    func generate() -> UIImage? {
        let mapView = MKMapView()
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        var image: UIImage?
        mapSnapshotOptions.region = mapView.region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = mapView.frame.size
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [])

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start { (snap, error) in
            guard error == nil else {
                Logger.view.error("Start snapshot failed: \(error!.localizedDescription, privacy: .public)")
                return
            }
            image = snap?.image
        }
        return image
    }
}
