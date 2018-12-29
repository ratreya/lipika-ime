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

class MappingStore {
    
    static let kAppGroupId = "group.daivajnanam.Lipika"
    
    class func read(schemeName: String, scriptName: String) -> [[String]]? {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupId)
        let customMap = container!.appendingPathComponent(schemeName + "-" + scriptName).appendingPathExtension("map")
        if FileManager.default.fileExists(atPath: customMap.path) {
            return NSArray(contentsOf: customMap) as? [[String]]
        }
        return nil
    }
    
    class func read(schemeName: String, scriptName: String) -> [String: MappingValue]? {
        if let denested: [[String]] = read(schemeName: schemeName, scriptName: scriptName) {
            return nest(denested: denested)
        }
        return nil
    }
    
    class func write(schemeName: String, scriptName: String, mappings: [[String]]) -> Bool {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupId)
        let customMap = container!.appendingPathComponent(schemeName + "-" + scriptName).appendingPathExtension("map")
        if FileManager.default.fileExists(atPath: customMap.path) {
            Logger.log.warning("Overwriting mapping for \(schemeName) and \(scriptName)")
        }
        return (mappings as NSArray).write(to: customMap, atomically: true)
    }
    
    class func write(schemeName: String, scriptName: String, mappings: [String: MappingValue]) -> Bool {
        return write(schemeName: schemeName, scriptName: scriptName, mappings: denest(nested: mappings))
    }
    
    class func delete(schemeName: String, scriptName: String) {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupId)
        let customMap = container!.appendingPathComponent(schemeName + "-" + scriptName).appendingPathExtension("map")
        if FileManager.default.fileExists(atPath: customMap.path) {
            try! FileManager.default.removeItem(at: customMap)
        }
    }
    
    class func denest(nested: [String: MappingValue]) -> [[String]] {
        var mappings = [[String]]()
        for type in nested.keys.sorted() {
            for key in nested[type]!.keys {
                if let script = nested[type]![key]!.script {
                    mappings.append([type, key, nested[type]![key]!.scheme.joined(separator: ", "), script.unicodeScalars.map({$0.value}).map({String($0, radix: 16, uppercase: true)}).joined(separator: ", ")])
                }
            }
        }
        return mappings
    }
    
    class func nest(denested: [[String]]) -> [String: MappingValue] {
        var mappings = [String: MappingValue]()
        for row in denested {
            mappings[row[0], default: MappingValue()][row[1]] = (scheme: row[2].components(separatedBy: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}), script: row[3].components(separatedBy: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}).compactMap({String(UnicodeScalar(Int($0, radix: 16)!)!)}).joined())
        }
        return mappings
    }
}
