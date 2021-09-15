//
//  CloudFileProvider.swift
//  BikeRide
//
//  Created by perrox75 on 09/08/2021.
//
// For reference see also https://github.com/amosavian/FileProvider/blob/master/Sources/CloudFileProvider.swift

import Foundation
import os.log

// Protocol to get information from iOS app to watch
protocol CloudFileProviderDelegate: AnyObject {
    func cloudFileWasDownloaded(_ urlFile: URL)
}

class CloudFileProvider: ClassName {
    // URL comes from Info.plist
    // Make sure entitlements are generated, use signing&capabilities project tabs

    // Delegation
    weak var delegate: CloudFileProviderDelegate?

    private var iCloudDocumentsURL: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    private func checkContainerAvailable() -> Bool {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        // Check for valid icloud doc url
        guard let url = iCloudDocumentsURL else {
            return false
        }

        let filemanager = FileManager.default

        // Check if folder already exists
        if !filemanager.fileExists(atPath: url.path, isDirectory: nil) {
            // Try to create container
            do {
                try filemanager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.model.error("Error while checking cloud containers: \(error.localizedDescription, privacy: .public)")
                return false
            }
        }
        return true
    }

    func listCloudFiles() -> [CloudFile] {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard checkContainerAvailable() else {
            return []
        }

        let filemanager = FileManager.default

        if let url = iCloudDocumentsURL {
            do {
                let urls = try filemanager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                var cloudFiles: [CloudFile] = []
                for url in urls {
                    print("Found url \(url)")
                    // Skip directories
                    if url.hasDirectoryPath {
                        continue
                    }
                    cloudFiles.append(CloudFile(cloudURL: url))
                }
                return cloudFiles
            } catch {
                Logger.model.error("Failed to load cloud files: \(error.localizedDescription, privacy: .public)")
                return []
            }
        }

        return []
    }

    func downloadFile(url: URL) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        let fileManager = FileManager.default

        do {
            try fileManager.startDownloadingUbiquitousItem(at: url )
        } catch {
            Logger.model.error("Unexpected error: \(error.localizedDescription, privacy: .public)")
        }

        var lastPathComponent = url.lastPathComponent
        // Delete the "." which is at the beginning of the icloud file name
        lastPathComponent.removeFirst()
        // Get folder path without the last component
        let folderPath = url.deletingLastPathComponent().path
        // Create the downloaded file path
        let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")

        // Start a thread that checks if the download is complete and notify with CloudFileProviderDelegation protocol
        DispatchQueue.global(qos: .userInteractive).async {
            // Check download status once in a while
            var isDownloaded = false
            while !isDownloaded {
                if fileManager.fileExists(atPath: downloadedFilePath) {
                    isDownloaded = true
                    Thread.sleep(forTimeInterval: 1)
                }
            }
            // Notify that file was downloaded
            DispatchQueue.main.async {
                self.delegate?.cloudFileWasDownloaded(url)
            }
        }
    }
}
