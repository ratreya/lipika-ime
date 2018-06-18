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

class ClientManager: CustomStringConvertible {
    private let currentPosition = NSMakeRange(NSNotFound, NSNotFound)
    private let config = LipikaConfig()
    private let client: IMKTextInput
    private let candidatesWindow: IMKCandidates
    private (set) var candidates = [String]()
    // Cache, otherwise clients quitting can sometimes SEGFAULT us
    var _description: String
    var description: String {
        return _description
    }

    private var attributes: [NSAttributedStringKey: Any]! {
        var rect = NSMakeRect(0, 0, 0, 0)
        return client.attributes(forCharacterIndex: 0, lineHeightRectangle: &rect) as! [NSAttributedStringKey : Any]
    }
    
    init(client: IMKTextInput) {
        Logger.log.debug("Initializing client: \(client.bundleIdentifier()) with Id: \(client.uniqueClientIdentifierString())")
        self.client = client
        if !client.supportsUnicode() {
            Logger.log.warning("Client: \(client.bundleIdentifier()) does not support Unicode!")
        }
        if !client.supportsProperty(TSMDocumentPropertyTag(kTSMDocumentSupportDocumentAccessPropertyTag)) {
            Logger.log.warning("Client: \(client.bundleIdentifier()) does not support Document Access!")
        }
        candidatesWindow = IMKCandidates(server: (NSApp.delegate as! AppDelegate).server, panelType: kIMKSingleRowSteppingCandidatePanel)
        _description = "\(client.bundleIdentifier()) with Id: \(client.uniqueClientIdentifierString())"
    }
    
    func showActive(clientText: NSAttributedString, candidateText: String, replacementRange: NSRange? = nil) {
        Logger.log.debug("Showing clientText: \(clientText) and candidateText: \(candidateText)")
        client.setMarkedText(clientText, selectionRange: NSMakeRange(clientText.length, 0), replacementRange: replacementRange ?? currentPosition)
        candidates = [candidateText]
        candidatesWindow.update()
        if !config.hideCandidate {
            candidatesWindow.show()
        }
    }
    
    func finalize(_ output: String) {
        Logger.log.debug("Finalizing with: \(output)")
        client.insertText(output, replacementRange: currentPosition)
        candidatesWindow.hide()
    }
    
    func clear() {
        Logger.log.debug("Clearing MarkedText and Candidate window")
        client.setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: currentPosition)
        candidatesWindow.hide()
    }
    
    func findWord(at current: Int) -> NSRange? {
        let maxLength = client.length()
        var exponent = 2
        var wordStart = -1, wordEnd = -1
        Logger.log.debug("Finding word at: \(current) with max: \(maxLength)")
        repeat {
            let low = wordStart == -1 ? max(current - 2 << exponent, 0): wordStart
            let high = wordEnd == -1 ? min(current + 2 << exponent, maxLength): wordEnd
            Logger.log.debug("Looking for word between \(low) and \(high)")
            var real = NSRange()
            guard let text = client.string(from: NSMakeRange(low, high - low), actualRange: &real) else { return nil }
            Logger.log.debug("Looking for word in text: \(text)")
            if wordStart == -1, let startOffset = text.unicodeScalars[text.unicodeScalars.startIndex..<text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - real.location)].reversed().index(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.base.encodedOffset {
                wordStart = real.location + startOffset
                Logger.log.debug("Found wordStart: \(wordStart)")
            }
            if wordEnd == -1, let endOffset = text.unicodeScalars[text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - real.location)..<text.unicodeScalars.endIndex].index(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.encodedOffset {
                wordEnd = real.location + endOffset
                Logger.log.debug("Found wordEnd: \(wordEnd)")
            }
            exponent += 1
            if wordStart == -1, low == 0 {
                wordStart = low
                Logger.log.debug("Starting word at beginning of document")
            }
            if wordEnd == -1, high == maxLength {
                wordEnd = high
                Logger.log.debug("Ending word at end of document")
            }
        }
        while(wordStart == -1 || wordEnd == -1)
        Logger.log.debug("Found word between \(wordStart) and \(wordEnd)")
        return NSMakeRange(wordStart, wordEnd - wordStart)
    }
}
