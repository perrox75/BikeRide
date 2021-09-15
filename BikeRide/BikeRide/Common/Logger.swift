//
//  Logger.swift
//  WatchTransfer
//
//  Created by perrox75 on 26/08/2021.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let app = Logger(subsystem: subsystem, category: "app")
    static let model = Logger(subsystem: subsystem, category: "model")
    static let controller = Logger(subsystem: subsystem, category: "controller")
    static let view = Logger(subsystem: subsystem, category: "view")
}

/*
// All messages are shown in Console, but debug and info need to be included with Action menu
// info and debug are colored as gray (info) and black (debug) type in Console
Logger.model.info(#function)
Logger.model.debug("Some debug")

// log and notice are same and is the default log type, they are not colored as type in Console
Logger.model.log("Some log")
Logger.model.notice("Some notice")

 // error is colored as yellow type in Console
 Logger.model.error("Some error")

// critical and fault end up both as fault type in Console colored as red
Logger.model.critical("Some critical")
Logger.model.fault("Some fault")

// => use info and debug for debugging purposes with debugging as lower level detail than info
// => use log for general high-level stuff (not debugging)
// => use error for errors that can typically be recovered
// => use fault for critical or bug event

Also take following into account:
default: The default log types are usually used in logging standard messages. The messages are stored in memory. Once the memory reaches the limit, the messages get compressed and moved to disk.
debug: Use this log type for logging information that will help in troubleshooting. The messages are stored in memory. Once the memory reaches the limit, the messages get compressed and moved to disk. The messages will not be shown without configuration.
info: Use info log type for logging informative messages such as “100 records got downloaded from server”. The messages are stored in memory. Once the memory reaches the limit, the messages get purged.
error: Use error log type for logging errors in your process. The messages are always stored on disk. Once it reaches the limit, the oldest messages get purged.
fault: Use fault log type for logging messages related to system issues such as “lost internet connectivity”. They are always stored on disk. Once it reaches the limit, the oldest messages get purged.
*/
