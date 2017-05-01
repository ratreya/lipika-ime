/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

extension DJLipikaInputScheme {
    public func getMappings() -> [(String, String, String, String)]? {
        let schemeTable = self.schemeTable() as! [String: [String: String]]
        let scriptTable = self.scriptTable() as! [String: [String: String]]
        let validKeys = self.validKeys() as! [String: [String]]
        var mappings: [(String, String, String, String)] = []
        for type in validKeys.keys {
            for key in validKeys[type]! {
                if scriptTable[type]?[key] != nil {
                    mappings.append((type, key, schemeTable[type]![key]!, scriptTable[type]![key]!))
                }
            }
        }
        return mappings
    }
}

var isInEditingMode = false

class MappingsController: UITableViewController {
    @IBOutlet weak var mappingsView: UITableView!
    var scriptName = DJLipikaUserSettings.scriptName()
    var schemeName = DJLipikaUserSettings.schemeName()
    var mappings: [(String, String, String, String)]?
    var oldLeftButton: UIBarButtonItem? = nil
    var oldRightButton: UIBarButtonItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MappingsController.startEditMode))
        tableView.register(MappingViewCell.self, forCellReuseIdentifier: "Mapping")
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        // Reload mappings only if needed - this is expensive
        if mappings == nil || scriptName != DJLipikaUserSettings.scriptName() || schemeName != DJLipikaUserSettings.schemeName() {
            scriptName = DJLipikaUserSettings.scriptName()
            schemeName = DJLipikaUserSettings.schemeName()
            DJLipikaSchemeFactory.setSchemesDirectory(LipikaBoardSettings.getSchemesURL()?.path)
            let scheme = DJLipikaSchemeFactory.inputScheme(forScript: scriptName, scheme: schemeName)
            mappings = scheme?.getMappings()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mappings!.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mapping", for: indexPath)
        (cell as! MappingViewCell).setText(mappings![indexPath.row])
        return cell
    }

    public func startEditMode() {
        isInEditingMode = true
        oldLeftButton = navigationItem.leftBarButtonItem
        oldRightButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(MappingsController.endEditMode))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MappingsController.endEditMode))
        mappingsView.beginUpdates()
        mappingsView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
        mappingsView.endUpdates()
    }

    public func endEditMode() {
        isInEditingMode = false
        navigationItem.leftBarButtonItem = oldLeftButton
        navigationItem.rightBarButtonItem = oldRightButton
        mappingsView.beginUpdates()
        mappingsView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
        mappingsView.endUpdates()
    }
}

extension UITextView {
    public func toUnicodeHex() {
        text = text.unicodeScalars.map({$0.value}).map({String($0, radix: 16, uppercase: true)}).joined(separator: ", ")
    }

    public func toUnicodeChars() {
        text = text.components(separatedBy: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}).flatMap({String(UnicodeScalar(Int($0, radix: 16)!)!)}).joined()
    }
}

class MappingViewCell: UITableViewCell, UITextViewDelegate {
    var mappings: [UITextView] = [UITextView(), UITextView(), UITextView(), UITextView()]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        for i in 0..<mappings.count {
            mappings[i].isScrollEnabled = false
            mappings[i].delegate = self
            mappings[i].translatesAutoresizingMaskIntoConstraints = false
            mappings[i].tag = i
            mappings[i].isEditable = false
            mappings[i].spellCheckingType = .no
            mappings[i].autocorrectionType = .no
            mappings[i].autocapitalizationType = .none
            mappings[i].sizeToFit()
            setStyle()
            addSubview(mappings[i])

            self.addConstraint(NSLayoutConstraint(item: mappings[i], attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: mappings[i], attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: mappings[i], attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.25, constant: -margin/2))
            self.addConstraint(NSLayoutConstraint(item: mappings[i], attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: i == 0 ? self: mappings[i-1], attribute: i == 0 ? NSLayoutAttribute.left: NSLayoutAttribute.right, multiplier: 1, constant: margin/2))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStyle() {
        for i in 2..<4 {
            mappings[i].isEditable = isInEditingMode
            if isInEditingMode {
                mappings[i].layer.borderColor = UIColor.gray.cgColor
                mappings[i].layer.borderWidth = 1.0
                mappings[i].layer.cornerRadius = 5
            }
            else {
                mappings[i].layer.borderWidth = 0.0
            }
        }
    }

    override func prepareForReuse() {
        setStyle()
    }

    public func setText(_ text: (String, String, String, String)) {
        mappings[0].text = text.0
        mappings[1].text = text.1
        mappings[2].text = text.2
        mappings[3].text = text.3
        mappings[3].toUnicodeChars()
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.tag == 3 {
            textView.toUnicodeHex()
        }
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.tag == 3 {
            textView.toUnicodeChars()
        }
        return true
    }
}
