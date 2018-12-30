/*
 * LipikaApp is companion application for LipikaIME.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func showUserGroup(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "http://facebook.com/groups/lipika.ime")!)
    }
    
    @IBAction func showReleaseNotes(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/ratreya/lipika-ime/releases")!)
    }
    
    @IBAction func reportIssue(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/ratreya/lipika-ime/issues/new")!)
    }
}
