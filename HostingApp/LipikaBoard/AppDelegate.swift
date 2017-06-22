/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Setup User Defaults
        LipikaBoardSettings.register()
        if loadAttachment(url) {
            // This will make the viewController reload the list and show the latest scheme that we just added
            NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationWillEnterForeground))
        }
        else {
            return false
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Setup User Defaults
        LipikaBoardSettings.register()
        if let url = launchOptions?[.url] as? URL {
            _ = loadAttachment(url)
        }
        return true
    }

    private func loadAttachment(_ url: URL) -> Bool {
        do {
            let schemeData = try String.init(contentsOf: url)
            let customScheme = DJGoogleSchemeFactory.init(schemeData: schemeData).scheme() as? DJGoogleInputScheme
            if customScheme == nil {
                return false
            }
            let customSchemeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LipikaBoardSettings.kAppGroupName)!
            let filePath = customSchemeURL.appendingPathComponent(customScheme!.name).appendingPathExtension("scm").path
            if !FileManager.default.createFile(atPath: filePath, contents: schemeData.data(using: String.Encoding.utf8)) {
                assert(false, "Unable to write custom file to path \(filePath)")
                return false
            }
            var currentScripts = LipikaBoardSettings.getLanguages()
            let index = currentScripts.index(where: {$0.0 == customScheme!.name})
            if index == nil {
                currentScripts.insert((customScheme!.name, true, DJ_GOOGLE), at: 0)
                LipikaBoardSettings.storeLanguages(currentScripts)
            }
        }
        catch let error {
            print("Error loading from provider: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
