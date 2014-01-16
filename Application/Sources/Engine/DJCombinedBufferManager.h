/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJActiveBufferManager.h"

@interface DJCombinedBufferManager : NSObject {
    DJActiveBufferManager *manager;
    
    IBOutlet NSPopUpButton *scriptPopup;
    IBOutlet NSPopUpButton *schemePopup;
    IBOutlet NSTextView *originalTextView;
    IBOutlet NSTextView *composedTextView;
}

@property IBOutlet NSPopUpButton *scriptPopup;
@property IBOutlet NSPopUpButton *schemePopup;
@property IBOutlet NSTextView *originalTextView;
@property IBOutlet NSTextView *composedTextView;

@end
