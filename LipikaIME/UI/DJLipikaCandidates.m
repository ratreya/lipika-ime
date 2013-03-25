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

#import "DJLipikaCandidates.h"
#import "DJLipikaInputController.h"
#import "DJLipikaAppDelegate.h"
#import "DJLipikaUserSettings.h"

extern IMKCandidates* candidates;

@implementation DJLipikaCandidates

-(id)initWithController:(DJLipikaInputController*)myController {
    self = [super init];
    if (self == nil) {
        return self;
    }
    controller = myController;
    return self;
}

-(void)showCandidateWithInput:(NSString*)input output:(NSString*)output {
    NSAttributedString* inputString;
    NSAttributedString* outputString;
    if (input) {
        NSDictionary* attributes;
        if ([DJLipikaUserSettings isInputLikeClient]) {
            NSRect rect = NSMakeRect(0, 0, 0, 0);
            attributes = [[controller client] attributesForCharacterIndex:0 lineHeightRectangle:&rect];
        }
        else {
            attributes = [[NSApp delegate] inputAttributes];
        }
        inputString = [[NSAttributedString alloc] initWithString:input attributes:attributes];
    }
    if (output) {
        outputString = [[NSAttributedString alloc] initWithString:output attributes:[[NSApp delegate] candidateStringAttributes]];
    }
    NSAttributedString* forCandidate;
    NSAttributedString* forInput;
    switch ([DJLipikaUserSettings candidateTextType]) {
        case DJ_INPUT_IN_CANDIDATE:
            forCandidate = inputString;
            forInput = outputString;
            break;
            
        case DJ_OUTPUT_IN_CANDIDATE:
            forCandidate = outputString;
            forInput = inputString;
            break;
            
        default:
            [NSException raise:@"Unknown Candidate Text Type" format:@"Unknown Candidate Text Type: %u", [DJLipikaUserSettings candidateTextType]];
            break;
    }

    if (forInput && [DJLipikaUserSettings isShowInput]) {
        [[controller client] setMarkedText:forInput selectionRange:NSMakeRange([forInput length], 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    if (forCandidate) {
        [candidates setCandidateData:[NSArray arrayWithObjects:forCandidate, nil]];
    }
    if ([DJLipikaUserSettings isShowCandidateWindow]) {
        [candidates show:kIMKLocateCandidatesBelowHint];
    }
}

-(void)hide {
    [[controller client] setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [candidates hide];
}

@end
