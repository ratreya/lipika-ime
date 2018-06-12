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
    private var _transliteratorKey: Int?
    private var _transliterator: Transliterator?
    private var transliterator: Transliterator { return _transliterator! }
    private let client: ClientManaager
    
    private func refreshTransliterator() {
        let config = LipikaConfig()
        do {
            let factory = try LiteratorFactory(config: config)
            if let customSchemeName = config.customSchemeName {
                let key = "customMapping: \(customSchemeName)".hashValue
                if key != _transliteratorKey {
                    _transliterator = try factory.transliterator(customMapping: customSchemeName)
                    _transliteratorKey = key
                }
            }
            else {
                let key = "schemeName: \(config.schemeName); scriptName: \(config.scriptName)".hashValue
                if key != _transliteratorKey {
                    _transliterator = try factory.transliterator(schemeName: config.schemeName, scriptName: config.scriptName)
                    _transliteratorKey = key
                }
            }
        }
        catch {
            fatal(error.localizedDescription)
        }
    }
    
    private func commit() {
        if let text = transliterator.reset() {
            client.finalize(text.finalaizedOutput + text.unfinalaizedOutput)
        }
        else {
            client.clear()
        }
    }
    
    public override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        client = ClientManaager(client: inputClient as! IMKTextInput)
        super.init(server: server, delegate: delegate, client: inputClient)
        refreshTransliterator()
    }
    
    public override func inputText(_ input: String!, client sender: Any!) -> Bool {
        if input.unicodeScalars.count != 1 || CharacterSet.whitespacesAndNewlines.contains(input.unicodeScalars.first!) {
            commit()
            return false
        }
        let literated = transliterator.transliterate(input)
        client.showActive(literated)
        return true
    }
    
    public override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
        if aSelector == #selector(NSResponder.deleteBackward) {
            if let result = transliterator.delete() {
                client.showActive(result)
                return true
            }
            return false
        }
        else if aSelector == #selector(NSResponder.cancelOperation) {
            let result = transliterator.reset()
            client.clear()
            return result != nil
        }
        client().length()
        return false
    }
    
    /// This message is sent when our client gains focus
    public override func activateServer(_ sender: Any!) {
        // Do this in case the user changed the scheme or script on the other window
        refreshTransliterator()
    }
    
    /// This message is sent when our client looses focus
    public override func deactivateServer(_ sender: Any!) {
        commit()
    }
    
    public override func menu() -> NSMenu! {
        let menu = NSMenu(title: "LipikaIME")
        let config = LipikaConfig()
        guard let factory = try? LiteratorFactory(config: config) else { return menu }
        var indent = 0
        if let customSchemes = try? factory.availableCustomMappings(), !customSchemes.isEmpty {
            indent = 1
            let customTitle = NSMenuItem(title: "Custom Schemes", action: nil, keyEquivalent: "")
            customTitle.isEnabled = false
            for customScheme in customSchemes {
                let item = NSMenuItem(title: customScheme, action: #selector(customSchemeSelected), keyEquivalent: "")
                item.indentationLevel = indent
                menu.addItem(item)
            }
            menu.addItem(NSMenuItem.separator())
            let installedTitle = NSMenuItem(title: "Installed Scripts", action: nil, keyEquivalent: "")
            installedTitle.isEnabled = false
            menu.addItem(installedTitle)
        }
        if !config.enabledScripts.isEmpty {
            for script in config.enabledScripts {
                let item = NSMenuItem(title: script, action: #selector(installedScriptSelected), keyEquivalent: "")
                item.indentationLevel = indent
                menu.addItem(item)
            }
        }
        return menu
    }
    
    public override func candidates(_ sender: Any!) -> [Any]! {
        return client.candidates
    }
    
    public override func candidateSelected(_ candidateString: NSAttributedString!) {
        commit()
    }
    
    public override func commitComposition(_ sender: Any!) {
        commit()
    }
    
    @objc public func customSchemeSelected(sender: NSMenuItem) {
        LipikaConfig().customSchemeName = sender.title
        refreshTransliterator()
    }
    
    @objc public func installedScriptSelected(sender: NSMenuItem) {
        LipikaConfig().scriptName = sender.title
        refreshTransliterator()
    }
}
