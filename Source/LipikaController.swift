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

@objc(LipikaController)
public class LipikaController: IMKInputController {
    private let client: ClientManaager
    private (set) var systemTrayMenu: NSMenu
    private (set) var transliterator: Transliterator
    private (set) var anteliterator: Anteliterator

    private func commit() {
        if let text = transliterator.reset() {
            client.finalize(text.finalaizedOutput + text.unfinalaizedOutput)
        }
        else {
            client.clear()
        }
    }
    
    public override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // Initialize Literators
        let config = LipikaConfig()
        let factory = try! LiteratorFactory(config: config)
        if let customSchemeName = config.customSchemeName {
            transliterator = try! factory.transliterator(customMapping: customSchemeName)
            anteliterator = try! factory.anteliterator(customMapping: customSchemeName)
        }
        else {
            transliterator = try! factory.transliterator(schemeName: config.schemeName, scriptName: config.scriptName)
            anteliterator = try! factory.anteliterator(schemeName: config.schemeName, scriptName: config.scriptName)
        }
        // Setup the System Tray Menu
        self.systemTrayMenu = NSMenu(title: "LipikaIME")
        var indent = 0
        let customSchemes = try! factory.availableCustomMappings()
        if !customSchemes.isEmpty {
            Logger.log.debug("Adding Custom Schemes to Menu: \(customSchemes)")
            indent = 1
            let customTitle = NSMenuItem(title: "Custom Schemes", action: nil, keyEquivalent: "")
            customTitle.isEnabled = false
            for customScheme in customSchemes {
                let item = NSMenuItem(title: customScheme, action: #selector(menuItemSelected), keyEquivalent: "")
                if customScheme == config.customSchemeName {
                    item.state = .on
                }
                item.indentationLevel = indent
                item.tag = 0
                systemTrayMenu.addItem(item)
            }
            systemTrayMenu.addItem(NSMenuItem.separator())
            let installedTitle = NSMenuItem(title: "Installed Scripts", action: nil, keyEquivalent: "")
            installedTitle.isEnabled = false
            systemTrayMenu.addItem(installedTitle)
        }
        if !config.enabledScripts.isEmpty {
            Logger.log.debug("Adding Installed Scripts to Menu: \(config.enabledScripts)")
            for script in config.enabledScripts {
                let item = NSMenuItem(title: script, action: #selector(menuItemSelected), keyEquivalent: "")
                if config.customSchemeName == nil, script == config.scriptName {
                    item.state = .on
                }
                item.indentationLevel = indent
                item.tag = 1
                systemTrayMenu.addItem(item)
            }
        }
        client = ClientManaager(client: inputClient as! IMKTextInput)
        super.init(server: server, delegate: delegate, client: inputClient)
        Logger.log.debug("Initialized Controller for Client: \(client)")
    }
    
    public override func inputText(_ input: String!, client sender: Any!) -> Bool {
        Logger.log.debug("Processing Input: \(input)")
        if input.unicodeScalars.count != 1 || CharacterSet.whitespacesAndNewlines.contains(input.unicodeScalars.first!) {
            Logger.log.debug("Input triggered a commit; not handling the input")
            commit()
            return false
        }
        let literated = transliterator.transliterate(input)
        client.showActive(literated)
        return true
    }
    
    public override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
        if aSelector == #selector(NSResponder.deleteBackward) {
            Logger.log.debug("Processing deleteBackward")
            if let result = transliterator.delete() {
                Logger.log.debug("Resulted in an actual delete")
                client.showActive(result)
                return true
            }
            Logger.log.debug("Nothing to delete")
        }
        else if aSelector == #selector(NSResponder.cancelOperation) {
            Logger.log.debug("Processing cancelOperation")
            let result = transliterator.reset()
            client.clear()
            Logger.log.debug("Handled the cancel: \(result != nil)")
            return result != nil
        }
        else {
            Logger.log.debug("Comitting due to unhandled selector: \(aSelector)")
            commit()
        }
        return false
    }
    
    /// This message is sent when our client looses focus
    public override func deactivateServer(_ sender: Any!) {
        Logger.log.debug("Client: \(client) loosing focus")
        commit()
    }
    
    public override func menu() -> NSMenu! {
        Logger.log.debug("Returning menu")
        return systemTrayMenu
    }
    
    public override func candidates(_ sender: Any!) -> [Any]! {
        Logger.log.debug("Returning Candidates")
        return client.candidates
    }
    
    public override func candidateSelected(_ candidateString: NSAttributedString!) {
        Logger.log.debug("Candidate selected: \(candidateString)")
        commit()
    }
    
    public override func commitComposition(_ sender: Any!) {
        Logger.log.debug("Commit Composition called by \(sender)")
        commit()
    }
    
    @objc public func menuItemSelected(sender: NSDictionary) {
        let item = sender.value(forKey: kIMKCommandMenuItemName) as! NSMenuItem
        Logger.log.debug("Menu Item Selected: \(item.title)")
        item.menu?.items.forEach() { $0.state = .off }
        item.state = .on
        let config = LipikaConfig()
        let factory = try! LiteratorFactory(config: config)
        if item.tag == 0 {
            Logger.log.debug("Selected Menu Item is Custom Scheme")
            transliterator = try! factory.transliterator(customMapping: item.title)
            anteliterator = try! factory.anteliterator(customMapping: item.title)
            config.customSchemeName = item.title
        }
        else {
            Logger.log.debug("Selected Menu Item is Installed Script; Loading schemeName: \(config.schemeName) and scriptName: \(item.title)")
            transliterator = try! factory.transliterator(schemeName: config.schemeName, scriptName: item.title)
            anteliterator = try! factory.anteliterator(schemeName: config.schemeName, scriptName: item.title)
            config.scriptName = item.title
        }
    }
}
