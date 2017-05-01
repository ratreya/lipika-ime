/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

let margin: CGFloat = 8
let fontSize: CGFloat = 13

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SupportCellView.self, forCellReuseIdentifier: "Introduction")
        tableView.register(SchemeTableViewCell.self, forCellReuseIdentifier: "SchemeSelection")
        tableView.register(LanguageSelectionTableViewCell.self, forCellReuseIdentifier: "LanguageOrdering")
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Introduction"
        case 1:
            return "Select Input Scheme"
        case 2:
            return "Select Language List"
        default:
            assert(false, "Unexpected section in tableview")
        }
        return nil
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 2 {
            if view.subviews.last is UIButton {
                return
            }
            let editButton = UIButton(type: .system)
            editButton.setTitle("Reorder", for: .normal)
            editButton.addTarget(self, action: #selector(ViewController.editLanguageView(sender:)), for: UIControlEvents.primaryActionTriggered)
            view.addSubview(editButton)
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            editButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }

    func editLanguageView(sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! LanguageSelectionTableViewCell
        if cell.isReordering {
            cell.isReordering = false
            sender.setTitle("Reorder", for: .normal)
        }
        else {
            cell.isReordering = true
            sender.setTitle("Done", for: .normal)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Introduction")
            (cell as! SupportCellView).setupSupportText(indexPath.row)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SchemeSelection")
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "LanguageOrdering")
        default:
            assert(false, "Unexpected index path for table view")
        }

        if cell != nil {
            return cell!
        }
        else {
            assert(false, "Unable to dequeue reusable cell from Table View")
        }
        return UITableViewCell()
    }
}

class SupportCellView: UITableViewCell {
    var textView: UITextView = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textView.isScrollEnabled = false
        textView.font = textView.font?.withSize(fontSize)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -margin))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupSupportText(_ row: Int) {
        var text:NSMutableAttributedString? = nil
        switch row {
        case 0:
            text = NSMutableAttributedString(string: "Go to Settings ⇒ General ⇒ Keyboard ⇒ Keyboards ⇒ Add New Keyboard... and add LipikaBoard.")
            text!.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSMakeRange(6, 64))
        case 1:
            text = NSMutableAttributedString(string: "Then on any keyboard press and hold the globe button to select LipikaBoard.")
            let attachment = NSTextAttachment()
            attachment.image = #imageLiteral(resourceName: "Globe")
            let ratio = attachment.image!.size.width / attachment.image!.size.height
            attachment.bounds = CGRect(x: attachment.bounds.origin.x, y: attachment.bounds.origin.y - 2, width: ratio * fontSize, height: fontSize)
            text!.replaceCharacters(in: NSMakeRange(40, 5), with: NSAttributedString(attachment: attachment))
        case 2:
            text = NSMutableAttributedString(string: "For futher assistance post in our User Group.")
            let appLink = URL(string: "fb://group?id=1816932011905947")!
            let webLink = URL(string: "https://facebook.com/groups/lipika.ime")!
            text!.addAttribute(NSLinkAttributeName, value: UIApplication.shared.canOpenURL(appLink) ? appLink: webLink, range: NSMakeRange(34, 10))
        default:
            text = NSMutableAttributedString()
        }
        textView.attributedText = text
    }
}

class SchemeTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    let schemePicker = UIPickerView()
    let longLabel = UITextView()
    let availableSchemes = LipikaBoardSettings.getSchemes()!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        schemePicker.delegate = self
        schemePicker.dataSource = self
        schemePicker.showsSelectionIndicator = true
        let currentScheme = DJLipikaUserSettings.schemeName()
        let index = availableSchemes.index(of: currentScheme!)
        schemePicker.selectRow(index!, inComponent: 0, animated: false)
        schemePicker.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(schemePicker)

        longLabel.text = "Select the transliteration scheme that you would like to use in the Keyboard. This scheme will apply to all languages."
        longLabel.isScrollEnabled = false
        longLabel.isSelectable = false
        longLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(longLabel)

        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -margin))
        
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .top, relatedBy: .equal, toItem: schemePicker, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -margin))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableSchemes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableSchemes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DJLipikaUserSettings.setSchemeName(availableSchemes[row])
    }
}

class LanguageSelectionTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    let languagesView = UITableView()
    let longLabel = UITextView()
    var languages = LipikaBoardSettings.getLanguages()

    public var isReordering: Bool {
        get {
            return languagesView.isEditing
        }
        set(value) {
            languagesView.isEditing = value
            selectCurrentLanguage()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        languagesView.dataSource = self
        languagesView.delegate = self
        languagesView.isScrollEnabled = false
        languagesView.translatesAutoresizingMaskIntoConstraints = false
        languagesView.register(UITableViewCell.self, forCellReuseIdentifier: "Language")
        selectCurrentLanguage()
        self.addSubview(languagesView)

        longLabel.text = "Select the list of languages to show and their ordering."
        longLabel.isScrollEnabled = false
        longLabel.isSelectable = false
        longLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(longLabel)

        self.addConstraint(NSLayoutConstraint(item: languagesView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(languages.count * 45)))
        self.addConstraint(NSLayoutConstraint(item: languagesView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: languagesView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: languagesView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -margin))

        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .top, relatedBy: .equal, toItem: languagesView, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -margin))

        // Need this because custom schemes may have been added when we were in the background
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            _ in
            self.languages = LipikaBoardSettings.getLanguages()
            self.languagesView.reloadData()
            self.selectCurrentLanguage()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func selectCurrentLanguage() {
        let currentScriptName = DJLipikaUserSettings.schemeType() == DJ_LIPIKA ? DJLipikaUserSettings.scriptName(): DJLipikaUserSettings.customSchemeName()
        let currentIndex = languages.index(where: {$0.0 == currentScriptName})
        languagesView.selectRow(at: IndexPath(row: currentIndex!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Language", for: indexPath)
        let language = languages[indexPath.row]
        cell.textLabel?.text = language.0
        cell.textLabel?.isEnabled = language.1
        if language.2 == DJ_GOOGLE {
            cell.textLabel?.textColor = UIColor.purple
        }
        else {
            cell.textLabel?.textColor = UIColor.black
        }
        let switchView = UISwitch()
        switchView.isOn = language.1
        switchView.addTarget(self, action: #selector(LanguageSelectionTableViewCell.languageSelectionChanged(sender:)), for: .valueChanged)
        switchView.tag = indexPath.row
        cell.accessoryView = switchView

        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let element = languages.remove(at: sourceIndexPath.row)
        languages.insert(element, at: destinationIndexPath.row)
        LipikaBoardSettings.storeLanguages(languages)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Disallow selecting disabled languages
        if !languages[indexPath.row].1 {
            return nil
        }
        DJLipikaUserSettings.setSchemeType(languages[indexPath.row].2)
        if languages[indexPath.row].2 == DJ_LIPIKA {
            DJLipikaUserSettings.setScriptName(languages[indexPath.row].0)
        }
        else {
            DJLipikaUserSettings.setCustomSchemeName(languages[indexPath.row].0)
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func languageSelectionChanged(sender: UISwitch) {
        let index = sender.tag
        languages[index].1 = sender.isOn
        languagesView.cellForRow(at: IndexPath(row: index, section: 0))?.textLabel?.isEnabled = sender.isOn
        LipikaBoardSettings.storeLanguages(languages)
    }
}
