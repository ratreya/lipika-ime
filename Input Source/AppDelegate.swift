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
    private (set) var candidatesWindow: IMKCandidates!
    private (set) var systemTrayMenu: NSMenu!
    
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
        systemTrayMenu = autoreleasepool { return createSystemTrayMenu() }
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel)
        candidatesWindow.setAttributes([IMKCandidatesSendServerKeyEventFirst: NSNumber(booleanLiteral: true)])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Logger.log.debug("Comitting all editing before terminating")
        server.commitComposition(self)
    }
    
    private func createSystemTrayMenu() -> NSMenu {
        let config = LipikaConfig()
        let systemTrayMenu = NSMenu(title: "LipikaIME")
        let customSchemes = try! LiteratorFactory(config: config).availableCustomMappings()
        if !customSchemes.isEmpty {
            Logger.log.debug("Adding Custom Schemes to Menu: \(customSchemes)")
            let customTitle = NSMenuItem(title: "Custom Schemes", action: nil, keyEquivalent: "")
            customTitle.isEnabled = false
            systemTrayMenu.addItem(customTitle)
            for customScheme in customSchemes {
                let item = NSMenuItem(title: customScheme, action: #selector(LipikaController.menuItemSelected), keyEquivalent: "")
                if customScheme == config.customSchemeName {
                    item.state = .on
                }
                item.tag = 0
                systemTrayMenu.addItem(item)
            }
            systemTrayMenu.addItem(NSMenuItem.separator())
            let installedTitle = NSMenuItem(title: "Installed Scripts", action: nil, keyEquivalent: "")
            installedTitle.isEnabled = false
            systemTrayMenu.addItem(installedTitle)
        }
        if !config.enabledScripts.isEmpty {
            Logger.log.debug("Adding Installed Scripts to Menu")
            for script in config.enabledScripts {
                let item = NSMenuItem(title: script, action: #selector(LipikaController.menuItemSelected), keyEquivalent: "")
                if config.customSchemeName == nil, script == config.scriptName {
                    item.state = .on
                }
                item.tag = 1
                systemTrayMenu.addItem(item)
            }
        }
        return systemTrayMenu
    }
}
