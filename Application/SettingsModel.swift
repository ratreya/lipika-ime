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
    @Published var schemeName: String
    @Published var scriptName: String
    @Published var stopCharacter: String {
        didSet {
            self.stopCharacterInvalid = self.stopCharacter.unicodeScalars.count != 1
        }
    }
    @Published var escapeCharacter: String {
           didSet {
               self.escapeCharacterInvalid = self.escapeCharacter.unicodeScalars.count != 1
           }
       }
    @Published var logLevel: String
    @Published var showCandidates: Bool
    @Published var outputInClient: Bool
    @Published var globalScriptSelection: Bool
    @Published var activeSessionOnCursorMove: Bool
    @Published var activeSessionOnDelete: Bool
    @Published var activeSessionOnInsert: Bool
    
    @Published var stopCharacterInvalid = false
    @Published var escapeCharacterInvalid = false
    
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
    }
    
    func save() {
        config.schemeName = schemeName
        config.scriptName = schemeName
        config.stopCharacter = stopCharacter.unicodeScalars.first!
        config.escapeCharacter = escapeCharacter.unicodeScalars.first!
        config.logLevel = Logger.Level(rawValue: logLevel)!
        config.showCandidates = showCandidates
        config.outputInClient = outputInClient
        config.globalScriptSelection = globalScriptSelection
        config.activeSessionOnCursorMove = activeSessionOnCursorMove
        config.activeSessionOnDelete = activeSessionOnDelete
        config.activeSessionOnInsert = activeSessionOnInsert
    }
}
