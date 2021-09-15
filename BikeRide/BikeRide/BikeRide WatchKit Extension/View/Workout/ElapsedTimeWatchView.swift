//
//  ElapsedTimeWatchView.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 20/08/2021.
//

import SwiftUI

struct ElapsedTimeWatchView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    @State private var timeFormatter = ElapsedTimeFormatter()

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#if !TEST
struct ElapsedTimeWatchView_Previews: PreviewProvider {
    static var previews: some View {
        ElapsedTimeWatchView()
    }
}
#endif

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString =
            componentsFormatter.string(from: time) else {
                return nil
            }

        if showSubseconds {
            let hundredths =
                Int((time.truncatingRemainder(dividingBy: 1))*100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
                return String(format: "%@%@%0.2d",
                    formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}
