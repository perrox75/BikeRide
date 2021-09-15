//
//  StartWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import SwiftUI
import HealthKit

struct StartWatchView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(
                workoutType.name,
                destination: SessionPagingWatchView(),
                tag: workoutType,
                selection: $workoutManager.selectedWorkout
            ).padding(
                EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
            )
        }
        .listStyle(CarouselListStyle())
        .navigationTitle("Workouts")
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

#if !TEST
struct StartWatchView_Previews: PreviewProvider {
    static var previews: some View {
        StartWatchView()
    }
}
#endif

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        default:
            return ""
        }
    }
}
