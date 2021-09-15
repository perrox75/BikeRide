//
//  Route.swift
//  BikeRide
//
//  Created by perrox75 on 18/08/2021.
//

import Foundation

struct Location {
    let latitude: Double
    let longitude: Double
    let isWaypoint: Bool = false
    var isVisited: Bool = false
    var distanceToNextLocation: Double
    var directionToNextLocation: Double
}

struct Route {
    let name: String
    let distance: Double
    let locations: [Location]
    let locationResolution: Int
    var visited: Bool = false
}
