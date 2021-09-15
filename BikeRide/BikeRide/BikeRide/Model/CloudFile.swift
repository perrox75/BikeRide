//
//  CloudFile.swift
//  BikeRide
//
//  Created by perrox75 on 10/08/2021.
//

import Foundation
import MapKit
import SwiftUI
import os.log

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

class CloudFile: ClassName, Identifiable, ObservableObject {
    // View needs to refresh local icon if file becomes locally available
    @Published var isLocal: Bool

    let id = UUID()
    let cloudURL: URL?
    let filename: String
    let isGpxExtension: Bool

    var snapshotImages: [UIImage] = []

    var gpx: GPX?
    var geoJSONData: Data = Data()
    var isGeoJSONDataLoaded: Bool = false

    init(cloudURL: URL?) {
        if let url = cloudURL {
            self.cloudURL = url
            var lastPathComponent = url.lastPathComponent
            if lastPathComponent.contains(".icloud") {
                isLocal = false
                // File in cloud but not local start with . and end with .icloud
                lastPathComponent.removeFirst()
                filename = lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
            } else {
                isLocal = true
                filename = lastPathComponent
            }
            if URL(fileURLWithPath: filename).pathExtension.compare("GPX", options: .caseInsensitive) == .orderedSame {
                isGpxExtension = true
            } else {
                isGpxExtension = false
            }
        } else {
            self.cloudURL = URL(string: "file://invalid")
            filename = "INVALID CLOUD URL"
            isLocal = false
            isGpxExtension = false
        }
    }

    func downloadFile() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard !isLocal else {
            // File is already locally present
            return
        }

        guard let url = cloudURL else {
            return
        }

        let cloudFileProvider =  CloudFileProvider()
        cloudFileProvider.delegate = self
        cloudFileProvider.downloadFile(url: url)

        // We will be notified with CloudFileProviderDelegate protocol that file was downloaded
    }

    func loadGPX() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        isGeoJSONDataLoaded = false
        Logger.model.debug("Loading GPX file \(self.filename, privacy: .public)")

        guard let url = cloudURL else {
            return
        }

        let gpxHelper: GPXHelper = GPXHelper()
        gpxHelper.parseXML(gpxURL: url)
        gpx = gpxHelper.gpx
        geoJSONData = gpxHelper.writeGeoJSON()
        isGeoJSONDataLoaded = true

        return
    }

    func generateSnapshot() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let gpx = gpx else {
            return
        }

        let center = CLLocationCoordinate2D(latitude: gpx.coordinateBox.center.lat, longitude: gpx.coordinateBox.center.lon)

        // Set region based on first waypoint
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: gpx.coordinateBox.latitudeDelta,
                                                               longitudeDelta: gpx.coordinateBox.longitudeDelta))

        let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
        let size = CGSize(width: 300, height: 300)

        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = size
        mapOptions.showsBuildings = true

        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                Logger.model.error("Error while snapshotting: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshotOrNil {
                let image = UIGraphicsImageRenderer(size: mapOptions.size).image { (context) in
                    snapshot.image.draw(at: .zero)

                    let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                    let pinImage = pinView.image

                    var point = snapshot.point(for: center)

                    if rect.contains(point) {
                        point.x -= pinView.bounds.width / 2
                        point.y -= pinView.bounds.height / 2
                        point.x += pinView.centerOffset.x
                        point.y += pinView.centerOffset.y
                        pinImage?.draw(at: point)
                    }

                    UIColor.blue.setFill()
                    context.fill(CGRect(x: 1, y: 1, width: 140, height: 140))
                        UIColor.yellow.setFill()
                    context.fill(CGRect(x: 60, y: 60, width: 140, height: 140), blendMode: .luminosity)

                    // Add a linestroke
                    let point1 = snapshot.point(for: center)
                    let point2 = snapshot.point(for: CLLocationCoordinate2D(
                        latitude: gpx.coordinateBox.topleft.lat,
                        longitude: gpx.coordinateBox.topleft.lon
                    ))
                    context.cgContext.setStrokeColor(UIColor.red.cgColor)
                    context.cgContext.setLineWidth(3)
                    context.cgContext.move(to: point1)
                    context.cgContext.addLine(to: point2)
                    context.cgContext.drawPath(using: .fillStroke)
                }

                self.snapshotImages.append(image)
            }
        }

        return
    }
}

extension CloudFile: CloudFileProviderDelegate {

    func cloudFileWasDownloaded(_ urlFile: URL) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        Logger.model.debug("iCloud file locally downloaded: \(urlFile, privacy: .public)")
        isLocal = true
        
    }
}
