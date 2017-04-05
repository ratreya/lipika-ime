/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation

let kAppGroupName = "group.LipikaBoard"
let kLanguagesKey = "languages"
let kLanguagesEnabledKey = "languagesEnabled"

func registerLanguages() {
    let fullLanguageList = [("Bengali", true), ("Devanagari", true), ("Grantha", true), ("Gujarati", true), ("Gurmukhi", true), ("Hindi", true), ("IPA", true), ("ISO-15919", true), ("Kannada", true), ("Malayalam", true), ("Oriya", true), ("Tamil", true), ("Telugu", true)]
    let defaults: [String: Any] = [
        kLanguagesKey: fullLanguageList.map({$0.0}),
        kLanguagesEnabledKey: fullLanguageList.map({$0.1})
    ]
    UserDefaults.init(suiteName: kAppGroupName)?.register(defaults: defaults)
}

func getLanguages() -> [(String, Bool)] {
    let defaults = UserDefaults.init(suiteName: kAppGroupName)
    let enabledList = defaults?.value(forKey: kLanguagesEnabledKey) as! [Bool]
    let languages = defaults?.value(forKey: kLanguagesKey) as! [String]
    let zipped = zip(languages, enabledList)
    return Array(zipped)
}

func storeLanguages(languages: [(String, Bool)]) {
    let defaults = UserDefaults.init(suiteName: kAppGroupName)
    defaults?.setValue(languages.map({$0.0}), forKey: kLanguagesKey)
    defaults?.setValue(languages.map({$0.1}), forKey: kLanguagesEnabledKey)
}
