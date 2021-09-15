//
//  ViewModelWatch.swift
//  BikeRide WatchKit Extension
//
//  Created by perrox75 on 29/07/2021.
//

import Foundation
import WatchConnectivity

class ViewModelWatch: NSObject, WCSessionDelegate {
    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

}
