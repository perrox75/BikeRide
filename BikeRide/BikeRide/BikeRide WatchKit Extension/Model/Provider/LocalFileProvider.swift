//
//  LocalFileProvider.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 02/09/2021.
//

import Foundation
import os.log

struct LocalFileProvider: ClassName {

    private var localDocumentsURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func listLocalFiles() -> [LocalFile] {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        let filemanager = FileManager.default
        if let url = localDocumentsURL {
            do {
                let urls = try filemanager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                var localFiles: [LocalFile] = []
                for url in urls {
                    Logger.model.debug("Found local file url: \(url, privacy: .public)")
                    // Skip directories
                    if url.hasDirectoryPath {
                        continue
                    }
                    localFiles.append(LocalFile(localURL: url))
                }
                return localFiles
            } catch {
                Logger.model.error("Error while listing local files: \(error.localizedDescription, privacy: .public)")
                return []
            }
        }

        return []
    }

    func removeLocalFile(localFile: LocalFile) {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: localFile.localURL)
        } catch {
            Logger.model.error("Failed to remove local file: \(error.localizedDescription, privacy: .public)")
        }
    }

    func saveToLocalFile(gpx: GPX) {

        guard !gpx.filename.isEmpty else {
            Logger.model.error("Filename of gpx object is empty while saving to local file")
            return
        }

        // Get json string of the gpx object
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(gpx)

            if let jsonFileDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pathWithFilename = jsonFileDirectory.appendingPathComponent(gpx.filename).deletingPathExtension().appendingPathExtension("json")
            do {
                try jsonData.write(to: pathWithFilename)
            }
        }
        } catch {
            Logger.model.error("Failed to write gpx object to file: \(error.localizedDescription, privacy: .public)")
        }
    }

    func loadFromLocalFile(localURL: URL) -> GPX? {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        do {
            let geoJSONData = try Data(contentsOf: localURL)
            let gpx = try JSONDecoder().decode(GPX.self, from: geoJSONData)
            return gpx

        } catch {
            Logger.model.error("Unable to load/serialize local json file: \(error.localizedDescription, privacy: .public)")
            return nil
        }

/*
        gpxToJSON.getCoordinateBox()
        minLon = gpxToJSON.minLon
        minLat = gpxToJSON.minLat
        maxLon = gpxToJSON.maxLon
        maxLat = gpxToJSON.maxLat
        */

    }

}
