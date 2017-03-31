//
//  InstallProtocol.swift
//  LipikaIME
//
//  Created by Atreya Ranganath on 3/31/17.
//  Copyright © 2017 com.daivajnanam. All rights reserved.
//

import Foundation

@objc(InstallProtocol) protocol InstallProtocol {
    func install(payloadPath: NSString!, withReply: ((NSString?)->Void)!)
}
