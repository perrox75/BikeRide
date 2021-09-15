//
//  SummaryWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import SwiftUI
import HealthKit

struct SummaryWatchView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.presentationMode) var presentationMode
    @State private var durationFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()

    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving workout")
                .navigationBarHidden(true)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    SummaryMetricView(
                        title: "Total Time",
                        value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? ""
                    ).accentColor(Color.yellow)
                    SummaryMetricView(
                        title: "Total Distance",
                        value: Measurement(
                            value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0.0,
                            unit: UnitLength.meters
                        ).usFormatted
                    ).accentColor(Color.green)
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
                            unit: UnitEnergy.kilocalories
                        ).usFormatted
                    ).accentColor(Color.pink)
                    SummaryMetricView(
                        title: "Avg. Heart Rate",
                        value: String(format: "%f", workoutManager.averageHeartRate)
                    ).accentColor(Color.red)
                    Text("Activity Rings")
                    ActivityRingsWatchView(
                        healthStore: workoutManager.healthStore
                    ).frame(width: 50, height: 50)
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Summary")
        }
    }
}

#if !TEST
struct SummaryWatchView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryWatchView()
    }
}
#endif

struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design: .rounded)
                    .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}
