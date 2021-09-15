//
//  BikeRideTests.swift
//  BikeRideTests
//
//  Created by perrox75 on 28/07/2021.
//

import XCTest

class TestsGPX: XCTestCase {

    var sutGpx: GPX!
    var sutData: Data!

    // Setup a json data object from the gpx.json resource file on one end and build an alike gpx object on the other end
    // Make sure both json data object and gpx object are data-alike
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()

        // Reusable gpx json data
        let bundle = Bundle(for: type(of: self))
        let urlTmp = bundle.url(forResource: "gpx", withExtension: "json")
        guard let urlLoad = urlTmp else {
            XCTFail("Failed to get document user url")
            return
        }
        do {
            sutData = try Data(contentsOf: urlLoad)
        } catch {
            XCTFail("Failed to load test data")
        }

        // Reusable gpx object
        sutGpx = GPX()
        sutGpx.filename = "gpx.json"
        sutGpx.version = "01.23"
        sutGpx.name = "name"

        var routePoint01 = GPXRoutePoint()
        routePoint01.name = "routePoint01"
        routePoint01.comment = "Comment for routePoint01"
        routePoint01.gpxCoordinate = GPXCoordinate(lat: 1.23, lon: 4.56)
        var routePoint02 = GPXRoutePoint()
        routePoint02.name = "routePoint02"
        routePoint02.comment = "Comment for routePoint02"
        routePoint02.gpxCoordinate = GPXCoordinate(lat: 7.89, lon: -3.21)

        var route01 = GPXRoute()
        route01.name = "route01"
        route01.gpxRoutePoints.append(routePoint01)
        route01.gpxRoutePoints.append(routePoint02)

        var route02 = GPXRoute()
        route02.name = "route02"
        route02.gpxRoutePoints.append(routePoint02)
        route02.gpxRoutePoints.append(routePoint01)

        var waypoint01 = GPXWaypoint()
        waypoint01.name = "waypoint01"
        waypoint01.gpxCoordinate = GPXCoordinate(lat: -6.54, lon: -9.87)
        var waypoint02 = GPXWaypoint()
        waypoint02.name = "waypoint01"
        waypoint02.gpxCoordinate = GPXCoordinate(lat: 123.456, lon: 789.101112)

        var trackSegment01 = GPXTrackSegment()
        trackSegment01.gpxCoordinates.append(GPXCoordinate(lat: 1.23, lon: 4.56))
        trackSegment01.gpxCoordinates.append(GPXCoordinate(lat: 7.89, lon: -3.21))
        var trackSegment02 = GPXTrackSegment()
        trackSegment02.gpxCoordinates.append(GPXCoordinate(lat: -6.54, lon: -9.87))
        trackSegment02.gpxCoordinates.append(GPXCoordinate(lat: 123.456, lon: 789.101112))

        var track01 = GPXTrack()
        track01.name = "track01"
        track01.gpxTrackSegments.append(trackSegment01)
        track01.gpxTrackSegments.append(trackSegment02)

        var track02 = GPXTrack()
        track02.name = "track02"
        track02.gpxTrackSegments.append(trackSegment02)
        track02.gpxTrackSegments.append(trackSegment01)

        sutGpx.gpxRoutes.append(route01)
        sutGpx.gpxRoutes.append(route02)
        sutGpx.gpxTracks.append(track01)
        sutGpx.gpxTracks.append(track02)
        sutGpx.gpxWaypoints.append(waypoint01)
        sutGpx.gpxWaypoints.append(waypoint02)

        sutGpx.coordinateBox = GPXCoordinateBox()
        sutGpx.coordinateBox.bottomright = GPXCoordinate(lat: 1.23, lon: 4.56)
        sutGpx.coordinateBox.topleft = GPXCoordinate(lat: 7.89, lon: -3.21)
        sutGpx.coordinateBox.center = GPXCoordinate(lat: -6.54, lon: -9.87)
        sutGpx.coordinateBox.latitudeDelta = 123.456
        sutGpx.coordinateBox.longitudeDelta = 789.101112
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sutGpx = nil
        sutData = nil

        try super.tearDownWithError()
    }

    // Test encoding/decoding roundtrip
    func testGPXEncodeDecode() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let decoder = JSONDecoder()
        var gpxRoundTrip: GPX!

        // when
        do {
            let data = try encoder.encode(sutGpx)
            try gpxRoundTrip = decoder.decode(GPX.self, from: data)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }

        // then
        XCTAssertEqual(sutGpx, gpxRoundTrip)
    }

    // Decode from json data to gpx object
    func testGPXDecode() {
        // given
        let decoder = JSONDecoder()
        var gpxRoundTrip: GPX!

        // when
        do {
            try gpxRoundTrip = decoder.decode(GPX.self, from: sutData)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }

        // then
        // And now compare the resouce object with the new object
        XCTAssertEqual(sutGpx, gpxRoundTrip)
    }

    // Test equatable code for all gpx related objects
    func testGPXEquatable() {
        // given
        let decoder = JSONDecoder()
        var gpx: GPX!

        do {
            try gpx = decoder.decode(GPX.self, from: sutData)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }

        // when/then
        let coordinate01 = sutGpx.coordinateBox.bottomright
        var coordinate02 = gpx.coordinateBox.bottomright

        coordinate02.lat = 0.0
        XCTAssertNotEqual(coordinate01, coordinate02)
        coordinate02.lat = coordinate01.lat
        XCTAssertEqual(coordinate01, coordinate02)

        coordinate02.lon = 0.0
        XCTAssertNotEqual(coordinate01, coordinate02)
        coordinate02.lon = coordinate01.lon
        XCTAssertEqual(coordinate01, coordinate02)

        let coordinateBox01 = sutGpx.coordinateBox
        var coordinateBox02 = gpx.coordinateBox

        coordinateBox02.bottomright.lat = 0.0
        XCTAssertNotEqual(coordinateBox01, coordinateBox02)
        coordinateBox02.bottomright.lat = coordinateBox01.bottomright.lat
        XCTAssertEqual(coordinateBox01, coordinateBox02)

        coordinateBox02.topleft.lat = 0.0
        XCTAssertNotEqual(coordinateBox01, coordinateBox02)
        coordinateBox02.topleft.lat = coordinateBox01.topleft.lat
        XCTAssertEqual(coordinateBox01, coordinateBox02)

        coordinateBox02.center.lat = 0.0
        XCTAssertNotEqual(coordinateBox01, coordinateBox02)
        coordinateBox02.center.lat = coordinateBox01.center.lat
        XCTAssertEqual(coordinateBox01, coordinateBox02)

        coordinateBox02.latitudeDelta = 0.0
        XCTAssertNotEqual(coordinateBox01, coordinateBox02)
        coordinateBox02.latitudeDelta = coordinateBox01.latitudeDelta
        XCTAssertEqual(coordinateBox01, coordinateBox02)

        coordinateBox02.longitudeDelta = 0.0
        XCTAssertNotEqual(coordinateBox01, coordinateBox02)
        coordinateBox02.longitudeDelta = coordinateBox01.longitudeDelta
        XCTAssertEqual(coordinateBox01, coordinateBox02)

        let routepoint01 = sutGpx.gpxRoutes[0].gpxRoutePoints[0]
        var routepoint02 = gpx.gpxRoutes[0].gpxRoutePoints[0]

        routepoint02.name = ""
        XCTAssertNotEqual(routepoint01, routepoint02)
        routepoint02.name = routepoint01.name
        XCTAssertEqual(routepoint01, routepoint02)

        routepoint02.comment = ""
        XCTAssertNotEqual(routepoint01, routepoint02)
        routepoint02.comment = routepoint01.comment
        XCTAssertEqual(routepoint01, routepoint02)

        routepoint02.gpxCoordinate.lat = 0.0
        XCTAssertNotEqual(routepoint01, routepoint02)
        routepoint02.gpxCoordinate.lat = routepoint01.gpxCoordinate.lat
        XCTAssertEqual(routepoint01, routepoint02)

        let route01 = sutGpx.gpxRoutes[0]
        var route02 = gpx.gpxRoutes[0]

        route02.name = ""
        XCTAssertNotEqual(route01, route02)
        route02.name = route01.name
        XCTAssertEqual(route01, route02)

        route02.gpxRoutePoints[0].name = ""
        XCTAssertNotEqual(route01, route02)
        route02.gpxRoutePoints[0].name = route01.gpxRoutePoints[0].name
        XCTAssertEqual(route01, route02)

        let waypoint01 = sutGpx.gpxWaypoints[0]
        var waypoint02 = gpx.gpxWaypoints[0]

        waypoint02.name = ""
        XCTAssertNotEqual(waypoint01, waypoint02)
        waypoint02.name = waypoint01.name
        XCTAssertEqual(waypoint01, waypoint02)

        waypoint02.gpxCoordinate.lat = 0.0
        XCTAssertNotEqual(waypoint01, waypoint02)
        waypoint02.gpxCoordinate.lat = waypoint01.gpxCoordinate.lat
        XCTAssertEqual(waypoint01, waypoint02)

        let tracksegment01 = sutGpx.gpxTracks[0].gpxTrackSegments[0]
        var tracksegment02 = gpx.gpxTracks[0].gpxTrackSegments[0]

        tracksegment02.gpxCoordinates[0].lat = 0.0
        XCTAssertNotEqual(tracksegment01, tracksegment02)
        tracksegment02.gpxCoordinates[0].lat = tracksegment01.gpxCoordinates[0].lat
        XCTAssertEqual(tracksegment01, tracksegment02)

        let track01 = sutGpx.gpxTracks[0]
        var track02 = gpx.gpxTracks[0]

        track02.name = ""
        XCTAssertNotEqual(track01, track02)
        track02.name = track01.name
        XCTAssertEqual(track01, track02)

        track02.gpxTrackSegments[0].gpxCoordinates[0].lat = 0.0
        XCTAssertNotEqual(track01, track02)
        track02.gpxTrackSegments[0].gpxCoordinates[0].lat = track01.gpxTrackSegments[0].gpxCoordinates[0].lat
        XCTAssertEqual(track01, track02)

        gpx.filename = ""
        XCTAssertNotEqual(sutGpx, gpx)
        gpx.filename = sutGpx.filename
        XCTAssertEqual(sutGpx, gpx)

        gpx.name = ""
        XCTAssertNotEqual(sutGpx, gpx)
        gpx.name = sutGpx.name
        XCTAssertEqual(sutGpx, gpx)

        gpx.version = ""
        XCTAssertNotEqual(sutGpx, gpx)
        gpx.version = sutGpx.version
        XCTAssertEqual(sutGpx, gpx)
    }

    // Measuring encoding from gpx object to json data
    func testPerformanceJSONEncode() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        self.measure {
            // Put the code you want to measure the time of here.

            encoder.outputFormatting = .prettyPrinted
            do {
                _ = try encoder.encode(sutGpx)
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }

    // Measuring decoding from json data to gpx object
    func testPerformanceJSONDecode() throws {
        let decoder = JSONDecoder()

        self.measure {
            // Put the code you want to measure the time of here.
            do {
                try _ = decoder.decode(GPX.self, from: sutData)
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
}
