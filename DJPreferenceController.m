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
#import <InputMethodKit/InputMethodKit.h>
#import "Constants.h"

@implementation DJPreferenceController

@synthesize fontName;
@synthesize fontSize;
@synthesize opacity;
@synthesize fontColor;
@synthesize background;
@synthesize save;

-(void)windowDidLoad {
    [fontName addItemsWithObjectValues:[[NSFontManager sharedFontManager] availableFonts]];
    [fontSize setDelegate:self];
    [opacity setDelegate:self];
    [save setBezelStyle:NSRoundedBezelStyle];
    [[self window] setDefaultButtonCell:[save cell]];
    [self loadValues];
}

-(void)loadValues {
    [fontName selectItemWithObjectValue:[DJLipikaUserSettings candidateFontName]];
    [fontSize setFloatValue:[DJLipikaUserSettings candidateFontSize]];
    [opacity setFloatValue:[DJLipikaUserSettings opacity]];
    [fontColor setColor:[DJLipikaUserSettings fontColor]];
    [background setColor:[DJLipikaUserSettings backgroundColor]];
}

-(IBAction)resetValues:(id)sender {
    [DJLipikaUserSettings reset];
    [self loadValues];
}

-(IBAction)saveValues:(id)sender {
    NSNumber* floatValue = [[[NSNumberFormatter alloc] init] numberFromString:[opacity objectValue]];
    if (floatValue == nil || floatValue.floatValue < 0.0 || floatValue.floatValue > 1.0) {
        NSBeep();
        [opacity setFloatValue:[DJLipikaUserSettings opacity]];
        return;
    }
    floatValue = [[[NSNumberFormatter alloc] init] numberFromString:[fontSize objectValue]];
    if (floatValue == nil || floatValue.floatValue < 9 || floatValue.floatValue > 288) {
        NSBeep();
        NSFont* font = [DJLipikaUserSettings candidateFont];
        float size = [[[font fontDescriptor] objectForKey:NSFontSizeAttribute] floatValue];
        [fontSize setFloatValue:size];
        return;
    }
    [DJLipikaUserSettings setFontColor:[fontColor color]];
    [DJLipikaUserSettings setBackgroundColor:[background color]];
    [DJLipikaUserSettings setOpacity:[opacity floatValue]];
    [DJLipikaUserSettings setCandidateFontName:[fontName objectValueOfSelectedItem]];
    [DJLipikaUserSettings setCandidateFontSize:[fontSize floatValue]];
    [DJPreferenceController configureCandidates];
    [self close];
}

+(void)configureCandidates {
    extern IMKCandidates* candidates;
    // Configure Candidate window
    [candidates setDismissesAutomatically:NO];
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] initWithCapacity:5];
    [attributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString*)IMKCandidatesSendServerKeyEventFirst];
    [attributes setValue:[DJLipikaUserSettings candidateFont] forKey:NSFontAttributeName];
    [attributes setValue:[NSNumber numberWithFloat:[DJLipikaUserSettings opacity]] forKey:(NSString*)IMKCandidatesOpacityAttributeName];
    [attributes setValue:[DJLipikaUserSettings fontColor] forKey:NSForegroundColorAttributeName];
    [attributes setValue:[DJLipikaUserSettings backgroundColor] forKey:NSBackgroundColorDocumentAttribute];
    [candidates setAttributes:attributes];
}


@end
