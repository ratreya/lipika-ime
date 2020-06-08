/*
 * LipikaApp is companion application for LipikaIME.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    /* Disabling this until all of SwiftUI is ready for launch
        // Create the SwiftUI view that provides the window contents.
        let contentView = MainView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 580),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("LipikaIME")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    */
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
