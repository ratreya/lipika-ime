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
@synthesize sampleInputText;
@synthesize sampleOutputText;
@synthesize saveButton;

-(void)updateSampleInputText {
    static NSString* displayText = @"Nor Aught nor Nought existed; yon bright sky\nWas not, nor heaven's broad roof outstretched above.";
    [sampleInputText setString:@""];
    [sampleInputText insertText:[[NSAttributedString alloc] initWithString:displayText attributes:[DJLipikaUserSettings inputAttributes]]];
    [sampleInputText selectAll:self];
}

-(void)updateSampleOutputText {
    static NSString* displayText = @"वृद्धिरादैच्";
    [sampleOutputText setString:@""];
    [sampleOutputText insertText:[[NSAttributedString alloc] initWithString:displayText attributes:[DJLipikaUserSettings candidateStringAttributes]]];
    [sampleOutputText selectAll:self];
}

-(void)awakeFromNib {
    // Configure the model controller
    NSUserDefaultsController* controller = [NSUserDefaultsController sharedUserDefaultsController];
    [controller setAppliesImmediately:NO];
    // Configure the UI elements
    [opacityStepper setMaxValue:1.0];
    [opacityStepper setMinValue:0.0];
    [opacityStepper setIncrement:0.1];
    [self updateSampleInputText];
    [self updateSampleOutputText];
    [saveButton setBezelStyle:NSRoundedBezelStyle];
    [[self window] setDefaultButtonCell:[saveButton cell]];
}

-(IBAction)changeInputFont:(id)sender {
    NSFontManager* fontManager = [NSFontManager sharedFontManager];
    [sampleInputText selectAll:self];
    [fontManager setTarget:sampleInputText];
    [fontManager orderFrontFontPanel:self];
    [fontManager modifyFontViaPanel:self];
}

-(void)changeOutputFont:(id)sender {
    NSFontManager* fontManager = [NSFontManager sharedFontManager];
    [sampleOutputText selectAll:self];
    [fontManager setTarget:sampleOutputText];
    [fontManager orderFrontFontPanel:self];
    [fontManager modifyFontViaPanel:self];
}

-(IBAction)saveSettings:(id)sender {
    // First save the string attributes
    NSDictionary* inputAttributes = [[sampleInputText attributedString] fontAttributesInRange:NSMakeRange(0, 1)];
    NSDictionary* outputAttributes = [[sampleOutputText attributedString] fontAttributesInRange:NSMakeRange(0, 1)];
    [DJLipikaUserSettings setInputAttributes:inputAttributes];
    [DJLipikaUserSettings setCandidateStringAttributes:outputAttributes];
    // Now save the other values
    NSUserDefaultsController* controller = [NSUserDefaultsController sharedUserDefaultsController];
    // controller-save: does not save immediately unless this is set
    [controller setAppliesImmediately:YES];
    [controller save:sender];
    [[NSApp delegate] configureCandiates];
    [[NSApp delegate] configureInput];
    [self close];
}

-(IBAction)resetSetting:(id)sender {
    [DJLipikaUserSettings reset];
    [[NSUserDefaultsController sharedUserDefaultsController] revert:sender];
    [self updateSampleInputText];
    [self updateSampleOutputText];
}


@end
