//
//  LocalFile.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 02/09/2021.
//

import Foundation
import os.log

struct LocalFile: Identifiable, ClassName {
    let id = UUID()
    
    var localURL: URL
    var gpx: GPX?

    init(localURL: URL) {
        self.localURL = localURL
        self.gpx = LocalFileProvider().loadFromLocalFile(localURL: self.localURL)

        guard gpx != nil else {
            return
        }
    }
}
