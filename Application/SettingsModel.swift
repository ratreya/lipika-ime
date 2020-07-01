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

class SettingsModel: Config, ObservableObject, PersistenceModel {
    @Published var schemeName: String { didSet { self.reeval() } }
    @Published var scriptName: String { didSet { self.reeval() } }
    @Published var stopString: String { didSet { self.reeval() } }
    @Published var escapeString: String { didSet { self.reeval() } }
    @Published var logLevelString: String { didSet { self.reeval() } }
    @Published var showCandidates: Bool { didSet { self.reeval() } }
    @Published var outputInClient: Bool { didSet { self.reeval() } }
    @Published var globalScriptSelection: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnCursorMove: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnDelete: Bool { didSet { self.reeval() } }
    @Published var activeSessionOnInsert: Bool { didSet { self.reeval() } }
    
    @Published var stopCharacterExample = ""
    @Published var stopCharacterInvalid = false
    @Published var escapeCharacterInvalid = false
    @Published var isDirty = false
    @Published var isFactory = false
    @Published var isValid = true

    override var stopCharacter: UnicodeScalar { get { stopString.unicodeScalars.first ?? super.stopCharacter } }
    override var escapeCharacter: UnicodeScalar { get { escapeString.unicodeScalars.first ?? super.escapeCharacter } }
    override var logLevel: Logger.Level { get { Logger.Level(rawValue: logLevelString)! } }
    
    var languages: [LanguageConfig] { get {
        config.languageConfig.filter({ $0.isEnabled })
    }}
    
    func transliterate(_ input: String) -> String {
        let factory = try! LiteratorFactory(config: self)
        let transliterator = try! factory.transliterator(schemeName: schemeName, scriptName: scriptName)
        let output = transliterator.transliterate(input)
        return output.finalaizedOutput + output.unfinalaizedOutput
    }

    let config = LipikaConfig()
    
    override init() {
        schemeName = config.schemeName
        scriptName = config.scriptName
        stopString = String(config.stopCharacter)
        escapeString = String(config.escapeCharacter)
        logLevelString = config.logLevel.rawValue
        showCandidates = config.showCandidates
        outputInClient = config.outputInClient
        globalScriptSelection = config.globalScriptSelection
        activeSessionOnCursorMove = config.activeSessionOnCursorMove
        activeSessionOnDelete = config.activeSessionOnDelete
        activeSessionOnInsert = config.activeSessionOnInsert
        super.init()
        reeval()
    }
    
    func reset() {
        config.resetSettings()
        self.reload()
    }
    
    func reload() {
        schemeName = config.schemeName
        scriptName = config.scriptName
        stopString = String(config.stopCharacter)
        escapeString = String(config.escapeCharacter)
        logLevelString = config.logLevel.rawValue
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
        config.stopCharacter = stopCharacter
        config.escapeCharacter = escapeCharacter
        config.logLevel = logLevel
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
            config.stopCharacter != stopCharacter ||
            config.escapeCharacter != escapeCharacter ||
            config.logLevel != logLevel ||
            config.showCandidates != showCandidates ||
            config.outputInClient != outputInClient ||
            config.globalScriptSelection != globalScriptSelection ||
            config.activeSessionOnCursorMove != activeSessionOnCursorMove ||
            config.activeSessionOnDelete != activeSessionOnDelete ||
            config.activeSessionOnInsert != activeSessionOnInsert
        isFactory = config.isFactorySettings()
        stopCharacterInvalid = self.stopString.unicodeScalars.count != 1
        escapeCharacterInvalid = self.escapeString.unicodeScalars.count != 1
        isValid = !stopCharacterInvalid && !escapeCharacterInvalid
        stopCharacterExample = transliterate("a\(stopCharacter)i")
    }
}
