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
    let config = LipikaConfig()
    private let clientManager: ClientManager
    private (set) var systemTrayMenu: NSMenu!
    private var literatorHash = 0
    private (set) var transliterator: Transliterator!
    private (set) var anteliterator: Anteliterator!
    
    private func refreshMenu() {
        self.systemTrayMenu = NSMenu(title: "LipikaIME")
        var indent = 0
        let customSchemes = try! LiteratorFactory(config: config).availableCustomMappings()
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
            Logger.log.debug("Adding Installed Scripts to Menu")
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
    }
    
    private func refreshLiterators() -> Bool {
        let factory = try! LiteratorFactory(config: config)
        if let customSchemeName = config.customSchemeName {
            let hashValue = "customMapping: \(customSchemeName)".hashValue
            if hashValue != literatorHash {
                Logger.log.debug("Refreshing Literators with customMapping: \(customSchemeName)")
                transliterator = try! factory.transliterator(customMapping: customSchemeName)
                anteliterator = try! factory.anteliterator(customMapping: customSchemeName)
                literatorHash = hashValue
                return true
            }
        }
        else {
            let hashValue = "schemeName: \(config.schemeName) and scriptName: \(config.scriptName)".hashValue
            if hashValue != literatorHash {
                Logger.log.debug("Refreshing Literators with schemeName: \(config.schemeName) and scriptName: \(config.scriptName)")
                transliterator = try! factory.transliterator(schemeName: config.schemeName, scriptName: config.scriptName)
                anteliterator = try! factory.anteliterator(schemeName: config.schemeName, scriptName: config.scriptName)
                literatorHash = hashValue
                return true
            }
        }
        return false
    }
    
    private func commit() {
        if let text = transliterator.reset() {
            Logger.log.debug("Committing with text: \(text)")
            clientManager.finalize(text.finalaizedOutput + text.unfinalaizedOutput)
        }
        else {
            Logger.log.debug("Nothing to commit")
            clientManager.clear()
        }
    }

    private func showActive(_ literated: Literated, replacementRange: NSRange? = nil) {
        if config.outputInClient {
            let attributes = mark(forStyle: kTSMHiliteConvertedText, at: replacementRange ?? client().selectedRange()) as! [NSAttributedStringKey : Any]
            let clientText = NSMutableAttributedString(string: literated.finalaizedOutput + literated.unfinalaizedOutput)
            clientText.addAttributes(attributes, range: NSMakeRange(0, clientText.length))
            clientManager.showActive(clientText: clientText, candidateText: literated.finalaizedInput + literated.unfinalaizedInput, replacementRange: replacementRange)
        }
        else {
            let attributes = mark(forStyle: kTSMHiliteSelectedRawText, at: replacementRange ?? client().selectedRange()) as! [NSAttributedStringKey : Any]
            let clientText = NSMutableAttributedString(string: literated.finalaizedInput + literated.unfinalaizedInput)
            clientText.addAttributes(attributes, range: NSMakeRange(0, clientText.length))
            clientManager.showActive(clientText: clientText, candidateText: literated.finalaizedOutput + literated.unfinalaizedOutput, replacementRange: replacementRange)
        }
    }
    
    private func moveCursorWithinMarkedText(delta: Int) -> Bool {
        if transliterator.isEmpty() {
            Logger.log.debug("Transliterator is empty, not handling cursor move")
        }
        else if clientManager.updateMarkedCursorLocation(delta) {
            showActive(transliterator.transliterate())
            return true
        }
        else {
            commit()
        }
        return false
    }
    
    private func convertWord(at location: Int) {
        if let wordRange = self.clientManager.findWord(at: location), wordRange.length > 0 {
            var actual = NSRange()
            guard let word = self.client().string(from: wordRange, actualRange: &actual), !word.isEmpty else {
                return
            }
            Logger.log.debug("Found word: \(word) at: \(actual)")
            let inputs = self.anteliterator.anteliterate(word)
            let literated = self.transliterator.transliterate(inputs)
            // Calculate the location of cursor within Marked Text
            self.clientManager.markedCursorLocation = transliterator.findPosition(forPosition: location - actual.location, inOutput: true)
            Logger.log.debug("Marked Cursor Location: \(self.clientManager.markedCursorLocation!)  for Global Location: \(location - actual.location)")
            self.showActive(literated, replacementRange: actual)
        }
        else {
            Logger.log.debug("No word found at: \(location)")
        }
    }
    
    public override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        clientManager = ClientManager(client: inputClient as! IMKTextInput)
        super.init(server: server, delegate: delegate, client: inputClient)
        // Setup the System Tray Menu
        refreshMenu()
        // Initialize Literators
        assert(refreshLiterators())
        Logger.log.debug("Initialized Controller for Client: \(clientManager)")
    }
    
    public override func inputText(_ input: String!, client sender: Any!) -> Bool {
        Logger.log.debug("Processing Input: \(input)")
        if input.unicodeScalars.count != 1 || CharacterSet.whitespacesAndNewlines.contains(input.unicodeScalars.first!) {
            // Handle inputting of whitespace inbetween Marked Text
            if let markedLocation = clientManager.markedCursorLocation {
                Logger.log.debug("Handling whitespace being inserted inbetween Marked Text at: \(markedLocation)")
                let literated = transliterator.transliterate()
                let aggregateInputs = literated.finalaizedInput + literated.unfinalaizedInput
                let committedIndex = aggregateInputs.index(aggregateInputs.startIndex, offsetBy: markedLocation)
                _ = transliterator.reset()
                _ = transliterator.transliterate(String(aggregateInputs.prefix(upTo: committedIndex)))
                commit()
                clientManager.finalize(input)
                clientManager.markedCursorLocation = 0
                showActive(transliterator.transliterate(String(aggregateInputs.suffix(from: committedIndex))))
                return true
            }
            else {
                Logger.log.debug("Input triggered a commit; not handling the input")
                commit()
                return false
            }
        }
        if !config.noActiveSessionOnInsert, transliterator.isEmpty() {
            convertWord(at: client().selectedRange().location)
        }
        let literated = transliterator.transliterate(input, position: clientManager.markedCursorLocation)
        if clientManager.markedCursorLocation != nil {
            _ = clientManager.updateMarkedCursorLocation(1)
        }
        showActive(literated)
        return true
    }
    
    public override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
        switch aSelector {
        case #selector(NSResponder.deleteBackward):
            Logger.log.debug("Processing deleteBackward")
            if let result = transliterator.delete(position: clientManager.markedCursorLocation) {
                Logger.log.debug("Resulted in an actual delete")
                if clientManager.markedCursorLocation != nil {
                    _ = clientManager.updateMarkedCursorLocation(-1)
                }
                showActive(result)
                return true
            }
            Logger.log.debug("Nothing to delete")
            let oldLocation = client().selectedRange().location
            commit()
            if config.noActiveSessionOnDelete { return false }
            // Move the cursor back to the oldLocation because commit() would have moved it to the end of the committed string
            clientManager.setGlobalCursorLocation(oldLocation)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                let newLocation = self.client().selectedRange().location
                Logger.log.debug("oldLocation: \(oldLocation), newLocation: \(newLocation)")
                if self.transliterator.isEmpty() {
                    self.convertWord(at: newLocation)
                }
            }
        case #selector(NSResponder.cancelOperation):
            Logger.log.debug("Processing cancelOperation")
            let result = transliterator.reset()
            clientManager.clear()
            Logger.log.debug("Handled the cancel: \(result != nil)")
            return result != nil
        case #selector(NSResponder.moveLeft), #selector(NSResponder.moveRight):
            Logger.log.debug("Processing moveRight/Left")
            if moveCursorWithinMarkedText(delta: aSelector == #selector(NSResponder.moveLeft) ? -1 : 1) {
                return true
            }
            commit()
        default:
            Logger.log.debug("Not processing selector: \(aSelector)")
            commit()
        }
        return false
    }
    
    /// This message is sent when our client looses focus
    public override func deactivateServer(_ sender: Any!) {
        Logger.log.debug("Client: \(clientManager) loosing focus")
        commit()
    }
    
    /// This message is sent when our client gains focus
    public override func activateServer(_ sender: Any!) {
        Logger.log.debug("Client: \(clientManager) gained focus")
        if config.globalScriptSelection {
            // Do this in case selection was changed when we were out of focus
            if refreshLiterators() {
                systemTrayMenu.items.forEach() { $0.state = .off }
                systemTrayMenu.items.first(where: { $0.title == config.customSchemeName ?? config.scriptName } )!.state = .on
            }
        }
    }
    
    public override func menu() -> NSMenu! {
        Logger.log.debug("Returning menu")
        return systemTrayMenu
    }
    
    public override func candidates(_ sender: Any!) -> [Any]! {
        Logger.log.debug("Returning Candidates")
        return clientManager.candidates
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
