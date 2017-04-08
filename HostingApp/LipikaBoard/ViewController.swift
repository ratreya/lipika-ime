/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        // Setup User Defaults
        LipikaBoardSettings.registerLanguages()

        super.viewDidLoad()
        tableView.register(SchemeTableViewCell.self, forCellReuseIdentifier: "SchemeSelection")
        tableView.register(LanguageTableViewCell.self, forCellReuseIdentifier: "LanguageOrdering")
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            return "Select Input Scheme"
        case 1:
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
            cell = tableView.dequeueReusableCell(withIdentifier: "SchemeSelection")
        case 1:
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

class SchemeTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    var schemePicker: UIPickerView
    var longLabel: UITextView

    let margin: CGFloat = 8
    let kSchemeNameKey = "SchemeName"
    let availableSchemes = LipikaBoardSettings.getFullSchemesList()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        longLabel = UITextView()
        schemePicker = UIPickerView()

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

class LanguageTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    var languageList: UITableView
    var longLabel: UITextView
    let margin: CGFloat = 8
    var languages =  LipikaBoardSettings.getLanguages()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        longLabel = UITextView()
        languageList = UITableView()

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
            LipikaBoardSettings.storeLanguages(languages: languages)
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
