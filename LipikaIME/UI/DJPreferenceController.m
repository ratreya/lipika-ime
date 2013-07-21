/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    NSUserDefaultsController* controller = [NSUserDefaultsController sharedUserDefaultsController];
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
    NSUserDefaultsController* controller = [NSUserDefaultsController sharedUserDefaultsController];
    // controller-save: does not save immediately unless this is set
    [controller setAppliesImmediately:YES];
    [controller save:sender];
    if ([DJLipikaUserSettings isOverrideCandidateAttributes]) {
        // Get the string attributes and store it
        NSRange range = NSMakeRange(0, 1);
        NSDictionary* attributes = [[candidateTextFormat attributedString] attributesAtIndex:0 effectiveRange:&range];
        [DJLipikaUserSettings setCandidateStringAttributes:attributes];
    }
    [[NSApp delegate] configureCandiates];
    [self close];
}

-(IBAction)resetSetting:(id)sender {
    [DJLipikaUserSettings reset];
    [[NSUserDefaultsController sharedUserDefaultsController] revert:sender];
}


@end
