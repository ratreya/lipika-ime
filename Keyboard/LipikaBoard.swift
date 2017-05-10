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
    public private(set) lazy var manager = DJStringBufferManager()
    var tempTextLength: String.IndexDistance = 0
    var banner: LipikaBanner?
    var edgeCase = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Setup User Defaults
        LipikaBoardSettings.register()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func createBanner() -> ExtraView? {
        banner = LipikaBanner(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode(), keyboard: self)
        banner?.selectCurrentLanguage()
        return banner
    }

    override func keyPressed(_ key: Key) {
        let keyInput = key.outputForCase(self.shiftState.uppercase())
        var previousText: String?
        if DJLipikaUserSettings.isCombineWithPreviousGlyph() {
            previousText = getPreviousText()
        }
        clearTempText()
        if let keyOutput = manager.output(forInput: keyInput, previousText: previousText) {
            textDocumentProxy.insertText(keyOutput)
        }
        else {
            showTempText()
        }
    }
    
    override func deleteBackward() {
        if !UserDefaults.standard.bool(forKey: kDeleteInput) {
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
                    preloadPreviousText()
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
         *
         * The whole edgeCase dance is to avoid a bug in iOS 10.3
         * where a spurious call is made when edgeCase is true
         */
        if edgeCase {
            edgeCase = !edgeCase
        }
        else {
            flushTempText()
        }
    }

    override func selectionWillChange(_ textInput: UITextInput?) {
        /*
         * As of iOS 10.3 this is not called at all, but leaving
         * it here for future proofing
         */
        if edgeCase {
            edgeCase = !edgeCase
        }
        else {
            flushTempText()
        }
    }

    private func getPreviousText() -> String? {
        if let context = textDocumentProxy.documentContextBeforeInput {
            return String(context.unicodeScalars.suffix(Int(manager.maxOutputLength())))
        }
        return nil
    }
    
    private func preloadPreviousText() {
        if !manager.hasDeletable(), let previousText = getPreviousText(),
                (manager.reverseMappings().input(forOutput: previousText) != nil) {
            manager.output(forInput: "", previousText: previousText)
            tempTextLength = manager.output().unicodeScalars.count
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
            tempTextLength += output.unicodeScalars.count
        }
        if let input = manager.input() {
            banner!.setTempInput(input: input)
        }
    }

    private func clearTempText() {
        deleteLastCodePoints(count: tempTextLength)
        tempTextLength = 0
        banner!.setTempInput(input: "")
    }

    private func deleteLastCodePoints(count: Int) {
        /*
         * UIKeyInput deleteBackward can delete more than a Code Point based on
         * the implementation within which we are operating. So check as you go
         */
        var toDeleteCount = count
        while toDeleteCount > 0 {
            if let context = textDocumentProxy.documentContextBeforeInput {
                let beforeCount = context.unicodeScalars.count
                // Assuming at most one character is deleted
                let before = String(context.characters.suffix(2))
                textDocumentProxy.deleteBackward()
                if let context = textDocumentProxy.documentContextBeforeInput {
                    let afterCount = context.unicodeScalars.count
                    let deletedCount = beforeCount - afterCount
                    toDeleteCount -= deletedCount
                    if toDeleteCount < 0 {
                        let extraCount = abs(toDeleteCount)
                        let extra = String(before.unicodeScalars.suffix(deletedCount).prefix(extraCount))
                        textDocumentProxy.insertText(extra)
                        break;
                    }
                }
                else {
                    edgeCase = true
                }
            }
            else {
                // Nothing to delete
                break
            }
        }
    }
}
