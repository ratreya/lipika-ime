/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Carbon

class Installer : NSObject, InstallProtocol {
    func install(payloadPath: NSString!, withReply: ((NSString?)->Void)!) {
        let inputSourcePath = "/Library/Input Methods/LipikaInputSource.app"
        var response = "Success"
        do {
            try FileManager.default.removeItem(atPath: inputSourcePath)
        }
        catch let error {
            response = "Error in removeItem: \(error)"
            NSLog(response)
        }
        do {
            try FileManager.default.copyItem(atPath: payloadPath as String, toPath: inputSourcePath)
        }
        catch let error {
            response = "Error in copyItem: \(error)"
            NSLog(response)
        }
        withReply(response as NSString)
    }
}

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: InstallProtocol.self)
        newConnection.exportedObject = Installer()
        newConnection.resume()
        return true
    }
}

let listener = NSXPCListener.service()
listener.delegate = ServiceDelegate()
listener.resume()
