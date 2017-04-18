/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation

class LipikaBoardSettings {
    static let kAppGroupName = "group.LipikaBoard"
    static let kLanguagesKey = "languages"
    static let kLanguagesEnabledKey = "languagesEnabled"
    static let kLanguageTypes = "languageTypes"
    
    class func register() {
        let path = getParentBundlePath()!.appendingPathComponent("UserSettings.plist").path
        var defaults = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        if defaults == nil {
            assert(false, "Unable to load defaults from \(path)")
        }
        // Add our values into the defaults
        let langList = getFullLanguageList()
        defaults?.updateValue(langList?.map({$0.0}) as AnyObject, forKey: kLanguagesKey)
        defaults?.updateValue(langList?.map({$0.1.rawValue}) as AnyObject, forKey: kLanguageTypes)
        defaults?.updateValue(Array(repeating: true, count: langList?.count ?? 0) as AnyObject, forKey: kLanguagesEnabledKey)

        UserDefaults.init(suiteName: kAppGroupName)?.register(defaults: defaults!)
    }

    private class func getKeyboardURL() -> URL? {
        if Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard" {
            return Bundle.main.bundleURL.appendingPathComponent("PlugIns/Keyboard.appex")
        }
        else if Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard.Keyboard" {
            return Bundle.main.bundleURL
        }
        else if Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard.CustomScheme" {
            return Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("Keyboard.appex")
        }
        else {
            assert(false, "Unknown bundle identifier \(Bundle.main.bundleIdentifier ?? "unknown")")
            return nil
        }
    }

    private class func getParentBundlePath() -> URL? {
        if Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard" {
            return Bundle.main.bundleURL
        }
        else if Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard.Keyboard"
                || Bundle.main.bundleIdentifier == "com.daivajnanam.LipikaBoard.CustomScheme" {
            return Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
        }
        else {
            assert(false, "Unknown bundle identifier \(Bundle.main.bundleIdentifier ?? "unknown")")
            return nil
        }
    }
    
    private class func getFullLanguageList() -> [(String, DJSchemeType)]? {
        var lipikaScripts: [String]?
        let lipikaScriptsPath = getKeyboardURL()!.appendingPathComponent("Schemes/Script").path
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: lipikaScriptsPath)
            lipikaScripts = files.filter({$0.hasSuffix(".map")}).map({($0 as NSString).deletingPathExtension})
        }
        catch let error {
            assert(false, "Unable to fetch file list from \(lipikaScriptsPath) due to: \(error)")
        }
        var customSchemes: [String]?
        let customSchemesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.path
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: customSchemesPath)
            customSchemes = files.filter({$0.hasSuffix(".scm")}).map({($0 as NSString).deletingPathExtension})
        }
        catch let error {
            assert(false, "Unable to fetch file list from \(customSchemesPath) due to: \(error)")
        }
        var response: [(String, DJSchemeType)] = []
        for script in customSchemes ?? [] {
            response.append((script, DJ_GOOGLE))
        }
        for script in lipikaScripts ?? [] {
            response.append((script, DJ_LIPIKA))
        }
        return response
    }

    class func getLanguages() -> [(String, Bool, DJSchemeType)] {
        let defaults = UserDefaults.init(suiteName: kAppGroupName)
        let enabledList = defaults?.value(forKey: kLanguagesEnabledKey) as! [Bool]
        let languages = defaults?.value(forKey: kLanguagesKey) as! [String]
        let types = (defaults?.value(forKey: kLanguageTypes) as! [NSNumber]).map({DJSchemeType.init(rawValue: $0.uint32Value)})
        var response: [(String, Bool, DJSchemeType)] = []
        for i in 0..<languages.count {
            response.append((languages[i], enabledList[i], types[i]))
        }
        return response
    }

    class func storeLanguages(_ languages: [(String, Bool, DJSchemeType)]) {
        let defaults = UserDefaults.init(suiteName: kAppGroupName)
        defaults?.setValue(languages.map({$0.0}), forKey: kLanguagesKey)
        defaults?.setValue(languages.map({$0.1}), forKey: kLanguagesEnabledKey)
        defaults?.setValue(languages.map({$0.2.rawValue}), forKey: kLanguageTypes)
    }

    class func getSchemes() -> [String]? {
        let path = getKeyboardURL()!.appendingPathComponent("Schemes/Transliteration").path
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            return files.filter({$0.hasSuffix(".tlr")}).map({($0 as NSString).deletingPathExtension})
        }
        catch let error {
            assert(false, "Unable to fetch file list from \(path) due to: \(error)")
            return nil
        }
    }
}
