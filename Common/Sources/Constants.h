/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

@import Foundation;

static NSString *const DJGoogleSubMenu = @"GoogleSubMenu";
static NSString *const DJSchemeSubMenu = @"SchemeSubMenu";
static NSString *const DJScriptSubMenu = @"ScriptSubMenu";
static NSString *const DJInputMenuItemTitle = @"Input scheme";
static NSString *const DJOutputMenuItemTitle = @"Output script";

enum DJLogLevel {
    DJ_DEBUG = 1,
    DJ_WARNING = 2,
    DJ_ERROR = 3,
    DJ_FATAL = 4
};

enum DJBackspaceBehavior {
    DJ_DELETE_OUTPUT = 1,
    DJ_DELETE_MAPPING = 2,
    DJ_DELETE_INPUT = 3
};

enum DJOnUnfocusBehavior {
    DJ_DISCARD_UNCOMMITTED = 1,
    DJ_COMMIT_UNCOMMITTED = 2,
    DJ_RESTORE_UNCOMMITTED = 3
};

enum DJSchemeType {
    DJ_LIPIKA = 1,
    DJ_GOOGLE = 2
};
