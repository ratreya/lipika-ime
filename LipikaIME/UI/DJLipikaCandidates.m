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
    NSString* inputString;
    NSString* outputString;
    if (input && [DJLipikaUserSettings isShowInput]) {
        inputString = input;
    }
    if (output && [DJLipikaUserSettings isShowOutput]) {
        outputString = output;
    }
    NSString* forCandidate;
    NSAttributedString* forClient;
    // Get the attributes of the client
    NSDictionary* attributes;
    NSRect rect = NSMakeRect(0, 0, 0, 0);
    attributes = [[controller client] attributesForCharacterIndex:0 lineHeightRectangle:&rect];

    if ([DJLipikaUserSettings isOutputInCandidate]) {
        forCandidate = outputString;
        forClient = inputString?[[NSAttributedString alloc] initWithString:inputString attributes:attributes]:nil;
    }
    else {
        forCandidate = inputString;
        forClient = outputString?[[NSAttributedString alloc] initWithString:outputString attributes:attributes]:nil;
    }

    if (forClient) {
        [[controller client] setMarkedText:forClient selectionRange:NSMakeRange([forClient length], 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    if (forCandidate) {
        if ([DJLipikaUserSettings isOverrideCandidateAttributes]) {
            currentCandidates = [NSArray arrayWithObjects:[[NSAttributedString alloc] initWithString:forCandidate attributes:[DJLipikaUserSettings candidateStringAttributes]], nil];
        }
        else {
            currentCandidates = [NSArray arrayWithObjects:forCandidate, nil];
        }
        [candidates updateCandidates];
        [candidates show:kIMKLocateCandidatesBelowHint];
    }
}

-(NSArray *)candidates:(id)sender {
    return currentCandidates;
}

-(void)hide {
    [[controller client] setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [candidates hide];
}

@end
