/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2014 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJStringBufferManager.h"

@interface DJConversionController : NSWindowController {
    IBOutlet NSTextField *inputFilePath;
    IBOutlet NSComboBox *validInputEncodings;
    IBOutlet NSTextField *outputFilePath;
    IBOutlet NSComboBox *validOutputEncodings;
    IBOutlet NSMatrix *typeIndex;
    IBOutlet NSComboBox *customMappings;
    IBOutlet NSButton *isLipikaMapping;
    IBOutlet NSButton *isCustomMapping;
    DJStringBufferManager *manager;
}

@property IBOutlet NSTextField *inputFilePath;
@property IBOutlet NSComboBox *validInputEncodings;
@property IBOutlet NSTextField *outputFilePath;
@property IBOutlet NSComboBox *validOutputEncodings;
@property IBOutlet NSMatrix *typeIndex;
@property IBOutlet NSComboBox *customMappings;
@property IBOutlet NSButton *isLipikaMapping;
@property IBOutlet NSButton *isCustomMapping;

-(IBAction)selectInputFile:(id)sender;
-(IBAction)changeTypeIndex:(id)sender;
-(IBAction)changeMappingType:(id)sender;

-(IBAction)convert:(id)sender;
-(IBAction)cancel:(id)sender;

@end
