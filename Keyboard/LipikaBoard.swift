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

    var manager = DJStringBufferManager()
    var tempTextLength: String.IndexDistance = 0
    var banner: LipikaBanner?

    override func createBanner() -> ExtraView? {
        banner = LipikaBanner(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode(), inputManager: manager)
        return banner
    }

    override func keyPressed(_ key: Key) {
        let keyInput = key.outputForCase(self.shiftState.uppercase())
        clearTempText()
        var previousText: String?
        if DJLipikaUserSettings.isCombineWithPreviousGlyph() {
            previousText = getPreviousText()
        }
        if let keyOutput = manager.output(forInput: keyInput, previousText: previousText) {
            textDocumentProxy.insertText(keyOutput)
        }
        else {
            showTempText()
        }
    }
    
    override func deleteBackward() {
        if DJLipikaUserSettings.backspaceBehavior() == DJ_DELETE_OUTPUT {
            flushTempText()
            super.deleteBackward()
            return
        }
        if !manager.hasDeletable() {
            // We have to convert previous text to temp text
            if let previousText = getPreviousText() {
                if manager.reverseMappings().input(forOutput: previousText) == nil {
                    super.deleteBackward()
                    preloadPreviousText()
                    return
                }
                else {
                    manager.output(forInput: "", previousText: previousText)
                    tempTextLength = manager.output().utf16.count
                }
            }
            else {
                super.deleteBackward()
                return
            }
        }
        // At this point it is always deletable
        manager.delete()
        clearTempText()
        showTempText()
        // Pre-load temporary text if any
        preloadPreviousText()
    }
 
    override func textWillChange(_ textInput: UITextInput?) {
        /*
         * Usually indicates some user action outside keypress
         * We will get out of synch and so must flush to be safe
         */
        flushTempText()
    }

    private func getPreviousText() -> String? {
        if let context = textDocumentProxy.documentContextBeforeInput {
            let offset = -1 * String.IndexDistance(manager.maxOutputLength())
            let startIndex = context.index(context.endIndex, offsetBy: offset, limitedBy: context.startIndex)
            return context.substring(from: startIndex ?? context.startIndex)
        }
        return nil
    }
    
    private func preloadPreviousText() {
        if !manager.hasDeletable(), let previousText = getPreviousText(),
            (manager.reverseMappings().input(forOutput: previousText) != nil) {
            manager.output(forInput: "", previousText: previousText)
            tempTextLength = manager.output().utf16.count
            banner?.setTempInput(input: manager.input())
        }
    }

    private func flushTempText() {
        manager.flush()
        tempTextLength = 0
        banner!.setTempInput(input: "")
    }

    private func showTempText() {
        if manager.hasOutput(), let output = manager.output() {
            textDocumentProxy.insertText(output)
            tempTextLength += output.utf16.count
        }
        if let input = manager.input() {
            banner!.setTempInput(input: input)
        }
    }

    private func clearTempText() {
        while tempTextLength > 0 {
            textDocumentProxy.deleteBackward()
            tempTextLength -= 1
        }
        banner!.setTempInput(input: "")
    }
}
