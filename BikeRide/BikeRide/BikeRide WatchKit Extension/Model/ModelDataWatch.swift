//
//  ModelDataWatch.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 09/08/2021.
//

import Foundation
import Network
import os.log

final class ModelDataWatch: ClassName, ObservableObject {

    private var localFileProvider = LocalFileProvider()
    private var connectivityProvider = ConnectivityProvider()

    private var monitor = NWPathMonitor()

    @Published var isPhoneReachable: Bool = false
    @Published var localFiles: [LocalFile] = []
    @Published var isInternetReachable: Bool = false

    init() {
        self.connectivityProvider.delegate = self
        self.connectivityProvider.connect()

        self.localFiles = localFileProvider.listLocalFiles()

        self.monitor.pathUpdateHandler = isNetworkPathUpdated(path:)
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    func deleteLocalFiles(at offsets: IndexSet) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        offsets.forEach { index in
            LocalFileProvider().removeLocalFile(localFile: localFiles[index])
        }

        // Reload the file list
        localFiles = LocalFileProvider().listLocalFiles()
    }
}

extension ModelDataWatch: ConnectivityProviderDelegate {

    func counterpartAppReachableDidChange(_ reachable: Bool) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        DispatchQueue.main.async {
            self.isPhoneReachable = reachable
        }
    }

    func stateDidChange(_ state: ConnectivityProviderState) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")
    }

    func gpxWasReceived(_ gpx: GPX) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        DispatchQueue.main.async {
            self.localFileProvider.saveToLocalFile(gpx: gpx)
            self.localFiles = self.localFileProvider.listLocalFiles()
        }
    }
}

// Extension for network reachability check
extension ModelDataWatch {

    private func isNetworkPathUpdated(path: NWPath) {
        if path.status == .satisfied {
            DispatchQueue.main.async {
                self.isInternetReachable = true
            }
        } else {
            DispatchQueue.main.async {
                self.isInternetReachable = false
            }
        }
    }
}
