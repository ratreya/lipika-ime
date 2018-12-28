/*
 * LipikaApp is companion application for LipikaIME.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa
import LipikaEngine_OSX

class MappingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var scriptName: NSPopUpButton!
    @IBOutlet weak var schemeName: NSPopUpButton!
    
    @IBOutlet weak var mappingsView: NSTableView!
    
    private let config = LipikaConfig()
    private let factory: LiteratorFactory
    private var mappings: [(String, String, String, String)]!
    
    required init?(coder: NSCoder) {
        factory = try! LiteratorFactory(config: config)
        super.init(coder: coder)
        updateMappings(schemeName: config.schemeName, scriptName: config.scriptName)
    }
    
    private func updateMappings(schemeName: String, scriptName: String) {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.daivajnanam.Lipika")
        let customMap = container!.appendingPathComponent(schemeName + "-" + scriptName).appendingPathExtension("map")
        if FileManager.default.fileExists(atPath: customMap.path) {
            mappings = NSArray(contentsOf: customMap) as? [(String, String, String, String)]
        }
        else {
            let nested = try! factory.mappings(schemeName: schemeName, scriptName: scriptName)
            mappings = []
            for type in nested.keys {
                for key in nested[type]!.keys {
                    mappings.append((type, key, nested[type]![key]!.scheme.reduce("", {$0 + ", " + $1}), nested[type]![key]!.script ?? ""))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mappingsView.delegate = self
        mappingsView.dataSource = self
        
        scriptName.addItems(withTitles: try! factory.availableScripts())
        schemeName.addItems(withTitles: try! factory.availableSchemes())
        scriptName.selectItem(withTitle: config.scriptName)
        schemeName.selectItem(withTitle: config.schemeName)
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return mappings.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch tableColumn!.title {
        case "Type":
            return mappings[row].0
        case "Key":
            return mappings[row].1
        case "Scheme":
            return mappings[row].2
        case "Script":
            return mappings[row].3
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
        }
    }
    
    @IBAction func selectionChanged(_ sender: NSPopUpButton) {
        updateMappings(schemeName: schemeName.titleOfSelectedItem!, scriptName: scriptName.titleOfSelectedItem!)
        mappingsView.reloadData()
    }
}
