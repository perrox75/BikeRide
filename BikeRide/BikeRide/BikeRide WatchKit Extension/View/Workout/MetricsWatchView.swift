//
//  MetricsWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import SwiftUI

struct MetricsWatchView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        VStack(alignment: .leading) {
            ElapsedTimeWatchView(
                elapsedTime: workoutManager.builder?.elapsedTime ?? 0,
                showSubseconds: true
            )
            Text(
                Measurement(
                    value: workoutManager.activeEnery,
                    unit: UnitEnergy.kilocalories
                ).usFormatted
            )
            Text(String(format: "%f", workoutManager.heartRate))
            Text(
                Measurement(
                    value: workoutManager.distance,
                    unit: UnitLength.meters
                ).usFormatted
            )
        }
        .font(.system(.title, design: .rounded)
                .monospacedDigit()
                .lowercaseSmallCaps()
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea(edges: .bottom)
    }
}

#if !TEST
struct MetricsWatchView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsWatchView()
    }
}
#endif

extension Measurement where UnitType == UnitLength {
    private static let usFormatted: MeasurementFormatter = {
       let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .long
        return formatter
    }()
    var usFormatted: String { Measurement.usFormatted.string(from: self) }
}

extension Measurement where UnitType == UnitEnergy {
    private static let usFormatted: MeasurementFormatter = {
       let formatter = MeasurementFormatter()

        formatter.locale = Locale(identifier: "en_US")
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .long
        return formatter
    }()
    var usFormatted: String { Measurement.usFormatted.string(from: self) }
}
