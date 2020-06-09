/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import LipikaEngine_OSX
import SwiftUI

class Settings: ObservableObject {
    @Published var schemeName: String { didSet { self.reeval() } }
    @Published var scriptName: String { didSet { self.reeval() } }
    @Published var stopCharacter: String { didSet { self.reeval() } }
    @Published var escapeCharacter: String { didSet { self.reeval() } }
    @Published var logLevel: String { didSet { self.reeval() } }
    @Published var showCandidates: Bool { didSet { self.reeval() } }
    @Published var outputInClient: Bool { didSet { self.reeval() } }
    @Published var globalScriptSelection: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnCursorMove: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnDelete: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnInsert: Bool { didSet { self.reeval() } }
    
    @Published var stopCharacterInvalid = false
    @Published var escapeCharacterInvalid = false
    @Published var isDirty = false
    @Published var isFactory = false
    
    let config = LipikaConfig()
    
    init() {
        schemeName = config.schemeName
        scriptName = config.scriptName
        stopCharacter = String(config.stopCharacter)
        escapeCharacter = String(config.escapeCharacter)
        logLevel = config.logLevel.rawValue
        showCandidates = config.showCandidates
        outputInClient = config.outputInClient
        globalScriptSelection = config.globalScriptSelection
        activeSessionOnCursorMove = config.activeSessionOnCursorMove
        activeSessionOnDelete = config.activeSessionOnDelete
        activeSessionOnInsert = config.activeSessionOnInsert
        reeval()
    }
    
    func defaults() {
        config.reset()
        self.reset()
    }
    
    func reset() {
        schemeName = config.schemeName
        scriptName = config.scriptName
        stopCharacter = String(config.stopCharacter)
        escapeCharacter = String(config.escapeCharacter)
        logLevel = config.logLevel.rawValue
        showCandidates = config.showCandidates
        outputInClient = config.outputInClient
        globalScriptSelection = config.globalScriptSelection
        activeSessionOnCursorMove = config.activeSessionOnCursorMove
        activeSessionOnDelete = config.activeSessionOnDelete
        activeSessionOnInsert = config.activeSessionOnInsert
        reeval()
    }
    
    func save() {
        config.schemeName = schemeName
        config.scriptName = scriptName
        config.stopCharacter = stopCharacter.unicodeScalars.first!
        config.escapeCharacter = escapeCharacter.unicodeScalars.first!
        config.logLevel = Logger.Level(rawValue: logLevel)!
        config.showCandidates = showCandidates
        config.outputInClient = outputInClient
        config.globalScriptSelection = globalScriptSelection
        config.activeSessionOnCursorMove = activeSessionOnCursorMove
        config.activeSessionOnDelete = activeSessionOnDelete
        config.activeSessionOnInsert = activeSessionOnInsert
        reeval()
    }
    
    func reeval() {
        isDirty =
            config.schemeName != schemeName ||
            config.scriptName != scriptName ||
            config.stopCharacter != stopCharacter.unicodeScalars.first! ||
            config.escapeCharacter != escapeCharacter.unicodeScalars.first! ||
            config.logLevel != Logger.Level(rawValue: logLevel)! ||
            config.showCandidates != showCandidates ||
            config.outputInClient != outputInClient ||
            config.globalScriptSelection != globalScriptSelection ||
            config.activeSessionOnCursorMove != activeSessionOnCursorMove ||
            config.activeSessionOnDelete != activeSessionOnDelete ||
            config.activeSessionOnInsert != activeSessionOnInsert
        isFactory = UserDefaults.standard.persistentDomain(forName: "group.daivajnanam.Lipika") == nil
        stopCharacterInvalid = self.stopCharacter.unicodeScalars.count != 1
        escapeCharacterInvalid = self.escapeCharacter.unicodeScalars.count != 1
    }
}
