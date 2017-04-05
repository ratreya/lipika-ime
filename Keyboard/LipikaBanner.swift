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
    var languages: [String]

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool, inputManager: DJStringBufferManager) {
        // Setup User Defaults
        let langTuples = getLanguages()
        languages = langTuples.filter({$0.1}).map({$0.0})
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

    override func setNeedsLayout() {
        super.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tempInput.center = center
        tempInput.frame.origin.x = frame.origin.x + 8
        tempInput.lineBreakMode = .byTruncatingHead
        tempInput.frame.size = CGSize(width: self.frame.width / 2 - 8, height: self.frame.height - 4)
        
        let pickerFrame = CGRect(x: tempInput.frame.maxX + 8, y: tempInput.frame.minY, width: self.frame.width / 2 - 8, height: self.frame.height - 4)
        languagePicker.frame = pickerFrame
        languagePicker.delegate = self
        languagePicker.dataSource = self
        let currentItemIndex = languages.index(of: DJLipikaUserSettings.scriptName())
        languagePicker.selectItem(currentItemIndex ?? 0)
        languagePicker.reloadData()
    }

    func setTempInput(input: String) {
        tempInput.text = input;
    }
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return languages[item]
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        manager.changeToScheme(withName: DJLipikaUserSettings.schemeName(), forScript: languages[item], type: DJ_LIPIKA)
    }
}
