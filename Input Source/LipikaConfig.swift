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

class LipikaConfig: Config {
    private let userDefaults: UserDefaults
    
    override init() {
        guard let groupDefaults = UserDefaults(suiteName: "group.daivajnanam.Lipika") else {
            fatalError("Unable to open UserDefaults for suite: group.daivajnanam.Lipika!")
        }
        self.userDefaults = groupDefaults
        super.init()
    }
    
    override var stopCharacter: UnicodeScalar {
        get {
            return userDefaults.string(forKey: #function)?.unicodeScalars.first ?? super.stopCharacter
        }
        set(value) {
            var strValue = ""
            strValue.unicodeScalars.append(value)
            userDefaults.set(strValue, forKey: #function)
        }
    }
    
    override var logLevel: Level {
        get {
            if let logLevelString = userDefaults.string(forKey: #function) {
                return Level.init(rawValue: logLevelString)!
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
            userDefaults.set(schemeName, forKey: #function)
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
    
    var hideCandidate: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
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
    
    var noActiveSessionOnDelete: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var noActiveSessionOnInsert: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
}
