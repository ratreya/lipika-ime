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
    private let notFoundRange = NSMakeRange(NSNotFound, NSNotFound)
    private let config = LipikaConfig()
    private let client: IMKTextInput
    // This is the position of the cursor within the marked text
    public var markedCursorLocation: Int? = nil
    private var candidatesWindow: IMKCandidates { return (NSApp.delegate as! AppDelegate).candidatesWindow }
    private (set) var candidates = autoreleasepool { return [String]() }
    // Cache, otherwise clients quitting can sometimes SEGFAULT us
    private var _description: String
    var description: String {
        return _description
    }

    private var attributes: [NSAttributedString.Key: Any]! {
        var rect = NSMakeRect(0, 0, 0, 0)
        return client.attributes(forCharacterIndex: 0, lineHeightRectangle: &rect) as? [NSAttributedString.Key : Any]
    }
    
    init?(client: IMKTextInput) {
        guard let bundleId = client.bundleIdentifier(), let clientId = client.uniqueClientIdentifierString() else {
            Logger.log.warning("bundleIdentifier: \(client.bundleIdentifier() ?? "nil") or uniqueClientIdentifierString: \(client.uniqueClientIdentifierString() ?? "nil") - failing ClientManager.init()")
            return nil
        }
        Logger.log.debug("Initializing client: \(bundleId) with Id: \(clientId)")
        self.client = client
        if !client.supportsUnicode() {
            Logger.log.warning("Client: \(bundleId) does not support Unicode!")
        }
        if !client.supportsProperty(TSMDocumentPropertyTag(kTSMDocumentSupportDocumentAccessPropertyTag)) {
            Logger.log.warning("Client: \(bundleId) does not support Document Access!")
        }
        _description = "\(bundleId) with Id: \(clientId)"
    }
    
    func setGlobalCursorLocation(_ location: Int) {
        Logger.log.debug("Setting global cursor location to: \(location)")
        client.setMarkedText("|", selectionRange: NSMakeRange(0, 0), replacementRange: NSMakeRange(location, 0))
        client.setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: NSMakeRange(location, 0))
    }
    
    func updateMarkedCursorLocation(_ delta: Int) -> Bool {
        Logger.log.debug("Cursor moved: \(delta) with selectedRange: \(client.selectedRange()), markedRange: \(client.markedRange()) and cursorPosition: \(markedCursorLocation?.description ?? "nil")")
        if client.markedRange().length == NSNotFound { return false }
        let nextPosition = (markedCursorLocation ?? client.markedRange().length) + delta
        if (0...client.markedRange().length).contains(nextPosition) {
            Logger.log.debug("Still within markedRange")
            markedCursorLocation = nextPosition
            return true
        }
        Logger.log.debug("Outside of markedRange")
        markedCursorLocation = nil
        return false
    }
    
    func showActive(clientText: NSAttributedString, candidateText: String, replacementRange: NSRange? = nil) {
        Logger.log.debug("Showing clientText: \(clientText) and candidateText: \(candidateText)")
        client.setMarkedText(clientText, selectionRange: NSMakeRange(markedCursorLocation ?? clientText.length, 0), replacementRange: replacementRange ?? notFoundRange)
        candidates = [candidateText]
        if clientText.string.isEmpty {
            candidatesWindow.hide()
        }
        else {
            candidatesWindow.update()
            if config.showCandidates {
                candidatesWindow.show()
            }
        }
    }
    
    func finalize(_ output: String) {
        Logger.log.debug("Finalizing with: \(output)")
        client.insertText(output, replacementRange: notFoundRange)
        candidatesWindow.hide()
        markedCursorLocation = nil
    }
    
    func clear() {
        Logger.log.debug("Clearing MarkedText and Candidate window")
        client.setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: notFoundRange)
        candidatesWindow.hide()
        markedCursorLocation = nil
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
            if wordStart == -1, let startOffset = text.unicodeScalars[text.unicodeScalars.startIndex..<text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - real.location)].reversed().firstIndex(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.base.utf16Offset(in: text) {
                wordStart = real.location + startOffset
                Logger.log.debug("Found wordStart: \(wordStart)")
            }
            if wordEnd == -1, let endOffset = text.unicodeScalars[text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - real.location)..<text.unicodeScalars.endIndex].firstIndex(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.utf16Offset(in: text) {
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
