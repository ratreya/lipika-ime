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
    static let fullLanguagesList = [("Bengali", true), ("Devanagari", true), ("Grantha", true), ("Gujarati", true), ("Gurmukhi", true), ("Hindi", true), ("IPA", true), ("ISO-15919", true), ("Kannada", true), ("Malayalam", true), ("Oriya", true), ("Tamil", true), ("Telugu", true)]
    static let fullSchemesList = ["Baraha", "Barahavat", "Harvard-Kyoto", "ITRANS", "Ksharanam"]

    class func registerLanguages() {
        var path = Bundle.main.path(forResource: "UserSettings", ofType: "plist")
        if path == nil {
            // If this is being called from the HostingApp
            path = Bundle.main.resourceURL!.appendingPathComponent("PlugIns/Keyboard.appex/UserSettings.plist").path
        }
        var defaults: [String: AnyObject]?
        if path == nil {
            // Manually initialize if UserSettings.plist cannot be found
            assert(false, "Unable to find UserSettings.plist")
            defaults  = [String: AnyObject]()
        }
        else {
            defaults = NSDictionary(contentsOfFile: path!) as? [String : AnyObject]
        }
        // Add our values into the defaults
        defaults?.updateValue(fullLanguagesList.map({$0.0}) as AnyObject, forKey: kLanguagesKey)
        defaults?.updateValue(fullLanguagesList.map({$0.1}) as AnyObject, forKey: kLanguagesEnabledKey)

        UserDefaults.init(suiteName: kAppGroupName)?.register(defaults: defaults!)
    }

    class func getLanguages() -> [(String, Bool)] {
        let defaults = UserDefaults.init(suiteName: kAppGroupName)
        let enabledList = defaults?.value(forKey: kLanguagesEnabledKey) as! [Bool]
        let languages = defaults?.value(forKey: kLanguagesKey) as! [String]
        let zipped = zip(languages, enabledList)
        return Array(zipped)
    }

    class func storeLanguages(languages: [(String, Bool)]) {
        let defaults = UserDefaults.init(suiteName: kAppGroupName)
        defaults?.setValue(languages.map({$0.0}), forKey: kLanguagesKey)
        defaults?.setValue(languages.map({$0.1}), forKey: kLanguagesEnabledKey)
    }

    class func getFullLanguagesList() -> [String] {
        let path = Bundle.main.resourceURL!.appendingPathComponent("PlugIns/Keyboard.appex/Schemes/Script").path
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            return files.filter({$0.hasSuffix(".map")}).map({($0 as NSString).deletingPathExtension})
        }
        catch let error {
            assert(false, "Unable to fetch file list from \(path) due to: \(error)")
            return fullLanguagesList.map({$0.0})
        }
    }

    class func getFullSchemesList() -> [String] {
        let path = Bundle.main.resourceURL!.appendingPathComponent("PlugIns/Keyboard.appex/Schemes/Transliteration").path
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            return files.filter({$0.hasSuffix(".tlr")}).map({($0 as NSString).deletingPathExtension})
        }
        catch let error {
            assert(false, "Unable to fetch file list from \(path) due to: \(error)")
            return fullSchemesList
        }
    }
}
