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
@synthesize fontSizeStepper;
@synthesize opacityStepper;

-(void)awakeFromNib {
    [opacityStepper setMaxValue:1.0];
    [opacityStepper setMinValue:0.0];
    [opacityStepper setIncrement:0.1];
    [fontSizeStepper setMaxValue:288.0];
    [fontSizeStepper setMinValue:9.0];
    [fontSizeStepper setIncrement:1.0];
    [fontName addItemsWithObjectValues:[[NSFontManager sharedFontManager] availableFonts]];
    [save setBezelStyle:NSRoundedBezelStyle];
    [[self window] setDefaultButtonCell:[save cell]];
    [self loadValues];
}

-(void)loadValues {
    [fontName selectItemWithObjectValue:[DJLipikaUserSettings candidateFontName]];
    fontSize = [DJLipikaUserSettings candidateFontSize];
    opacity = [DJLipikaUserSettings opacity];
    fontColor = [DJLipikaUserSettings fontColor];
    background = [DJLipikaUserSettings backgroundColor];
}

-(IBAction)resetValues:(id)sender {
    [DJLipikaUserSettings reset];
    [self loadValues];
}

-(IBAction)saveValues:(id)sender {
    [DJLipikaUserSettings setFontColor:fontColor];
    [DJLipikaUserSettings setBackgroundColor:background];
    [DJLipikaUserSettings setOpacity:opacity];
    [DJLipikaUserSettings setCandidateFontName:[fontName objectValueOfSelectedItem]];
    [DJLipikaUserSettings setCandidateFontSize:fontSize];
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
