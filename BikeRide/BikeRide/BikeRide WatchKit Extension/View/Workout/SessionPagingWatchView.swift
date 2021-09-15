//
//  SessionPagingWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import SwiftUI
import WatchKit

struct SessionPagingWatchView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .metrics

    enum Tab {
        case controls, metrics, nowPlaying, navigation
    }

    var body: some View {
        TabView(selection: $selection) {
            ControlsWatchView().tag(Tab.controls)
            MetricsWatchView().tag(Tab.metrics)
            NowPlayingView().tag(Tab.nowPlaying)
            NavigationWatchView().tag(Tab.navigation)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .nowPlaying)
        .onChange(of: workoutManager.running) { _ in
            displayViewMetricsView()
        }
    }

    private func displayViewMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

#if !TEST
struct SessionPagingWatchView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingWatchView()
    }
}
#endif
