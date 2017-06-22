/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Carbon

enum InstallType {
    case new, replace, upgrade, downgrade
}

class InputSourceUtil {
    let bundleId = "com.daivajnanam.inputmethod.LipikaIME.InputSource"
    let inputSourcePath = "/Library/Input Methods/LipikaIME.app"

    func getType() -> InstallType {
        var type = InstallType.new
        let inputSources = getInputSources()
        if inputSources.count > 0 {
            // Get existing bundle version
            if let currentBundle = Bundle(path: inputSourcePath),
                let currentInfo = currentBundle.infoDictionary,
                let currentVersion = currentInfo["CFBundleShortVersionString"] as? String {
                // Get payload version
                if let newBundlePath = Bundle.main.path(forResource: "LipikaInputSource", ofType: "app"),
                    let newBundle = Bundle(path: newBundlePath),
                    let newInfo = newBundle.infoDictionary,
                    let newVersion = newInfo["CFBundleShortVersionString"] as? String {
                    // Check if there is an older version installed
                    switch newVersion.compare(currentVersion, options: NSString.CompareOptions.numeric) {
                    case ComparisonResult.orderedDescending:
                        type = InstallType.upgrade
                    case ComparisonResult.orderedSame:
                        type = InstallType.replace
                    case ComparisonResult.orderedAscending:
                        type = InstallType.downgrade
                    }
                }
                else {
                    NSLog("Unable to get new bundle version")
                }
            }
            else {
                NSLog("Unable to get current bundle version")
            }
        }
        return type;
    }

    func getInputSources() -> Array<TISInputSource> {
        let options: CFDictionary = [kTISPropertyBundleID as String: bundleId] as CFDictionary
        if let rawList = TISCreateInputSourceList(options, true) {
            let inputSourceNSArray = rawList.takeRetainedValue() as NSArray
            let inputSourceList = inputSourceNSArray as! [TISInputSource]
            return inputSourceList
        }
        else {
            NSLog("Unable to get a list of Input Sources")
            return []
        }
    }

    func register() -> Bool {
        let path = NSURL(fileURLWithPath: inputSourcePath)
        let status = TISRegisterInputSource(path)
        if (Int(status) == paramErr) {
            NSLog("Failed to register: %@ due to: %d", inputSourcePath, status)
            return false;
        }
        return true;
    }

    func remove(inputSource: TISInputSource) -> Bool {
        let status = TISDisableInputSource(inputSource)
        if (Int(status) == paramErr) {
            NSLog("Failed to remove due to: %d", status)
            return false;
        }
        return true;
    }

    func enable(inputSource: TISInputSource) -> Bool {
        let status = TISEnableInputSource(inputSource)
        if (Int(status) == paramErr) {
            NSLog("Failed to enable due to: %d", status)
            return false;
        }
        return true;
    }

    func select(inputSource: TISInputSource) -> Bool {
        let status = TISSelectInputSource(inputSource)
        if (Int(status) == paramErr) {
            NSLog("Failed to select due to: %d", status)
            return false;
        }
        return true;
    }

}
