//
//  GPXHelper.swift
//  BikeRide
//
//  Created by perrox75 on 11/08/2021.
//

import Foundation
import os.log

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

class GPXHelper: NSObject, ClassName {
    var gpx: GPX = GPX()

    // Helper variables for the parser delegates
    private var errorDescription: String = ""
    private var isError: Bool = false
    private var xpath: String = ""
    private var gpxCoordinate: GPXCoordinate = GPXCoordinate()
    private var gpxWaypoint: GPXWaypoint = GPXWaypoint()
    private var gpxTrack: GPXTrack = GPXTrack()
    private var gpxTrackSegment: GPXTrackSegment = GPXTrackSegment()
    private var gpxRoute: GPXRoute = GPXRoute()
    private var gpxRoutePoint: GPXRoutePoint = GPXRoutePoint()

    func parseXML(gpxURL: URL) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard let parser = XMLParser(contentsOf: gpxURL) else {
            // Return empty data if parsing fails
            return
        }

        gpx.filename = gpxURL.lastPathComponent

        // Note that the delegation callbacks happen on the same main thread
        parser.delegate = self
        // No need to implement async behavior, when parse function exits, all delegation callbacks have all happened on main thread
        parser.parse()
    }

    private func calcCoordinateBox() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard !gpx.gpxTracks.isEmpty && !gpx.gpxTracks[0].gpxTrackSegments.isEmpty
            && !gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates.isEmpty else {
                return
        }

        var minLon: Double = gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lon
        var minLat: Double = gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lat
        var maxLon: Double = gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lon
        var maxLat: Double = gpx.gpxTracks[0].gpxTrackSegments[0].gpxCoordinates[0].lat

        for track in gpx.gpxTracks {
            for segment in track.gpxTrackSegments {
                for point in segment.gpxCoordinates {
                    if point.lon < minLon {
                        minLon = point.lon
                    }
                    if point.lon > maxLon {
                        maxLon = point.lon
                    }
                    if point.lat < minLat {
                        minLat = point.lat
                    }
                    if point.lat > maxLat {
                        maxLat = point.lat
                    }
                }
            }
        }

        // Calculate the center and the delta's
        let centerLon = (maxLon + minLon)/2
        let centerLat = (maxLat + minLat)/2
        let deltaLon = (maxLon - minLon)
        let deltaLat = (maxLat - minLat)

        gpx.coordinateBox =  GPXCoordinateBox(topleft: GPXCoordinate(lat: minLat, lon: minLon),
                                bottomright: GPXCoordinate(lat: maxLat, lon: maxLon),
                                center: GPXCoordinate(lat: centerLat, lon: centerLon),
                                latitudeDelta: deltaLat, longitudeDelta: deltaLon)
    }

    func writeGeoJSON() -> Data {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        struct GeoJSON: Encodable {
            let type: String = "FeatureCollection"
            var features: [Feature] = []
        }

        struct Feature: Encodable {
            let type: String = "Feature"
            var geometry: Geometry
            var properties: Properties
        }

        struct Geometry: Encodable {
            var type: String
            var coordinatesLineString: [[Double]] = []
            var coordinatesPoint: [Double] = []

            // swiftlint:disable nesting
            private enum CodingKeys: String, CodingKey {
                case type, coordinates
            }
            // swiftint:enable nesting

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(type, forKey: .type)
                if !coordinatesLineString.isEmpty {
                    try container.encode(coordinatesLineString, forKey: .coordinates)
                } else if !coordinatesPoint.isEmpty {
                    try container.encode(coordinatesPoint, forKey: .coordinates)
                } else {
                    fatalError("Programming error!")
                }
            }
        }

        struct Properties: Encodable {
            var name: String
        }

        var geoJSON: GeoJSON = GeoJSON()

        var geometry = Geometry(type: "LineString")
        for track in gpx.gpxTracks {
            for segment in track.gpxTrackSegments {
                for point in segment.gpxCoordinates {
                    geometry.coordinatesLineString.append([point.lon, point.lat])
                }
            }
        }
        let feature = Feature(geometry: geometry, properties: Properties(name: "GPX Route"))
        geoJSON.features.append(feature)

        for waypoint in gpx.gpxWaypoints {
            var geometry2 = Geometry(type: "Point")
            geometry2.coordinatesPoint.append(waypoint.gpxCoordinate.lon)
            geometry2.coordinatesPoint.append(waypoint.gpxCoordinate.lat)
            let feature = Feature(geometry: geometry2, properties: Properties(name: waypoint.name))
            geoJSON.features.append(feature)
        }

        do {
            let geoJSONData = try JSONEncoder().encode(geoJSON)
            return geoJSONData
        } catch {
            isError = true
            errorDescription = error.localizedDescription
        }

        return Data()
    }
}

extension GPXHelper: XMLParserDelegate {

    func parserDidEndDocument(_ parser: XMLParser) {
        guard !isError else {
            return
        }

        // We have a filled-in gpx object, so calculate the center and delta's once
        calcCoordinateBox()
    }

    // swiftlint:disable cyclomatic_complexity
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        #if DELEGATION_DEBUG
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
        #endif

        // Stop parsing if encountered an error
        guard !isError else {
            // Just continue without further analyzing
            return
        }

        xpath.append("/" + elementName)

        switch xpath {
        case "/gpx":
            // Check version is 1.1
            guard let version = attributeDict["version"] else {
                isError = true
                errorDescription = "No GPX version information in file"
                return
            }
            guard version == "1.1" else {
                isError = true
                errorDescription = "GPX version information is not 1.1"
                return
            }
            gpx.version = version
        case "/gpx/metadata/name":
            gpx.name = ""
        case "/gpx/wpt":
            // New waypoint found
            guard let lat = attributeDict["lat"] else {
                isError = true
                errorDescription = "No latitude information for waypoint"
                return
            }
            guard let lon = attributeDict["lon"] else {
                isError = true
                errorDescription = "No longitude information for waypoint"
                return
            }
            guard let doubleLat = Double(lat) else {
                isError = true
                errorDescription = "Latitude \(lat) is not a valid double"
                return
            }
            guard let doubleLon = Double(lon) else {
                isError = true
                errorDescription = "Longitude \(lon) is not a valid double"
                return
            }
            gpxCoordinate.lat = doubleLat
            gpxCoordinate.lon = doubleLon
        case "/gpx/trk/trkseg/trkpt":
            // New trackpoint found
            guard let lat = attributeDict["lat"] else {
                isError = true
                errorDescription = "No latitude information for trackpoint"
                return
            }
            guard let lon = attributeDict["lon"] else {
                isError = true
                errorDescription = "No longitude information for trackpoint"
                return
            }
            guard let doubleLat = Double(lat) else {
                isError = true
                errorDescription = "Latitude \(lat) is not a valid double"
                return
            }
            guard let doubleLon = Double(lon) else {
                isError = true
                errorDescription = "Longitude \(lon) is not a valid double"
                return
            }
            gpxCoordinate.lat = doubleLat
            gpxCoordinate.lon = doubleLon
        case "/gpx/rte/rtept":
            // New routepoint found
            guard let lat = attributeDict["lat"] else {
                isError = true
                errorDescription = "No latitude information for trackpoint"
                return
            }
            guard let lon = attributeDict["lon"] else {
                isError = true
                errorDescription = "No longitude information for trackpoint"
                return
            }
            guard let doubleLat = Double(lat) else {
                isError = true
                errorDescription = "Latitude \(lat) is not a valid double"
                return
            }
            guard let doubleLon = Double(lon) else {
                isError = true
                errorDescription = "Longitude \(lon) is not a valid double"
                return
            }
            gpxCoordinate.lat = doubleLat
            gpxCoordinate.lon = doubleLon
        default:
            // Not interested in this data
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        #if DELEGATION_DEBUG
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
        #endif

        // Stop parsing if encountered an error
        guard !isError else {
            // Just continue without further analyzing
            return
        }

        switch xpath {
        case "/gpx/wpt":
            // Write away waypoint
            gpxWaypoint.gpxCoordinate = gpxCoordinate
            gpx.gpxWaypoints.append(gpxWaypoint)
            gpxWaypoint.name = ""
        case "/gpx/trk":
            gpx.gpxTracks.append(gpxTrack)
            gpxTrack.name = ""
            gpxTrack.gpxTrackSegments = []
        case "/gpx/trk/trkseg":
            gpxTrack.gpxTrackSegments.append(gpxTrackSegment)
            gpxTrackSegment.gpxCoordinates = []
        case "/gpx/trk/trkseg/trkpt":
            gpxTrackSegment.gpxCoordinates.append(gpxCoordinate)
        case "/gpx/rte":
            gpx.gpxRoutes.append(gpxRoute)
            gpxRoute.name = ""
        case "/gpx/rte/rtept":
            gpxRoutePoint.gpxCoordinate = gpxCoordinate
            gpxRoute.gpxRoutePoints.append(gpxRoutePoint)
            gpxRoutePoint.name = ""
            gpxRoutePoint.comment = ""
        default:
            // Not interested in this data
            break
        }

        guard let index = xpath.lastIndex(of: "/") else {
            isError = true
            errorDescription = "Internal parsing error"
            return
        }
        xpath.removeSubrange(index..<xpath.endIndex)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        #if DELEGATION_DEBUG
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
        #endif

        // Stop parsing if encountered an error
        guard !isError else {
            // Just continue without further analyzing
            return
        }

        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        guard !data.isEmpty else {
            return
        }

        switch xpath {
        case "/gpx/metadata/name":
            gpx.name += data
        case "/gpx/wpt/name":
            gpxWaypoint.name += data
        case "/gpx/trk/name":
            gpxTrack.name += data
        case "/gpx/rte/name":
            gpxRoute.name += data
        case "/gpx/rte/rtept/name":
            gpxRoutePoint.name += data
        case "/gpx/rte/rtept/cmt":
            gpxRoutePoint.comment += data
        default:
            // Not interested in this data
            break
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        #if DELEGATION_DEBUG
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
        #endif

        Logger.model.error("Paring error: \(parseError.localizedDescription, privacy: .public)")

        isError = true
        errorDescription = parseError.localizedDescription
    }

}
