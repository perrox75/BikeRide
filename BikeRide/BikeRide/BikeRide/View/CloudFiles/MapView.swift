//
//  MapView.swift
//  BikeRide
//
//  Created by perrox75 on 16/08/2021.
//

import SwiftUI
import MapKit
import os.log

struct PolylineInfo: Decodable {
    let name: String
}

struct PointInfo: Decodable {
    let name: String
}

struct MapView: UIViewRepresentable, ClassName {

    typealias UIViewType = MKMapView

    var mapView = MKMapView()
    var cloudFile: CloudFile

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIViewType {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        mapView.delegate = context.coordinator

        // Load gpx information is not loaded
        if !cloudFile.isGeoJSONDataLoaded {
            cloudFile.loadGPX()
        }

        guard let gpx = cloudFile.gpx else {
            Logger.view.error("GPX object is nil")
            return mapView
        }

        let center = CLLocationCoordinate2D(
            latitude: gpx.coordinateBox.center.lat,
            longitude: gpx.coordinateBox.center.lon
        )
        let span = MKCoordinateSpan(
            latitudeDelta: gpx.coordinateBox.latitudeDelta,
            longitudeDelta: gpx.coordinateBox.longitudeDelta
        )
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)

        // Add route and waypoints
        guard let objs = try? MKGeoJSONDecoder().decode(cloudFile.geoJSONData) as? [MKGeoJSONFeature] else {
            fatalError("Wrong format")
        }

        for feature in objs {
            guard let geometry = feature.geometry.first else {
                return mapView
            }

            guard let propData = feature.properties else {
                return mapView
            }

            // Check if LineString
            if let polyline = geometry as? MKPolyline {
                let polylineInfo = try? JSONDecoder.init().decode(PolylineInfo.self, from: propData)
                polyline.title = polylineInfo?.name
                mapView.addOverlay(polyline)
            }

            // Check if Point (annotation)
            if let annotation = geometry as? MKPointAnnotation {
                let pointInfo = try? JSONDecoder.init().decode(PointInfo.self, from: propData)
                annotation.title = pointInfo?.name
                mapView.addAnnotation(annotation)
            }
        }

        // Show user location
        mapView.showsUserLocation = true

        return mapView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        return
    }

    final class Coordinator: NSObject, MKMapViewDelegate {

        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let polylineView = MKPolylineRenderer(overlay: overlay)
                polylineView.lineWidth = 2
                polylineView.strokeColor = UIColor.red
                polylineView.lineCap = .round
                return polylineView
            }
            return MKOverlayRenderer.init()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "waypoint"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                // Make one
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.glyphText = annotation.title!
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}
