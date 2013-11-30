/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>

@interface DJPreferenceController : NSWindowController {
    IBOutlet NSStepper* opacityStepper;
    IBOutlet NSButton* saveButton;
    IBOutlet NSTextView* candidateTextFormat;
}

@property IBOutlet NSStepper* opacityStepper;
@property IBOutlet NSButton* saveButton;
@property IBOutlet NSTextView* candidateTextFormat;

-(IBAction)saveSettings:(id)sender;
-(IBAction)resetSetting:(id)sender;

@end
