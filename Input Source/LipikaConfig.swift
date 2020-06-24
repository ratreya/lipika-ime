/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation
import LipikaEngine_OSX

struct LanguageConfig: Codable, Equatable {
    var identifier: String  // Factory default name of the language
    var language: String
    var isEnabled: Bool
    var keyModifier: UInt?
    var shortcutKey: UInt16?
}

class LipikaConfig: Config {
    private static let kGroupDomainName = "group.daivajnanam.Lipika"
    private let userDefaults: UserDefaults
    
    func reset() {
        UserDefaults.standard.removePersistentDomain(forName: LipikaConfig.kGroupDomainName)
        UserDefaults.standard.synchronize()
    }
    
    func resetLanguageConfig() {
        userDefaults.removeObject(forKey: "languageConfig")
    }
    
    override init() {
        guard let groupDefaults = UserDefaults(suiteName: LipikaConfig.kGroupDomainName) else {
            fatalError("Unable to open UserDefaults for suite: \(LipikaConfig.kGroupDomainName)!")
        }
        self.userDefaults = groupDefaults
        super.init()
    }
    
    override var stopCharacter: UnicodeScalar {
        get {
            return userDefaults.string(forKey: #function)?.unicodeScalars.first ?? super.stopCharacter
        }
        set(value) {
            userDefaults.set(String(value), forKey: #function)
        }
    }
    
    override var escapeCharacter: UnicodeScalar {
        get {
            return userDefaults.string(forKey: #function)?.unicodeScalars.first ?? super.escapeCharacter
        }
        set(value) {
            userDefaults.set(String(value), forKey: #function)
        }
    }

    override var logLevel: Logger.Level {
        get {
            if let logLevelString = userDefaults.string(forKey: #function) {
                return Logger.Level(rawValue: logLevelString)!
            }
            else {
                return super.logLevel
            }
        }
        set(value) {
            userDefaults.set(value.rawValue, forKey: #function)
        }
    }
    
    var enabledScripts: [String] {
        get {
            return try! userDefaults.stringArray(forKey: #function) ?? LiteratorFactory(config: self).availableScripts()
        }
        set(value) {
            if value.isEmpty {
                userDefaults.removeObject(forKey: #function)
            }
            else {
                userDefaults.set(value, forKey: #function)
            }
        }
    }

    var schemeName: String {
        get {
            return try! userDefaults.string(forKey: #function) ?? LiteratorFactory(config: self).availableSchemes().first!
        }
        set(value) {
            userDefaults.removeObject(forKey: "customSchemeName")
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var scriptName: String {
        get {
            return userDefaults.string(forKey: #function) ?? enabledScripts.first!
        }
        set(value) {
            userDefaults.removeObject(forKey: "customSchemeName")
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var customSchemeName: String? {
        get {
            return userDefaults.string(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var showCandidates: Bool {
        get {
            return !userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(!value, forKey: #function)
        }
    }
    
    var outputInClient: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var globalScriptSelection: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }

    /*
     It is impossible to reliably determine the PositionalUnit a given client uses to report caret location.
     And so, when output is in client, don't try to start your own session.
    */
    var activeSessionOnDelete: Bool {
        get {
            return !outputInClient && userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var activeSessionOnInsert: Bool {
        get {
            return !outputInClient && userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var activeSessionOnCursorMove: Bool {
        get {
            return !outputInClient && userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var languageConfig: [LanguageConfig] {
        get {
            if let encoded = userDefaults.data(forKey: #function) {
                do {
                    return try JSONDecoder().decode(Array<LanguageConfig>.self, from: encoded)
                }
                catch {
                    Logger.log.error("Exception while trying to decode languageConfig: \(error)")
                    resetLanguageConfig()
                }
            }
            let scripts = try! LiteratorFactory(config: self).availableScripts()
            return scripts.compactMap() { script in LanguageConfig(identifier: script, language: script, isEnabled: true) }
        }
        set(value) {
            let encodedData: Data = try! JSONEncoder().encode(value)
            userDefaults.set(encodedData, forKey: #function)
        }
    }
}
