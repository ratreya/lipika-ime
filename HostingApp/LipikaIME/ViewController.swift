/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa

class ViewController: NSViewController {

    var util = InputSourceUtil()

    @IBOutlet weak var actionButton: NSButton!

    @IBAction func doAction(_ sender: NSButton) {
        let inputSources = util.getInputSources()
        if inputSources.count > 0 {
            _ = util.remove(inputSource: inputSources[0])
        }
        // Delete existing input source and install the payload
        _ = installInputSource()
    }

    func installInputSource() -> Bool {
        let newBundlePath = Bundle.main.path(forResource: "LipikaInputSource", ofType: "app")
        let serviceName = "com.daivajnanam.LipikaIME"
        // First register a blessed job with launchd
        var authRef: AuthorizationRef?
        let createStatus = AuthorizationCreate(nil, nil, [], &authRef)
        if createStatus != errAuthorizationSuccess {
            NSLog("Authorization create failed with: %d", createStatus)
            return false
        }
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]
        let rightsStatus = AuthorizationCopyRights(authRef!, &authRights, nil, flags, nil)
        if rightsStatus != errAuthorizationSuccess {
            NSLog("Authorization copy rights failed with: %d", rightsStatus)
            return false
        }
        var errorRef: Unmanaged<CFError>?
        if !SMJobBless(kSMDomainSystemLaunchd, serviceName as CFString, authRef, &errorRef) {
            if let error = errorRef {
                NSLog("Unable to launch install helper due to: %@", error.takeRetainedValue().localizedDescription)
            }
            return false
        }
        // Now communicate with it using XPC
        let connection = NSXPCConnection(serviceName: serviceName)
        connection.remoteObjectInterface = NSXPCInterface(with: InstallProtocol.self)
        connection.resume()
        let installer = connection.remoteObjectProxyWithErrorHandler {
            (error) in NSLog("Remote proxy error: \(error)")
            } as! InstallProtocol
        installer.install(payloadPath: newBundlePath! as NSString) {
            (response) in NSLog("Remote response: \(response ?? "none")")
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch util.getType() {
        case .new:
            actionButton.title = "Install Lipika Input Source"
        case .upgrade:
            actionButton.title = "Upgrade Lipika Input Source"
        case .replace:
            actionButton.title = "Reinstall Lipika Input Source"
        case .downgrade:
            actionButton.title = "Newer Version already Installed"
            actionButton.isEnabled = false
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
