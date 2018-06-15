/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation

public final class Installer {
    enum Argument: String {
        case register = "--register"
        case remove = "--remove"
        case enable = "--enable"
        case select = "--select"
    }
    private let argument: Argument
    
    public init(arguments: [String] = CommandLine.arguments) {
        if arguments.count != 2 {
            print("[ERROR] You should specify one of --register, --remove, --enable or --select")
            exit(-1)
        }
        guard let argument = Argument(rawValue: arguments[1]) else {
            print("Unrecognized argument: \(arguments[1])")
            exit(-1)
        }
        self.argument = argument
    }
    
    public func run() {
        switch argument {
        case .register:
            register()
        case .enable:
            register()
            enable()
        case .select:
            register()
            enable()
            select()
        case .remove:
            remove()
        }
    }
    
    private func register() {
        try! InputSource.register(inputSourcePath: "/Library/Input Methods/LipikaIME.app")
    }
    
    private func enable() {
        try! InputSource.enable(inputSource: InputSource.getLipika().first!)
    }
    
    private func select() {
        try! InputSource.select(inputSource: InputSource.getLipika().first!)
    }
    
    private func remove() {
        try! InputSource.remove(inputSource: InputSource.getLipika().first!)
    }
}

// Now run it!
Installer().run()
