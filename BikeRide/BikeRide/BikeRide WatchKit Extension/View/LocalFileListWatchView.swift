//
//  LocalFileListView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 02/09/2021.
//

import SwiftUI

struct LocalFileListWatchView: View {
    @EnvironmentObject var modelDataWatch: ModelDataWatch

    var body: some View {

        NavigationView {
            List {
                ForEach(modelDataWatch.localFiles) { localFile in
                    NavigationLink(destination: LazyView(LocalFileMapWatchView(localFile: localFile))) {
                        Text(localFile.localURL.deletingPathExtension().lastPathComponent)
                    }
                }
                .onDelete(perform: { indexSet in modelDataWatch.deleteLocalFiles(at: indexSet) })
            }
        }
    }
}

#if !TEST
struct LocalFileListWatchView_Previews: PreviewProvider {
    static var previews: some View {
        LocalFileListWatchView()
    }
}
#endif
