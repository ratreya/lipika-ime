/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaCandidates.h"
#import "DJLipikaInputController.h"
#import "DJLipikaAppDelegate.h"
#import "DJLipikaUserSettings.h"

extern IMKCandidates *candidates;

@implementation DJLipikaCandidates

-(id)initWithClient:(id<IMKTextInput>)theClient {
    self = [super init];
    if (self == nil) {
        return self;
    }
    client = theClient;
    currentCandidates = [NSArray array];
    return self;
}

-(void)showCandidateWithInput:(NSString *)input output:(NSString *)output replacementLength:(unsigned long)replacementLength {
    NSString *inputString;
    NSString *outputString;
    if (input && [DJLipikaUserSettings isShowInput]) {
        inputString = input;
    }
    if (output && [DJLipikaUserSettings isShowOutput]) {
        outputString = output;
    }
    NSString *forCandidate;
    NSAttributedString *forClient;
    // Get the attributes of the client
    NSDictionary *attributes;
    NSRect rect = NSMakeRect(0, 0, 0, 0);
    attributes = [client attributesForCharacterIndex:0 lineHeightRectangle:&rect];

    if ([DJLipikaUserSettings isOutputInCandidate]) {
        forCandidate = outputString;
        forClient = inputString?[[NSAttributedString alloc] initWithString:inputString attributes:attributes]:nil;
    }
    else {
        forCandidate = inputString;
        forClient = outputString?[[NSAttributedString alloc] initWithString:outputString attributes:attributes]:nil;
    }

    if (forClient) {
        NSRange replacementRange = [client selectedRange];
        replacementRange.location -= replacementLength;
        replacementRange.length += replacementLength;
        [client setMarkedText:forClient selectionRange:NSMakeRange([forClient length], 0) replacementRange:replacementRange];
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

-(NSArray *)candidates {
    return currentCandidates;
}

-(void)hide {
    [client setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [candidates hide];
    currentCandidates = [NSArray array];
}

@end
