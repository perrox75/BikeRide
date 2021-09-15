//
//  MapWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 02/09/2021.
//

import SwiftUI
import MapKit
import CoreLocation
import os.log

enum AnnotationPointType {
    case point
    case waypoint
    case route
}

struct AnnotationPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationPointType
}

struct LocalFileMapWatchView: View, ClassName {
    var localFile: LocalFile

    @State private var region = MKCoordinateRegion()
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var points: [AnnotationPoint] = []

    @State private var isOnAppearOnce: Bool = false

    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: points) { point in
                MapAnnotation(
                    coordinate: point.coordinate
                ) {
                    switch point.type {
                    case .point:
                        Circle()
                            .stroke(Color.red)
                            .frame(width: 1, height: 1)
                    case .waypoint:
                        Image(systemName: "mappin.circle.fill").foregroundColor(.red)
                    case .route:
                        Image(systemName: "mappin").foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                // TODO Move these calculations to the model, so it is only calculated once
                if !isOnAppearOnce {
                    points.removeAll()
                    setRegion()
                    setPoints()
                    setWaypoints()
                    setRoutes()
                    isOnAppearOnce = true
                }
            }
        }
    }

    init(localFile: LocalFile) {
        self.localFile = localFile
    }

    private func setRegion() {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let gpx = localFile.gpx else {
            Logger.view.error("GPX object is nil.")
            return
        }

        region.center.latitude = gpx.coordinateBox.center.lat
        region.center.longitude = gpx.coordinateBox.center.lon
        region.span.latitudeDelta = gpx.coordinateBox.latitudeDelta
        region.span.longitudeDelta = gpx.coordinateBox.longitudeDelta
    }

    private func setPoints() {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let gpx = localFile.gpx else {
            Logger.view.error("GPX object is nil.")
            return
        }

        // Annotate to view route
        var prevPoint = AnnotationPoint(coordinate: .init(latitude: gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lat,
                                                          longitude: gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lat), type: .point)
        points.append(prevPoint)
        for track in gpx.gpxTracks {
            for segment in track.gpxTrackSegments {
                for coordinate in segment.gpxCoordinates {
                    let point = AnnotationPoint(coordinate: .init(latitude: coordinate.lat, longitude: coordinate.lon), type: .point)

                    // Only append if distance if more than 5 meter
                    let location0 = CLLocation(latitude: prevPoint.coordinate.latitude, longitude: prevPoint.coordinate.longitude)
                    let location1 = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                    let distanceInMeters = location0.distance(from: location1)

                    if distanceInMeters > 5 {
                        points.append(point)
                        prevPoint = point
                    }
                }
            }
        }
    }

    private func setWaypoints() {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let gpx = localFile.gpx else {
            Logger.view.error("GPX object is nil.")
            return
        }

        // Annotate to view waypoints
        for waypoint in gpx.gpxWaypoints {
            let coordinate = waypoint.gpxCoordinate
            let point = AnnotationPoint(coordinate: .init(latitude: coordinate.lat, longitude: coordinate.lon), type: .waypoint)
            points.append(point)
        }
    }

    private func setRoutes() {
        Logger.view.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let gpx = localFile.gpx else {
            Logger.view.error("GPX object is nil.")
            return
        }

        // Annotate to view waypoints
        for waypoint in gpx.gpxWaypoints {
            let coordinate = waypoint.gpxCoordinate
            let point = AnnotationPoint(coordinate: .init(latitude: coordinate.lat, longitude: coordinate.lon), type: .waypoint)
            points.append(point)
        }
    }
}

#if !TEST
struct LocalFileMapWatchView_Previews: PreviewProvider {
    static var previews: some View {
        let url = Bundle.main.url(forResource: "example_route", withExtension: "json")
        let localFile = LocalFile(localURL: url!)

        LocalFileMapWatchView(localFile: localFile)
    }
}
#endif
