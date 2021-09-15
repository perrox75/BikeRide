//
//  CloudFileListView.swift
//  BikeRide
//
//  Created by perrox75 on 09/08/2021.
//

import SwiftUI

struct CloudFileListView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showGpxOnly = true

    var filteredCloudFiles: [CloudFile] {
        modelData.cloudFiles.filter { cloudFile in
            !showGpxOnly || cloudFile.isGpxExtension
        }
    }

    var body: some View {
        NavigationView {
            if modelData.isCloudLoading || !modelData.isCloudLoaded {
                ProgressView("Loading cloud files")
                    .onAppear {
                        modelData.loadCloudFiles()
                    }
            } else {
                VStack {
                    Toggle(isOn: $showGpxOnly) {
                        Text("GPX extension only")
                    }
                    Button("Reload") {
                        modelData.isCloudLoading = true
                        modelData.loadCloudFiles()
                    }
                    List {
                        ForEach(filteredCloudFiles) { cloudFile in
                            HStack {
                                if cloudFile.isLocal {
                                    NavigationLink(destination: LazyView(CloudFileDetailView(cloudFile: cloudFile))) {
                                        CloudFileRowView(cloudFile: cloudFile)
                                    }
                                } else {
                                    CloudFileRowView(cloudFile: cloudFile)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#if !TEST
struct CloudFileList_Previews: PreviewProvider {
    static var previews: some View {
        CloudFileListView()
            .environmentObject(ModelData())
    }
}
#endif
