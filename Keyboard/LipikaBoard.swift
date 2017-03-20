/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

class LipikaBoard: KeyboardViewController {

    var manager: DJStringBufferManager = DJStringBufferManager()
    var tempTextLength: String.IndexDistance = 0

    override func keyPressed(_ key: Key) {
        let keyInput = key.outputForCase(self.shiftState.uppercase())
        let preContext = textDocumentProxy.documentContextBeforeInput
        
        // Compute previous text if any
        var previousText: String?
        if DJLipikaUserSettings.isCombineWithPreviousGlyph(), let context = preContext {
            let offset = -1 * String.IndexDistance(manager.maxOutputLength())
            if let index = context.index(context.endIndex, offsetBy: offset, limitedBy: context.startIndex) {
                previousText = context.substring(from: index)
            }
            else {
                previousText = context
            }
        }

        clearTempText()
        if let keyOutput = manager.output(forInput: keyInput, previousText: previousText) {
            textDocumentProxy.insertText(keyOutput)
        }
        else if manager.hasOutput() {
            let output = manager.output()!
            textDocumentProxy.insertText(output)
            tempTextLength = output.distance(from: output.startIndex, to: output.endIndex)
        }
    }
    
    private func clearTempText() {
        while tempTextLength > 0 {
            textDocumentProxy.deleteBackward()
            tempTextLength -= 1
        }
    }
}
