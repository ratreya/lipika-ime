/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Carbon
import LipikaEngine_OSX

class InputSource {
    enum InstallType {
        case new, replace, upgrade, downgrade
    }

    static func getLipika() -> Array<TISInputSource> {
        let options: CFDictionary = [kTISPropertyBundleID as String: Bundle.main.bundleIdentifier] as CFDictionary
        if let rawList = TISCreateInputSourceList(options, true) {
            let inputSourceNSArray = rawList.takeRetainedValue() as NSArray
            let inputSourceList = inputSourceNSArray as! [TISInputSource]
            return inputSourceList
        }
        else {
            return []
        }
    }

    static func getAll() -> Array<TISInputSource> {
        if let rawList = TISCreateInputSourceList(nil, true) {
            let inputSourceNSArray = rawList.takeRetainedValue() as NSArray
            let inputSourceList = inputSourceNSArray as! [TISInputSource]
            return inputSourceList
        }
        else {
            return []
        }
    }

    static func register(inputSourcePath: String) throws {
        let path = NSURL(fileURLWithPath: inputSourcePath)
        let status = TISRegisterInputSource(path)
        if (Int(status) == paramErr) {
            throw LipikaError.systemError("Failed to register: \(inputSourcePath) due to: \(status)!")
        }
    }

    static func remove(inputSource: TISInputSource) throws {
        let status = TISDisableInputSource(inputSource)
        if (Int(status) == paramErr) {
            throw LipikaError.systemError("Failed to remove due to: \(status)!")
        }
    }

    static func enable(inputSource: TISInputSource) throws {
        let status = TISEnableInputSource(inputSource)
        if (Int(status) == paramErr) {
            throw LipikaError.systemError("Failed to enable due to: \(status)!")
        }
    }

    static func select(inputSource: TISInputSource) throws {
        let status = TISSelectInputSource(inputSource)
        if (Int(status) == paramErr) {
            throw LipikaError.systemError("Failed to select due to: \(status)!")
        }
    }
}
