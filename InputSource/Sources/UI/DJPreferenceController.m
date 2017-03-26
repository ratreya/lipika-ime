/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJPreferenceController.h"
#import "DJLipikaUserSettings.h"
#import "DJLipikaAppDelegate.h"
#import "Constants.h"

@implementation DJPreferenceController

@synthesize opacityStepper;
@synthesize saveButton;
@synthesize candidateTextFormat;

-(void)awakeFromNib {
    // Configure the model controller
    NSUserDefaultsController *controller = [NSUserDefaultsController sharedUserDefaultsController];
    [controller setAppliesImmediately:NO];
    // Configure the UI elements
    [opacityStepper setMaxValue:1.0];
    [opacityStepper setMinValue:0.0];
    [opacityStepper setIncrement:0.1];
    [saveButton setBezelStyle:NSRoundedBezelStyle];
    [[self window] setDefaultButtonCell:[saveButton cell]];
}

-(IBAction)saveSettings:(id)sender {
    // Save all values
    NSUserDefaultsController *controller = [NSUserDefaultsController sharedUserDefaultsController];
    // controller-save: does not save immediately unless this is set
    [controller setAppliesImmediately:YES];
    [controller save:sender];
    if ([DJLipikaUserSettings isOverrideCandidateAttributes]) {
        // Get the string attributes and store it
        NSRange range = NSMakeRange(0, 1);
        NSDictionary *attributes = [[candidateTextFormat attributedString] attributesAtIndex:0 effectiveRange:&range];
        [DJLipikaUserSettings setCandidateStringAttributes:attributes];
    }
    [(DJLipikaAppDelegate *)[NSApp delegate] configureCandiates];
    [self close];
}

-(IBAction)resetSetting:(id)sender {
    [DJLipikaUserSettings reset];
    [[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately:YES];
    [[NSUserDefaultsController sharedUserDefaultsController] revert:sender];
    // Revert also resets the scheme section to defaults, so we need to update the menu
    [(DJLipikaAppDelegate *)[NSApp delegate] updateSchemeSelection];
}

@end
