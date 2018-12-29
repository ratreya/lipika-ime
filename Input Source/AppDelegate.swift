/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import InputMethodKit
import LipikaEngine_OSX

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private (set) var server: IMKServer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let connectionName = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String else {
            fatalError("Unable to get Connection Name from Info dictionary!")
        }
        guard let bundleId = Bundle.main.bundleIdentifier else {
            fatalError("Unable to obtain bundle identifier!")
        }
        guard let server = IMKServer(name: connectionName, bundleIdentifier: bundleId) else {
            fatalError("Unable to init IMKServer for connection name: \(connectionName) and bundle id: \(bundleId)")
        }
        Logger.log.debug("Initialized IMK Server: \(server.bundle().bundleIdentifier ?? "nil")")
        self.server = server
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Logger.log.debug("Comitting all editing before terminating")
        server.commitComposition(self)
    }
}
