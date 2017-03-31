/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation

var register = false
var enable = false
var select = false
var remove = false

if CommandLine.arguments.count != 2 {
    print("[ERROR] You should specify one of --register, --remove, --enable or --select")
    exit(-1)
}

switch CommandLine.arguments[1] {
case "--register":
    register = true
case "--enable":
    register = true
    enable = true
case "--select":
    register = true
    enable = true
    select = true
case "--remove":
    remove = true
default:
    print("[ERROR] Unrecognized argument: \(CommandLine.arguments[1])")
    exit(-1)
}

let util = InputSourceUtil()

if register {
    if !util.register() {
        print("[ERROR] Unable to register input source")
        exit(-1)
    }
}

let inputList = util.getInputSources()
if (inputList.count != 1) {
    print ("[ERROR] Expected 1 but found \(inputList.count) input source(s)")
    exit(-1)
}

if enable {
    if !util.enable(inputSource: inputList[0]) {
        print("[ERROR] Unable to enable input source")
        exit(-1)
    }
}

if select {
    if !util.select(inputSource: inputList[0]) {
        print("[ERROR] Unable to select input source")
        exit(-1)
    }
}

if remove {
    if !util.remove(inputSource: inputList[0]) {
        print("[ERROR] Unable to remove input source")
        exit(-1)
    }
}
