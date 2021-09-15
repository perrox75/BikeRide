//
//  ViewModel.swift
//  BikeRide
//
//  Created by perrox75 on 08/08/2021.
//

import Foundation
import SwiftUI
import os.log

extension ModelData: ConnectivityProviderDelegate {

    func counterpartAppReachableDidChange(_ reachable: Bool) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        self.isWatchReachable = reachable
    }

    func stateDidChange(_ state: ConnectivityProviderState) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
    }

    func gpxWasReceived(_ gpx: GPX) {
        // We don't need/support sending gpx routes from watch to phone
        return
    }
}

final class ModelData: ClassName, ObservableObject {
    var connectivityProvider = ConnectivityProvider()
    var cloudFileProvider = CloudFileProvider()

    @Published var textFieldValue: String = ""
    @Published var textMessageReceived: String = "No text"
    @Published var cloudFiles: [CloudFile] = []
    @Published var isCloudLoading: Bool = true
    @Published var isCloudLoaded: Bool = false

    @Published var isWatchReachable: Bool = false

    var lastMessage: CFAbsoluteTime = 0

    init() {
        self.connectivityProvider.delegate = self
        self.connectivityProvider.connect()
    }

    func loadCloudFiles() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        isCloudLoading = true
        cloudFiles = cloudFileProvider.listCloudFiles()
        isCloudLoaded = true
        isCloudLoading = false
    }

    // Note: sendGPX sends the gpx data with object data rather with files.
    // Watchapp then saves that data to file.
    // Got the background transfer of files from phone to watch never working, while from watch to phone was working.
    func sendGpx(gpx: GPX?) {
        guard let gpx = gpx else {
            return
        }

        // Get json string of the gpx object
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(gpx)
            connectivityProvider.sendInChunks(message: jsonData)

            /*
            if let jsonFileDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pathWithFilename = jsonFileDirectory.appendingPathComponent(gpx.name)

                do {
                    try data.write(to: pathWithFilename)
                    self.sendFile(url: pathWithFilename)
                }
            }
             */
        } catch {
            Logger.model.error("Failed to json gpx object: \(error.localizedDescription, privacy: .public)")
        }
    }
}
