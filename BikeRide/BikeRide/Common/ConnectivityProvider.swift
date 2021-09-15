//
//  ConnectivityProvider.swift
//  BikeRide
//
//  Created by perrox75 on 08/08/2021.
//

import WatchConnectivity
import os.log

enum ConnectivityProviderState {
    case active, notActive
}

// Protocol to get information from iOS app to watch
protocol ConnectivityProviderDelegate: AnyObject {
    func counterpartAppReachableDidChange(_ reachable: Bool)
    func gpxWasReceived(_ gpx: GPX)
    func stateDidChange(_ state: ConnectivityProviderState)
}

class ConnectivityProvider: NSObject, ClassName {

    // 50 KB message
    private let chunkSize = 1024 * 50

    // Const definitions
    private let keyType: String = "Type"
    private let valueGPX: String = "GPX"
    private let keyId: String = "Id"
    private let keyChunkNbr: String = "ChunkNbr"
    private let keyChunkTotalNbr: String = "ChunkTotalNbr"
    private let keyData: String = "Data"

    // Helper variables for getting the gpx route in chunks
    private var messageUUID: String = ""
    private var messageType: String = ""
    private var messageChunkNbr: Int = 0
    private var messageChunkTotalNbr: Int = 0
    private var messageData: Data = Data()

    // Session object we are proxying
    private var session: WCSession

    // State of session
    var state: ConnectivityProviderState = .notActive
    var counterPartAppReachable: Bool = false

    // Delegation
    weak var delegate: ConnectivityProviderDelegate?

    // Configure a session
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }

    // Print session status
    private func printSessionStatus() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        print("Session watch state did change")
        print("OutstandingFileTransfers = \(session.outstandingFileTransfers.count)")
        print("hasContentPending = \(session.hasContentPending)")
        print("isTransferring = \(session.outstandingFileTransfers[0].isTransferring)")

        #if os(iOS)
        print("isPaired = \(session.isPaired)")
        print("isWatchAppInstalled = \(session.isWatchAppInstalled)")
        print("isComplicationEnabled = \(session.isComplicationEnabled)")
        print("watchDirectoryURL = \(session.watchDirectoryURL as Optional)")
        #endif
    }

    private func WCSessionStateToConnectivityProvideState(state: WCSessionActivationState) -> ConnectivityProviderState {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        switch state {
        case WCSessionActivationState.inactive, WCSessionActivationState.notActivated:
            return .notActive
        case WCSessionActivationState.activated:
            return .active
        default:
            Logger.model.error("Programming error: Should never come here")
            return .notActive
        }
    }

    // Activate the session
    func connect() {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard WCSession.isSupported() else {
            Logger.model.debug("WCSession is not supported")
            return
        }
        session.activate()

        // Wait for feedback on success of activation with session activationDidCompleteWith delegation call

        return
    }

    func sendInChunks(message: Data) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        func replyHandler(replyMessage: [String: Any]) {
            return
        }

        func errorHandler(error: Error) {
            Logger.model.error("Sending in chunks failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        let dataChunk = DataChunk()
        let data = dataChunk.dataIntoChunks(data: message, chunkSize: chunkSize)

        let uuid = UUID().uuidString
        for index in 0..<data.count {
            let encapsulatedData = [keyType: valueGPX, keyId: uuid,
                                    keyChunkNbr: index,
                                    keyChunkTotalNbr: data.count,
                                    keyData: data[index]] as [String: Any]
            // Send all message chunks in burst, iOS will handle the buffering
            session.sendMessage(encapsulatedData, replyHandler: replyHandler, errorHandler: errorHandler)
        }
    }
}

extension WCSessionActivationState: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case WCSessionActivationState.inactive.rawValue, WCSessionActivationState.notActivated.rawValue :
            return "notActive"
        case WCSessionActivationState.activated.rawValue:
            return "Active"
        default:
            return "Illegal state"
        }
    }
}

extension ConnectivityProvider: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        guard error == nil else {
            Logger.model.error("Error on session activation: \(error!.localizedDescription, privacy: .public)")
            return
        }

        Logger.model.debug("Session activation state: \(activationState.description, privacy: .public)")

        if activationState == .activated {
            state = .active
        } else {
            state = .notActive
        }

        // Notify about current state
        DispatchQueue.main.async {
            self.delegate?.stateDidChange(self.state)
        }

        counterPartAppReachable = session.isReachable

        // Also notify on counterpart app reachability
        DispatchQueue.main.async {
            self.delegate?.counterpartAppReachableDidChange(self.counterPartAppReachable)
        }

        return
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        counterPartAppReachable = session.isReachable

        DispatchQueue.main.async {
            self.delegate?.counterpartAppReachableDidChange(session.isReachable)
        }

        return
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        func resetMessageData() {
            messageData.removeAll()
            messageChunkTotalNbr = 0
            messageChunkNbr = 0
            messageUUID = ""
        }

        var allChunkDataReceived = false

        guard let type = message[keyType] as? String else {
            Logger.model.error("Message not in expected format: key 'Type' is missing")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'Type' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }
        guard let uuid = message[keyId] as? String else {
            Logger.model.error("Message not in expected format: key 'Id' is missing")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'Id' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }
        guard let data = message[keyData] as? Data else {
            Logger.model.error("Message not in expected format: key 'Data' is missing")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'Data' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }
        guard let chunkNbr = message[keyChunkNbr] as? Int else {
            Logger.model.error("Message not in expected format: key 'keyChunkNbr' is missing")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'keyChunkNbr' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }
        guard let chunkTotalNbr = message[keyChunkTotalNbr] as? Int else {
            Logger.model.error("Message not in expected format: key 'keyChunkTotalNbr' is missing")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'keyChunkTotalNbr' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }

        guard type == valueGPX else {
            Logger.model.error("Message type is not supported: Type is \(type, privacy: .public)")
            resetMessageData()
            let reply = ["Nack": "Message not in expected format: key 'Type' is missing"] as [String: Any]
            replyHandler(reply)
            return
        }

        if chunkNbr == 0 {
            // New chunk, drop old transfers
            resetMessageData()

            // Receive first packet and reply
            messageUUID = uuid
            messageType = type
            messageChunkNbr = chunkNbr
            messageChunkTotalNbr = chunkTotalNbr
        }

        // We must get packets from the same uuid in sequential order
        guard messageUUID == uuid, type == messageType, messageChunkTotalNbr == chunkTotalNbr, messageChunkNbr == chunkNbr else {
            Logger.model.error("Inconsistent sequential package received")
            resetMessageData()
            let reply = ["Nack": "Inconsistent sequential package received"] as [String: Any]
            replyHandler(reply)
            return
        }

        messageData.append(data)

        // All ok, reply packet was received and handled
        let reply = ["Ack": ""] as [String: Any]
        replyHandler(reply)

        // Could be last packet
        messageChunkNbr += 1
        if messageChunkNbr == chunkTotalNbr {
            allChunkDataReceived = true
        }

        if allChunkDataReceived {
            // We received total message, notify through delegation
            do {
                let gpx: GPX = try JSONDecoder().decode(GPX.self, from: messageData)

                // Notify all data was received
                DispatchQueue.main.async {
                    self.delegate?.gpxWasReceived(gpx)
                }
            } catch {
                Logger.model.error("Unable to decode message data to GPX route.")
                return
            }
        }

        return
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        return
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        return
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Logger.model.debug("Entering \(self.className(), privacy: .public).\(#function, privacy: .public)")

        return
    }
    #endif
}
