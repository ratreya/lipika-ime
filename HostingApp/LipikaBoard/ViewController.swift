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
        tableView.register(LanguageTableViewCell.self, forCellReuseIdentifier: "LanguageOrdering")
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Introduction")
            var text:NSMutableAttributedString? = nil
            switch indexPath.row {
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
            (cell as! SupportCellView).setSupportText(text!)
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

        self.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setSupportText(_ text: NSMutableAttributedString) {
        textView.attributedText = text
    }
}

class SchemeTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    var schemePicker: UIPickerView
    var longLabel: UITextView
    let kSchemeNameKey = "SchemeName"
    let availableSchemes: [String]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        longLabel = UITextView()
        schemePicker = UIPickerView()
        availableSchemes = LipikaBoardSettings.getSchemes()!

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        schemePicker.delegate = self
        schemePicker.dataSource = self
        schemePicker.showsSelectionIndicator = true
        let currentScheme = UserDefaults(suiteName: LipikaBoardSettings.kAppGroupName)?.string(forKey: kSchemeNameKey)
        let index = availableSchemes.index(of: currentScheme!)
        schemePicker.selectRow(index!, inComponent: 0, animated: false)
        schemePicker.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(schemePicker)

        longLabel.text = "Select the transliteration scheme that you would like to use in the Keyboard. This scheme will apply to all languages."
        longLabel.isScrollEnabled = false
        longLabel.isSelectable = false
        longLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(longLabel)

        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: schemePicker, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin))
        
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: schemePicker, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin))
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
        UserDefaults(suiteName: LipikaBoardSettings.kAppGroupName)?.set(availableSchemes[row], forKey: kSchemeNameKey)
    }
}

extension UIFont {
    func italic() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep size as it is
    }

    func regular() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits())
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep size as it is
    }
}

class LanguageTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    var languageList: UITableView
    var longLabel: UITextView
    var languages: [(String, Bool, DJSchemeType)]
    let settings = LipikaBoardSettings()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        longLabel = UITextView()
        languageList = UITableView()
        languages =  LipikaBoardSettings.getLanguages()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        languageList.estimatedRowHeight = 22
        languageList.rowHeight = UITableViewAutomaticDimension
        languageList.allowsSelection = false
        languageList.dataSource = self
        languageList.delegate = self
        languageList.isEditing = true
        languageList.translatesAutoresizingMaskIntoConstraints = false
        languageList.register(UITableViewCell.self, forCellReuseIdentifier: "Language")
        self.addSubview(languageList)

        longLabel.text = "Select the list of languages to show and their ordering."
        longLabel.isScrollEnabled = false
        longLabel.isSelectable = false
        longLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(longLabel)

        languageList.isScrollEnabled = false
        self.addConstraint(NSLayoutConstraint(item: languageList, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(languages.count * 45)))
        self.addConstraint(NSLayoutConstraint(item: languageList, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: languageList, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: languageList, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin))

        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: languageList, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin))

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            _ in
            self.languages = LipikaBoardSettings.getLanguages()
            self.languageList.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Language", for: indexPath)
        cell.textLabel?.text = languages[indexPath.row].0
        if languages[indexPath.row].2 == DJ_GOOGLE {
            cell.textLabel?.font = cell.textLabel?.font.italic()
            cell.textLabel?.textColor = UIColor.purple
        }
        else {
            cell.textLabel?.font = cell.textLabel?.font.regular()
            cell.textLabel?.textColor = UIColor.black
        }
        cell.textLabel?.isEnabled = languages[indexPath.row].1
        cell.showsReorderControl = true
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let element = languages.remove(at: sourceIndexPath.row)
        languages.insert(element, at: destinationIndexPath.row)
        LipikaBoardSettings.storeLanguages(languages)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if editingStyle == UITableViewCellEditingStyle.delete {
            if (cell?.textLabel?.isEnabled)! {
                cell?.textLabel?.isEnabled = false
                languages[indexPath.row].1 = false
            }
            else {
                cell?.textLabel?.isEnabled = true
                languages[indexPath.row].1 = true
            }
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.right)
            LipikaBoardSettings.storeLanguages(languages)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if languages[indexPath.row].1 {
            return "Hide"
        }
        else {
            return "Show"
        }
    }
}
