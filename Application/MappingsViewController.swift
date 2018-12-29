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
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var mappingsView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    private let types = ["CONSONANT", "DEPENDENT", "DIGIT", "SIGN", "VOWEL"]
    private let config = LipikaConfig()
    private let factory: LiteratorFactory
    private var mappings: [[String]]!
    
    required init?(coder: NSCoder) {
        factory = try! LiteratorFactory(config: config)
        super.init(coder: coder)
        updateMappings(schemeName: config.schemeName, scriptName: config.scriptName)
    }
    
    private func updateMappings(schemeName: String, scriptName: String) {
        if let mappings: [[String]] = MappingStore.read(schemeName: schemeName, scriptName: scriptName) {
            self.mappings = mappings
        }
        else {
            let nested = try! factory.mappings(schemeName: schemeName, scriptName: scriptName)
            self.mappings = MappingStore.denest(nested: nested)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
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
            return types.firstIndex(of: mappings[row][0])
        case "Key":
            return mappings[row][1]
        case "Scheme":
            return mappings[row][2]
        case "Script":
            return mappings[row][3]
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        switch tableColumn!.title {
        case "Type":
            mappings[row][0] = types[(object as! NSNumber).intValue]
        case "Key":
            mappings[row][1] = object as! String
        case "Scheme":
            mappings[row][2] = object as! String
        case "Script":
            mappings[row][3] = object as! String
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
        }
        saveButton.isEnabled = true
    }
    
    @IBAction func addMapping(_ sender: NSButton) {
        mappings.insert([types[0], "", "", ""], at: mappingsView.selectedRow + 1)
        mappingsView.reloadData()
        mappingsView.selectRowIndexes(IndexSet.init(integer: mappingsView.selectedRow + 1), byExtendingSelection: false)
        mappingsView.scrollRowToVisible(mappingsView.selectedRow)
    }
    
    @IBAction func removeMapping(_ sender: NSButton) {
        let selectedRow = mappingsView.selectedRow
        mappings.remove(at: selectedRow)
        mappingsView.reloadData()
        mappingsView.selectRowIndexes(IndexSet.init(integer: max(0, selectedRow - 1)), byExtendingSelection: false)
        mappingsView.scrollRowToVisible(mappingsView.selectedRow)
    }
    
    @IBAction func reset(_ sender: Any) {
        saveButton.isEnabled = false
        MappingStore.delete(schemeName: schemeName.titleOfSelectedItem!, scriptName: scriptName.titleOfSelectedItem!)
        updateMappings(schemeName: schemeName.titleOfSelectedItem!, scriptName: scriptName.titleOfSelectedItem!)
        mappingsView.reloadData()
    }
    
    @IBAction func save(_ sender: NSButton) {
        saveButton.isEnabled = false
        if !MappingStore.write(schemeName: schemeName.titleOfSelectedItem!, scriptName: scriptName.titleOfSelectedItem!, mappings: mappings) {
            Logger.log.error("Unable to write to MappingStore for \(schemeName.titleOfSelectedItem!) and \(scriptName.titleOfSelectedItem!)")
        }
    }
}
