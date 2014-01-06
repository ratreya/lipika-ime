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

-(id)initWithClient:(DJLipikaClientDelegate *)theClient {
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
    NSDictionary *attributes = [client textAttributesAtCurrentPosition];

    if ([DJLipikaUserSettings isOutputInCandidate]) {
        forCandidate = outputString;
        forClient = inputString?[[NSAttributedString alloc] initWithString:inputString attributes:attributes]:nil;
    }
    else {
        forCandidate = inputString;
        forClient = outputString?[[NSAttributedString alloc] initWithString:outputString attributes:attributes]:nil;
    }

    if (forClient) {
        [client setMarkedText:forClient withReplacementOffset:replacementLength];
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
    [client clearMarkedText];
    [candidates hide];
    currentCandidates = [NSArray array];
}

@end
