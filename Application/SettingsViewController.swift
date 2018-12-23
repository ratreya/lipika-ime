/*
 * LipikaApp is companion application for LipikaIME.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa
import LipikaEngine_OSX

class SettingsViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var schemeName: NSPopUpButton!
    @IBOutlet weak var logLevel: NSPopUpButton!
    @IBOutlet weak var stopCharacter: NSTextField!
    @IBOutlet weak var escapeCharacter: NSTextField!
    @IBOutlet weak var showCandidates: NSButton!
    @IBOutlet weak var outputInClient: NSPopUpButton!
    @IBOutlet weak var globalScriptSelection: NSButton!
    @IBOutlet weak var activeSessionOnDelete: NSButton!
    @IBOutlet weak var activeSessionOnInsert: NSButton!
    @IBOutlet weak var activeSessionOnCursorMove: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    
    private let config = LipikaConfig()
    
    private func reset() {
        let factory = try! LiteratorFactory(config: config)
        schemeName.addItems(withTitles: try! factory.availableSchemes())
        schemeName.selectItem(withTitle: config.schemeName)
        logLevel.addItems(withTitles: [Level.debug.rawValue, Level.warning.rawValue, Level.error.rawValue, Level.fatal.rawValue])
        logLevel.selectItem(withTitle: config.logLevel.rawValue)
        stopCharacter.stringValue = String(config.stopCharacter)
        escapeCharacter.stringValue = String(config.escapeCharacter)
        showCandidates.state = config.showCandidates ? .on : .off
        outputInClient.selectItem(withTag: config.outputInClient ? 1 : 0)
        globalScriptSelection.state = config.globalScriptSelection ? .on : .off
        activeSessionOnDelete.state = config.activeSessionOnDelete ? .on : .off
        activeSessionOnInsert.state = config.activeSessionOnInsert ? .on : .off
        activeSessionOnCursorMove.state = config.activeSessionOnCursorMove ? .on : .off
        stopCharacter.backgroundColor = NSColor.white
        stopCharacter.backgroundColor = NSColor.white
        saveButton.title = "Save"
        saveButton.isEnabled = false
    }
    
    private func isValid() -> Bool {
        return stopCharacter.stringValue.unicodeScalars.count == 1
            && escapeCharacter.stringValue.unicodeScalars.count == 1
    }
    
    private func makeSaveable() {
        if !isValid() {
            saveButton.title = "Invalid!"
            saveButton.isEnabled = false
            return
        }
        saveButton.title = "Save"
        saveButton.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        makeSaveable()
    }
    
    @IBAction func schemeChanged(_ sender: NSPopUpButton) {
        makeSaveable()
    }
    
    @IBAction func logLevelChanged(_ sender: NSPopUpButton) {
        makeSaveable()
    }
    
    @IBAction func showCandidatesChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func outputInClientChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func globalScriptSelectionChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func activeSessionOnDeleteChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func activeSessionOnInsertChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func activeSessionOnCursorMoveChanged(_ sender: NSButton) {
        makeSaveable()
    }
    
    @IBAction func resetPressed(_ sender: NSButton) {
        reset()
    }
    
    @IBAction func savePressed(_ sender: NSButton) {
        config.schemeName = schemeName.titleOfSelectedItem!
        config.logLevel = Level(rawValue: logLevel.titleOfSelectedItem!)!
        config.stopCharacter = stopCharacter.stringValue.unicodeScalars.first!
        config.escapeCharacter = escapeCharacter.stringValue.unicodeScalars.first!
        config.showCandidates = showCandidates.state == .on
        config.outputInClient = outputInClient.selectedTag() == 1
        config.activeSessionOnDelete = activeSessionOnDelete.state == .on
        config.globalScriptSelection = globalScriptSelection.state == .on
        config.activeSessionOnInsert = activeSessionOnInsert.state == .on
        config.activeSessionOnCursorMove = activeSessionOnCursorMove.state == .on
        saveButton.title = "Saved"
        saveButton.isEnabled = false
    }
}
