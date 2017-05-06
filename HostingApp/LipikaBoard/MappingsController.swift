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
    public func getMappings() -> [[String]]? {
        let mappings = self.mappings() as! [String: [String:DJMap]]
        var result: [[String]] = [[String]]()
        for type in mappings.keys {
            for key in mappings[type]!.keys {
                if mappings[type]?[key] != nil {
                    result.append([type, key, mappings[type]![key]!.scheme, mappings[type]![key]!.script])
                }
            }
        }
        return result
    }
}

var isInEditingMode = false

class MappingsController: UITableViewController, UITextViewDelegate {
    @IBOutlet weak var mappingsView: UITableView!
    var scriptName = DJLipikaUserSettings.scriptName()
    var schemeName = DJLipikaUserSettings.schemeName()
    var mappings: [[String]]?
    var originalMappings: [[String]]?
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
            originalMappings = scheme?.getMappings()
            mappings = originalMappings
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mappings!.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mapping", for: indexPath)
        (cell as! MappingViewCell).setupCell(textValues: mappings![indexPath.row], controller: self)
        cell.tag = indexPath.row
        return cell
    }

    public func startEditMode(sender: UIBarButtonItem) {
        isInEditingMode = true
        oldLeftButton = navigationItem.leftBarButtonItem
        oldRightButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(MappingsController.endEditMode(sender:)))
        navigationItem.rightBarButtonItem?.tag = 1
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MappingsController.endEditMode(sender:)))
        navigationItem.leftBarButtonItem?.tag = 2
        mappingsView.beginUpdates()
        mappingsView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
        mappingsView.endUpdates()
    }

    public func endEditMode(sender: UIBarButtonItem) {
        if sender.tag == 1 {
            // Save the changes
            let lipikaMaps = mappings?.reduce([String:[String:DJMap]]()) {initial, delta in
                var result = initial
                if result[delta[0]] != nil {
                    result[delta[0]]!.updateValue(DJMap(script: delta[3], scheme: delta[2]), forKey: delta[1])
                }
                else {
                    result.updateValue([delta[1] : DJMap(script: delta[3], scheme: delta[2])], forKey: delta[0])
                }
                return result
            }
            DJLipikaMappings.store(lipikaMaps, scriptName: scriptName, schemeName: schemeName)
        }
        else {
            mappings = originalMappings
            tableView.reloadData()
        }
        isInEditingMode = false
        navigationItem.leftBarButtonItem = oldLeftButton
        navigationItem.rightBarButtonItem = oldRightButton
        mappingsView.beginUpdates()
        mappingsView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
        mappingsView.endUpdates()
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        mappings![textView.superview!.tag][textView.tag] = textView.text
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

extension UITextView {
    public func toUnicodeHex() {
        text = text.unicodeScalars.map({$0.value}).map({String($0, radix: 16, uppercase: true)}).joined(separator: ", ")
    }

    public func toUnicodeChars() {
        text = text.components(separatedBy: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}).flatMap({String(UnicodeScalar(Int($0, radix: 16)!)!)}).joined()
    }
}

class MappingViewCell: UITableViewCell {
    var mappings: [UITextView] = [UITextView(), UITextView(), UITextView(), UITextView()]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        for i in 0..<mappings.count {
            mappings[i].isScrollEnabled = false
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

    public func setupCell(textValues: [String], controller: MappingsController) {
        for i in 0..<4 {
            mappings[i].text = textValues[i]
            mappings[i].delegate = controller
        }
        mappings[3].toUnicodeChars()
    }
}
