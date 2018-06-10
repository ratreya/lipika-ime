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
    
    override public init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        client = ClientManaager(client: inputClient as! IMKTextInput)
        super.init(server: server, delegate: delegate, client: inputClient)
        refreshTransliterator()
    }
    
    override public func inputText(_ input: String!, client sender: Any!) -> Bool {
        if input.unicodeScalars.count != 1 || CharacterSet.whitespacesAndNewlines.contains(input.unicodeScalars.first!) {
            commit()
            return false
        }
        let literated = transliterator.transliterate(input)
        client.showActive(literated)
        return true
    }
    
    override public func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
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
    override public func activateServer(_ sender: Any!) {
        // Do this in case the user changed the scheme or script on the other window
        refreshTransliterator()
    }
    
    /// This message is sent when our client looses focus
    override public func deactivateServer(_ sender: Any!) {
        commit()
    }
    
    override public func menu() -> NSMenu! {
        let menu = NSMenu(title: "LipikaIME")
        return menu
    }
    
    override public func candidates(_ sender: Any!) -> [Any]! {
        return client.candidates
    }
    
    override public func candidateSelected(_ candidateString: NSAttributedString!) {
        commit()
    }
    
    override public func commitComposition(_ sender: Any!) {
        commit()
    }
}
