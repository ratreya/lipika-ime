/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

class LipikaBanner: ExtraView, AKPickerViewDelegate, AKPickerViewDataSource {
    var tempInput = UILabel()
    var languagePicker = AKPickerView()
    var manager: DJStringBufferManager
    var languages: [(String, DJSchemeType)]

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool, inputManager: DJStringBufferManager) {
        let langTuples = LipikaBoardSettings.getLanguages()
        languages = langTuples.filter({$0.1}).map({($0.0, $0.2)})
        manager = inputManager
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        addSubview(tempInput)
        addSubview(languagePicker)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        fatalError("init(globalColors:darkMode:solidColorMode:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tempInput.center = center
        tempInput.frame.origin.x = frame.origin.x + 8
        tempInput.lineBreakMode = .byTruncatingHead
        tempInput.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: tempInput, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: tempInput, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: CGFloat(8.0)))
        self.addConstraint(NSLayoutConstraint(item: tempInput, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: CGFloat(-8.0)))
        self.addConstraint(NSLayoutConstraint(item: tempInput, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: CGFloat(2.0)))
        self.addConstraint(NSLayoutConstraint(item: tempInput, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: CGFloat(-2.0)))
        
        languagePicker.interitemSpacing = 5.0
        languagePicker.translatesAutoresizingMaskIntoConstraints = false
        languagePicker.delegate = self
        languagePicker.dataSource = self
        let currentItemIndex = languages.index(where: {$0.0 == (DJLipikaUserSettings.schemeType() == DJ_LIPIKA ? DJLipikaUserSettings.scriptName() : DJLipikaUserSettings.customSchemeName())})
        languagePicker.selectItem(currentItemIndex ?? 0)
        if currentItemIndex == nil {
            selectLanguage(index: 0)
        }
        languagePicker.reloadData()
        self.addConstraint(NSLayoutConstraint(item: languagePicker, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: languagePicker, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: tempInput, attribute: NSLayoutAttribute.right, multiplier: 1, constant: CGFloat(8.0)))
        self.addConstraint(NSLayoutConstraint(item: languagePicker, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: CGFloat(-8.0)))
        self.addConstraint(NSLayoutConstraint(item: languagePicker, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: CGFloat(2.0)))
        self.addConstraint(NSLayoutConstraint(item: languagePicker, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: CGFloat(-2.0)))
    }

    func setTempInput(input: String) {
        tempInput.text = input;
    }
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return languages[item].0
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        selectLanguage(index: item)
    }

    func selectLanguage(index: Int) {
        if languages[index].1 == DJ_LIPIKA {
            manager.changeToLipikaScheme(withName: DJLipikaUserSettings.schemeName(), forScript: languages[index].0)
        }
        else {
            manager.changeToCustomScheme(withName: languages[index].0)
        }
        DJLipikaUserSettings.setCustomSchemeName(languages[index].0)
        DJLipikaUserSettings.setSchemeType(languages[index].1)
    }
}
