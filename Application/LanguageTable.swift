/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI
import LipikaEngine_OSX
import ShortcutRecorder

struct ShortcutView: View {
    @Binding var modifier: String
    @Binding var key: String
    
    var body: some View {
        HStack {
            MenuButton(modifier) {
                ForEach (["⌘", "⌥", "⌃", "⇧"], id: \.self) { (item) in
                    Button(item) { self.modifier = item }
                }
            }.fixedSize()
            TextField("", text: $key).fixedSize()
        }
    }
}


struct LanguageTable: NSViewControllerRepresentable {
    @Binding var mappings: [LanguageConfig]
    typealias NSViewControllerType = LanguageTableController

    func makeNSViewController(context: Context) -> LanguageTableController {
        return LanguageTableController(self)
    }
    
    func updateNSViewController(_ nsViewController: LanguageTableController, context: Context) {
        if nsViewController.mappings != mappings {
            nsViewController.mappings = mappings
            nsViewController.table.reloadData()
        }
    }
}

class ShortcutModel: NSObject {
    private let row: Int
    private unowned let controller: LanguageTableController
    
    init(forRow row: Int, ofController controller: LanguageTableController) {
        self.row = row
        self.controller = controller
    }
    
    @objc func shortcut() -> Shortcut? {
        if let key = controller.mappings[row].shortcutKey, let modifiers = controller.mappings[row].shortcutModifiers {
            let keyCode = ASCIILiteralKeyCodeTransformer.shared.reverseTransformedValue(key) as! UInt16
            return Shortcut(code: KeyCode(rawValue: keyCode)!, modifierFlags: NSEvent.ModifierFlags(rawValue: modifiers), characters: nil, charactersIgnoringModifiers: nil)
        }
        return nil
    }

    @objc func setShortcut(_ shortcut: Any?) {
        guard let shortcut = shortcut as? Shortcut? else {
            // Bug: key-value coding is calling this method with member variables of Shortcut as well
            return
        }
        if let shortcut = shortcut {
            controller.mappings[row].shortcutKey = ASCIILiteralKeyCodeTransformer.shared.transformedValue(shortcut.keyCode.rawValue as NSNumber)
            controller.mappings[row].shortcutModifiers = shortcut.modifierFlags.rawValue
        }
        else {
            controller.mappings[row].shortcutKey = nil
            controller.mappings[row].shortcutModifiers = nil
        }
        controller.updateWrapper()
    }
}

class LanguageTableController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    private var wrapper: LanguageTable
    var table = NSTableView()
    var mappings: [LanguageConfig]
    
    init(_ wrapper: LanguageTable) {
        self.wrapper = wrapper
        self.mappings = wrapper.mappings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
        view.autoresizesSubviews = true
        
        let columns = [
            (title: "Identifier", width: 120.0, tooltip: "Factory name for language"),
            (title: "Display Name", width: 240.0, tooltip: "Custom name for language"),
            (title: "Shortcut", width: 145.0, tooltip: "Shortcut to select language"),
            (title: "Enabled", width: 60.0, tooltip: "Show language in IME menu"),
        ]
        for column in columns {
            let tableColumn = NSTableColumn()
            tableColumn.headerCell.title = column.title
            tableColumn.headerCell.alignment = .center
            tableColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: column.title)
            tableColumn.width = CGFloat(column.width)
            tableColumn.headerToolTip = column.tooltip
            table.addTableColumn(tableColumn)
        }
        table.allowsColumnResizing = false
        table.allowsColumnSelection = false
        table.allowsMultipleSelection = false
        table.allowsColumnReordering = false
        table.allowsEmptySelection = true
        table.allowsTypeSelect = false
        table.usesAlternatingRowBackgroundColors = true
        table.intercellSpacing = NSSize(width: 15, height: 7)

        let scroll = NSScrollView()
        scroll.documentView = table
        scroll.hasVerticalScroller = true
        scroll.autoresizingMask = [.height, .width]
        scroll.borderType = .bezelBorder
        view.addSubview(scroll)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }

    // NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn?.title {
        case "Identifier":
            let id = NSTextField()
            id.identifier = tableColumn!.identifier
            id.isEditable = false
            id.drawsBackground = false
            id.isBordered = false
            return id
        case "Display Name":
            let language = NSTextField()
            language.identifier = tableColumn!.identifier
            language.delegate = self
            return language
        case "Shortcut":
            let shortcut = RecorderControl()
            shortcut.bind(.value, to: ShortcutModel(forRow: row, ofController: self), withKeyPath: "shortcut", options: nil)
            shortcut.identifier = tableColumn!.identifier
            return shortcut
        case "Enabled":
            let isEnabled = NSButton(checkboxWithTitle: "", target: self, action: #selector(self.onChange(receiver:)))
            isEnabled.identifier = tableColumn!.identifier
            return isEnabled
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }
    
    // NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return mappings.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch tableColumn!.title {
        case "Identifier":
            return mappings[row].identifier
        case "Display Name":
            return mappings[row].language
        case "Shortcut":
            return nil  // Set using key-value binding
        case "Enabled":
            return mappings[row].isEnabled
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
        }
    }

    // NSTextFieldDelegate
    func controlTextDidEndEditing(_ obj: Notification) {
        onChange(receiver: obj.object!)
    }
    
    // Native API
    func updateWrapper() {
        if wrapper.mappings != self.mappings {
            wrapper.mappings = self.mappings
        }
    }
    
    @objc func onChange(receiver: Any) {
        let row = table.row(for: receiver as! NSView)
        if row == -1 {
            // The view has changed under us
            return
        }
        let column = table.column(for: receiver as! NSView)
        switch column {
        case 1:
            mappings[row].language = (receiver as! NSTextField).stringValue
        case 3:
            mappings[row].isEnabled = (receiver as! NSButton).state == .on
        default:
            // shortcut uses key-value coding and should never come here
            Logger.log.fatal("Unknown column: \(column)")
            fatalError()
        }
        updateWrapper()
    }
}
