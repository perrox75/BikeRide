//
//  GPX.swift
//  BikeRide
//
//  Created by perrox75 on 24/08/2021.
//

import Foundation

/// This struct holds the information typically needed to generate maps.
///
/// It is up to the owner to make sure that the information is correct. E.g. topleft and bottomright could be conflicting with center and latitudeDelta and longitudeDelta.
struct GPXCoordinateBox: Codable, Equatable {
    /// Topleft coordinate of the box.
    var topleft: GPXCoordinate = GPXCoordinate()
    /// Bottomright coordinate of the box.
    var bottomright: GPXCoordinate = GPXCoordinate()
    /// Center of the box.
    var center: GPXCoordinate = GPXCoordinate()
    /// Delta latitude from the center.
    var latitudeDelta: Double = 0.0
    /// Delta longitude from the center.
    var longitudeDelta: Double = 0.0

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXCoordinateBox, rhs: GPXCoordinateBox) -> Bool {
        return lhs.topleft == rhs.topleft &&
            lhs.bottomright == rhs.bottomright &&
            lhs.center == rhs.center &&
            lhs.latitudeDelta == rhs.latitudeDelta &&
            lhs.longitudeDelta == rhs.longitudeDelta
    }
}

/// This struct holds a coordinate.
///
/// It is up to the owner to make sure that the information is valid. E.g. Sane longitude and latitude values.
struct GPXCoordinate: Codable, Equatable {
    /// Latitude of the coordinate.
    var lat: Double = 0.0
    /// Longitude of the coordiinate.
    var lon: Double = 0.0

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXCoordinate, rhs: GPXCoordinate) -> Bool {
        return lhs.lat == rhs.lat &&
            lhs.lon == rhs.lon
    }
}

/// This struct holds a waypoint.
///
/// A waypoint denotes a coordinate of interest. E.g. typically along a route. Waypoints have a name that describe them.
struct GPXWaypoint: Codable, Equatable {
    /// Name of the waypoint.
    var name: String = ""
    /// Coordinate of the waypoint.
    var gpxCoordinate: GPXCoordinate = GPXCoordinate()

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXWaypoint, rhs: GPXWaypoint) -> Bool {
        return lhs.name == rhs.name &&
            lhs.gpxCoordinate == rhs.gpxCoordinate
    }
}

/// This struct holds a tracksegment.
///
/// A tracksegment is a part of a track. A tracksegment is typically recorded by gps-enabled devices.
struct GPXTrackSegment: Codable, Equatable {
    /// List of coordinates defining the track segment.
    var gpxCoordinates: [GPXCoordinate] = []

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXTrackSegment, rhs: GPXTrackSegment) -> Bool {
        return lhs.gpxCoordinates == rhs.gpxCoordinates
    }
}

/// This struct holds a track.
///
/// A track has a name and is contained of a list of tracksegments. A track is typically recorded by gps-enabled devices.
struct GPXTrack: Codable, Equatable {
    /// Name of the track.
    var name: String = ""
    /// List of tracksegments defining the track.
    var gpxTrackSegments: [GPXTrackSegment] = []

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXTrack, rhs: GPXTrack) -> Bool {
        return lhs.name == rhs.name &&
            lhs.gpxTrackSegments == rhs.gpxTrackSegments
    }
}

/// This struct holds a routepoint.
///
/// A routepoint has a name and a comment and a coordinate. Difference between a routepoint and a waypoint is that a waypoint is a special point of interest (e.g. a shop, endpoint, startpoint, sightseeing spot, ...), while a routepoint is more related to the route itself (e.g. left turn, right turn, crossing, roundabout, ...).
struct GPXRoutePoint: Codable, Equatable {
    /// Name of the routepoint. E.g. roundabout.
    var name: String = ""
    /// Comment of the routepoint. E.g. "Turn left to follow route".
    var comment: String = ""
    /// Coordinate of the routepoint.
    var gpxCoordinate: GPXCoordinate = GPXCoordinate()

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXRoutePoint, rhs: GPXRoutePoint) -> Bool {
        return lhs.name == rhs.name &&
            lhs.comment == rhs.comment &&
            lhs.gpxCoordinate == rhs.gpxCoordinate
    }
}

/// This struct holds a route.
///
/// A route has a name and is contained of a list of routepoints. A route is typically defined by using gpx tools.
struct GPXRoute: Codable, Equatable {
    /// Name of the route. Not to be confused with a filename, but could be the same.
    var name: String = ""
    /// List of routepoints that define the route.
    var gpxRoutePoints: [GPXRoutePoint] = []

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPXRoute, rhs: GPXRoute) -> Bool {
        return lhs.name == rhs.name &&
            lhs.gpxRoutePoints == rhs.gpxRoutePoints
    }
}

/// This struct holds all information tyipically contained in a gpx file.
///
/// See GPX exchange format (https://www.topografix.com/gpx/1/1/gpx.xsd)  for more details.
struct GPX: Codable, Equatable {
    /// Filename of the file where we got this gpx information from.
    var filename: String = ""
    /// Version of the gpx schema defined in the filename. This must be 1.1.
    var version: String = ""
    /// Name of the gpx information as found in the metadata of the file.
    var name: String = ""
    /// List of waypoints as found in the file.
    var gpxWaypoints: [GPXWaypoint] = []
    /// List of tracks as found in the file.
    var gpxTracks: [GPXTrack] = []
    /// List of routes as found in the file.
    var gpxRoutes: [GPXRoute] = []
    /// Coordinate box helper that contains all waypoints, tracks and routes.
    var coordinateBox: GPXCoordinateBox = GPXCoordinateBox()

    /// Equatable protocol implementation.
    /// - Parameters:
    ///   - lhs: Left hand side.
    ///   - rhs: Right hand side.
    /// - Returns: True of all members are equal, false otherwise.
    static func == (lhs: GPX, rhs: GPX) -> Bool {
        return lhs.filename == rhs.filename &&
            lhs.version == rhs.version &&
            lhs.name == rhs.name &&
            lhs.gpxWaypoints == rhs.gpxWaypoints &&
            lhs.gpxTracks == rhs.gpxTracks &&
            lhs.gpxRoutes == rhs.gpxRoutes &&
            lhs.coordinateBox == rhs.coordinateBox
    }
}
