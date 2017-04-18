/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    var schemeData: String?
    var customScheme: DJGoogleInputScheme?
    var doneParsing = false

    func loadScheme() {
        let items = self.extensionContext?.inputItems[0] as! NSExtensionItem
        // We only support one attachment - see Info.plist
        let provider = items.attachments![0] as! NSItemProvider
        if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            DispatchQueue.global().async {
                provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) {
                    (txtProvider, error) in
                    if let error = error {
                        print("Error loading from provider: \(error.localizedDescription)")
                        return
                    }
                    self.schemeData = txtProvider as? String
                    // #2: after loading, callback
                    self.schemeDataDidLoad()
                }
            }
        }
        else if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            DispatchQueue.global().async {
                provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) {
                    (urlProvider, error) in
                    if let error = error {
                        print("Error loading from provider: \(error.localizedDescription)")
                        return
                    }
                    URLSession.shared.downloadTask(with: urlProvider as! URL) {
                        (location: URL?, response: URLResponse?, error: Error?) in
                        do {
                            try self.schemeData = String.init(contentsOf: location!)
                            // #2: after loading, callback
                            DispatchQueue.main.async {
                                self.schemeDataDidLoad()
                            }
                        }
                        catch let error {
                            print("Error loading from provider: \(error.localizedDescription)")
                        }
                    }.resume()
                }
            }
        }
    }

    func schemeDataDidLoad() {
        if self.schemeData == nil {
            DispatchQueue.main.async {
                self.textView.text = "Error loading file!"
            }
        }
        else {
            // #3: on the async thread itself, parse the data
            customScheme = DJGoogleSchemeFactory.init(schemeData: schemeData).scheme() as? DJGoogleInputScheme
            self.doneParsing = true
            // #4: on the main thread, update UI
            DispatchQueue.main.async {
                self.validateContent()
            }
        }
    }

    // #5: check if parsing was successful
    override func isContentValid() -> Bool {
        // When called randomly by the OS before the data is loaded
        if !doneParsing {
            return false
        }
        if customScheme == nil {
            self.textView.text = "Error parsing file!"
            return false
        }
        else {
            let currentScripts = LipikaBoardSettings.getLanguages()
            let currentSchemes = LipikaBoardSettings.getSchemes()
            if currentScripts.index(where: {$0.0 == customScheme!.name && $0.2 == DJ_LIPIKA}) != nil
                || currentSchemes?.index(of: customScheme!.name) != nil {
                self.textView.text = "[Error] Conflicting name: \(customScheme!.name ?? "unknown")! Change the scheme name and try again."
                self.textView.textColor = UIColor.red
                return false
            }
            self.textView.text = "Name: \(self.customScheme?.name ?? "unknown")\nVersion: \(self.customScheme?.version ?? "unknown")"
            return true
        }
    }

    override func presentationAnimationDidFinish() {
        // #1: start loading the scheme on a background thread
        LipikaBoardSettings.register()
        self.textView.isEditable = false
        loadScheme()
    }

    override func didSelectPost() {
        let customSchemeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LipikaBoardSettings.kAppGroupName)!
        let filePath = customSchemeURL.appendingPathComponent(customScheme!.name).appendingPathExtension("scm").path
        if !FileManager.default.createFile(atPath: filePath, contents: schemeData!.data(using: String.Encoding.utf8)) {
            assert(false, "Unable to write custom file to path \(filePath)")
        }
        var currentScripts = LipikaBoardSettings.getLanguages()
        let index = currentScripts.index(where: {$0.0 == customScheme!.name})
        if index == nil {
            currentScripts.insert((customScheme!.name, true, DJ_GOOGLE), at: 0)
            LipikaBoardSettings.storeLanguages(currentScripts)
        }
        super.didSelectPost()
    }

}
