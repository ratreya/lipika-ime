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
    
    init() {
        guard let groupDefaults = UserDefaults(suiteName: "group.daivajnanam.Lipika") else {
            fatal("Unable to open UserDefaults for suite: group.daivajnanam.Lipika!")
        }
        self.userDefaults = groupDefaults
    }
    
    var stopCharacter: UnicodeScalar {
        get {
            return userDefaults.string(forKey: #function)?.unicodeScalars.first ?? "\\"
        }
        set(value) {
            var strValue = ""
            strValue.unicodeScalars.append(value)
            userDefaults.set(strValue, forKey: #function)
        }
    }
    
    var schemesDirectory: URL {
        get {
            let directoryName = userDefaults.string(forKey: #function) ?? "Mapping"
            return Bundle.main.bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(directoryName, isDirectory: true)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var customMappingsDirectory: URL {
        get {
            let directoryName = userDefaults.string(forKey: #function) ?? "Custom"
            return Bundle.main.bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(directoryName, isDirectory: true)
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }
    
    var logLevel: Level {
        get {
            return Level.init(rawValue: userDefaults.string(forKey: #function) ?? "Warning")!
        }
        set(value) {
            userDefaults.set(value.rawValue, forKey: #function)
        }
    }
    
    var enabledScripts: [String] {
        get {
            do {
                let availableScripts = try LiteratorFactory(config: self).availableScripts()
                return userDefaults.stringArray(forKey: #function) ?? availableScripts
            }
            catch {
                fatal(error.localizedDescription)
            }
        }
        set(value) {
            userDefaults.set(value, forKey: #function)
        }
    }

    var schemeName: String {
        get {
            return userDefaults.string(forKey: #function) ?? "Barahavat"
        }
        set(value) {
            userDefaults.set(schemeName, forKey: #function)
        }
    }
    
    var scriptName: String {
        get {
            return userDefaults.string(forKey: #function) ?? enabledScripts.first!
        }
        set(value) {
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
}
