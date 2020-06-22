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
import Carbon.HIToolbox.Events

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
            (title: "Language", width: 240.0, tooltip: "Custom name for language"),
            (title: "Shortcut", width: 300.0, tooltip: "Shortcut to select language"),
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
        table.intercellSpacing = NSSize(width: 5, height: 8)

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
            case "Language":
                let language = NSTextField()
                language.identifier = tableColumn!.identifier
                language.delegate = self
                return language
            case "Enabled":
                let isEnabled = NSButton(checkboxWithTitle: "", target: self, action: #selector(self.onChange(receiver:)))
                isEnabled.identifier = tableColumn!.identifier
                return isEnabled
            case "Shortcut":
                let shortcut = NSTextField()
                shortcut.identifier = tableColumn!.identifier
                shortcut.delegate = self
                return shortcut
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
        case "Language":
            return mappings[row].language
        case "Enabled":
            return mappings[row].isEnabled
        case "Shortcut":
            return mappings[row].shortcutKey
        default:
            Logger.log.fatal("Unknown column title \(tableColumn!.title)")
            fatalError()
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
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            Logger.log.fatal("Unknown column: \(column)")
            fatalError()
        }
        if wrapper.mappings != self.mappings {
            wrapper.mappings = self.mappings
        }
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        onChange(receiver: obj.object!)
    }
}
