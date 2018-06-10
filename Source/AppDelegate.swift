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
            fatal("Unable to get Connection Name from Info dictionary!")
        }
        guard let bundleId = Bundle.main.bundleIdentifier else {
            fatal("Unable to obtain bundle identifier!")
        }
        guard let server = IMKServer(name: connectionName, bundleIdentifier: bundleId) else {
            fatal("Unable to init IMKServer for connection name: \(connectionName) and bundle id: \(bundleId)")
        }
        self.server = server
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        server.commitEditing()
    }
}
