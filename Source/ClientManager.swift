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

class ClientManaager {
    private let currentPosition = NSMakeRange(NSNotFound, NSNotFound)
    private let config = LipikaConfig()
    private let client: IMKTextInput
    private let candidatesWindow: IMKCandidates
    private (set) var candidates = [String]()
    
    private var attributes: [NSAttributedStringKey: Any]! {
        var rect = NSMakeRect(0, 0, 0, 0)
        return client.attributes(forCharacterIndex: 0, lineHeightRectangle: &rect) as! [NSAttributedStringKey : Any]
    }
    
    init(client: IMKTextInput) {
        self.client = client
        if !client.supportsUnicode() {
            Logger.log.warning("Client: \(client.bundleIdentifier()) does not support Unicode!")
        }
        if client.supportsProperty(TSMDocumentPropertyTag(kTSMDocumentSupportDocumentAccessPropertyTag)) {
            Logger.log.warning("Client: \(client.bundleIdentifier()) does not support Document Access!")
        }
        candidatesWindow = IMKCandidates(server: (NSApp.delegate as! AppDelegate).server, panelType: kIMKScrollingGridCandidatePanel)
    }
    
    func showActive(_ literated: Literated) {
        var clientText: NSAttributedString
        var candidateText: String
        var unfinalizedRange: NSRange
        if config.outputInClient {
            unfinalizedRange = NSMakeRange(literated.finalaizedOutput.unicodeScalars.count, literated.unfinalaizedOutput.unicodeScalars.count)
            clientText = NSAttributedString(string: literated.finalaizedOutput + literated.unfinalaizedOutput, attributes: attributes)
            candidateText = literated.finalaizedInput + literated.unfinalaizedInput
        }
        else {
            unfinalizedRange = NSMakeRange(literated.finalaizedInput.unicodeScalars.count, literated.unfinalaizedInput.unicodeScalars.count)
            clientText = NSAttributedString(string: literated.finalaizedInput + literated.unfinalaizedInput, attributes: attributes)
            candidateText = literated.finalaizedOutput + literated.unfinalaizedOutput
        }
        client.setMarkedText(clientText, selectionRange: unfinalizedRange, replacementRange: currentPosition)
        candidates = [candidateText]
        candidatesWindow.update()
        if !config.hideCandidate {
            candidatesWindow.show()
        }
    }
    
    func finalize(_ output: String) {
        client.insertText(output, replacementRange: currentPosition)
        candidatesWindow.hide()
    }
    
    func clear() {
        client.setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: currentPosition)
        candidatesWindow.hide()
    }
    
    func findWord(at current: Int) -> (start: Int, end: Int)? {
        let maxLength = client.length()
        var exponent = 2
        var wordStart = -1, wordEnd = -1
        repeat {
            let low = wordStart == -1 ? max(current - 2^exponent, 0): wordStart
            let high = wordEnd == -1 ? min(current + 2^exponent, maxLength): wordEnd
            var real = NSRange()
            guard let text = client.string(from: NSMakeRange(low, high - low), actualRange: &real) else { return nil }
            if wordStart == -1, let startOffset = text.unicodeScalars[text.unicodeScalars.startIndex...text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - low)].reversed().index(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.base.encodedOffset {
                wordStart = low + startOffset
            }
            if wordEnd == -1, let endOffset = text.unicodeScalars[text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: current - low + 1)...text.unicodeScalars.endIndex].index(where: { CharacterSet.whitespacesAndNewlines.contains($0) })?.encodedOffset {
                wordEnd = low + endOffset
            }
            exponent += 1
            if wordStart == -1, low == 0 { wordStart = low }
            if wordEnd == -1, high == maxLength { wordEnd = high }
        }
        while(wordStart == -1 || wordEnd == -1)
        return (wordStart, wordEnd)
    }
}
