/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI
import AppKit
import LipikaEngine_OSX

extension String {
    static let hex = CharacterSet(charactersIn: "0123456789ABCDEF, ").inverted
    func isHex() -> Bool {
        return self.rangeOfCharacter(from: String.hex) == nil
    }
}

class UnicodeTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        if !self.stringValue.isHex() {
            self.stringValue = self.stringValue.unicodeScalars.map({$0.value}).map({String($0, radix: 16, uppercase: true)}).joined(separator: ", ")
        }
        return super.becomeFirstResponder()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        if !self.stringValue.isEmpty && self.stringValue.isHex() {
            self.stringValue = self.stringValue.components(separatedBy: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}).map({String(UnicodeScalar(Int($0, radix: 16)!)!)}).joined()
        }
        super.textDidEndEditing(notification)
    }
}

struct MappingTable: NSViewControllerRepresentable {
    @Binding var mappings: [[String]]
    typealias NSViewControllerType = MappingTableController

    func makeNSViewController(context: Context) -> MappingTableController {
        return MappingTableController(self)
    }
    
    func updateNSViewController(_ nsViewController: MappingTableController, context: Context) {
        if nsViewController.mappings != mappings {
            nsViewController.mappings = mappings
            nsViewController.table.reloadData()
        }
    }
}

class MappingTableController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    private let types = ["CONSONANT", "DEPENDENT", "DIGIT", "SIGN", "VOWEL"]
    private var wrapper: MappingTable
    var table = NSTableView()
    var mappings: [[String]]
    
    init(_ wrapper: MappingTable) {
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
            (title: "Type", width: 150.0, tooltip: "Output character type"),
            (title: "Key", width: 180.0, tooltip: "Mapping identifier"),
            (title: "Scheme", width: 135.0, tooltip: "User input"),
            (title: "Script", width: 140.0, tooltip: "Generated output")
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
        table.intercellSpacing = NSSize(width: 5, height: 7)
        
        let menu = NSMenu(title: "Mappings")
        menu.addItem(NSMenuItem(title: "Add Mapping", action: #selector(self.addMappingMenu(receiver:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Remove Mapping", action: #selector(self.removeMappingMenu(receiver:)), keyEquivalent: ""))
        table.menu = menu

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
        table.registerForDraggedTypes([dragDropType])
    }

    // NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn?.title {
            case "Type":
                let type = NSPopUpButton()
                type.identifier = tableColumn!.identifier
                type.addItems(withTitles: types)
                type.target = self
                type.action = #selector(self.onChange(receiver:))
                return type
            case "Key":
                let key = NSTextField()
                key.identifier = tableColumn!.identifier
                key.delegate = self
                return key
            case "Scheme":
                let scheme = NSTextField()
                scheme.identifier = tableColumn!.identifier
                scheme.delegate = self
                return scheme
            case "Script":
                let script = UnicodeTextField()
                script.identifier = tableColumn!.identifier
                script.delegate = self
                return script
            default:
                Logger.log.fatal("Unknown column title \(tableColumn!.title)")
                fatalError()
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .leading {
            return [NSTableViewRowAction(style: .regular, title: "Add", handler: { action, row in self.addMapping(at: row) })]
        }
        else {
            return [NSTableViewRowAction(style: .destructive, title: "Remove", handler: { action, row in self.removeMapping(row: row) })]
        }
    }
    
    // NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return mappings.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
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
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: dragDropType)
        return item
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = IndexSet()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.insert(index)
            }
        }
        mappings.move(fromOffsets: oldIndexes, toOffset: row)
        updateWrapper()
        table.reloadData()
        return true
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
        case 0:
            mappings[row][0] = (receiver as! NSPopUpButton).titleOfSelectedItem!
        case 1:
            mappings[row][1] = (receiver as! NSTextField).stringValue
        case 2:
            mappings[row][2] = (receiver as! NSTextField).stringValue
        case 3:
            mappings[row][3] = (receiver as! NSTextField).stringValue
        default:
            Logger.log.fatal("Unknown column: \(column)")
            fatalError()
        }
        updateWrapper()
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        onChange(receiver: obj.object!)
    }

    // Own API
    @objc func addMappingMenu(receiver: Any) {
        addMapping(at: table.clickedRow + 1)
    }
    
    @objc func removeMappingMenu(receiver: Any) {
        removeMapping(row: table.clickedRow)
    }
    
    func addMapping(at: Int? = nil) {
        let newRow = at ?? table.selectedRow + 1
        mappings.insert([types[0], "", "", ""], at: newRow)
        wrapper.mappings = self.mappings
        table.reloadData()
        table.selectRowIndexes(IndexSet.init(integer: newRow), byExtendingSelection: false)
        table.scrollRowToVisible(table.selectedRow)
    }
    
    func removeMapping(row: Int? = nil) {
        let selectedRow = row ?? table.selectedRow
        mappings.remove(at: selectedRow)
        wrapper.mappings = self.mappings
        table.reloadData()
        table.selectRowIndexes(IndexSet.init(integer: max(0, selectedRow - 1)), byExtendingSelection: false)
        table.scrollRowToVisible(table.selectedRow)
    }
}
