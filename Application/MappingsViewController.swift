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

class MappingsViewController: NSViewController {
    @IBOutlet weak var scriptName: NSComboBox!
    @IBOutlet weak var schemeName: NSComboBox!
    
    @IBOutlet weak var mappingsHeader: NSTableHeaderView!
    @IBOutlet weak var mappings: NSTableView!
    
    private let config = LipikaConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let factory = try! LiteratorFactory(config: config)
        scriptName.addItems(withObjectValues: try! factory.availableScripts())
        schemeName.addItems(withObjectValues: try! factory.availableSchemes())
        scriptName.selectItem(withObjectValue: config.scriptName)
        schemeName.selectItem(withObjectValue: config.schemeName)
    }
}
