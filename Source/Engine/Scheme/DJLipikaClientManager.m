/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaClientManager.h"
#import "DJLipikaUserSettings.h"

/*
 * Using this technique because for some unknown reason notifications don't work.
 * They either crash the app or are never delivered.
 */
static long numCompositionCommits = 0;

@implementation DJLipikaClientManager

-(id)initWithClient:(id<IMKTextInput>)theClient {
    self = [super init];
    if (!self) return self;
    numMyCompositionCommits = 0;
    client = theClient;
    candidateManager = [[DJLipikaCandidates alloc] initWithClient:client];
    bufferManager = [[DJLipikaBufferManager alloc] init];
    return self;
}

-(DJLipikaCandidates *)candidateManager {
    return candidateManager;
}

-(BOOL)inputText:(NSString *)string {
    NSString *previousText;
    // If this is the first character and combine with previous glyph is enabled
    if ([DJLipikaUserSettings isCombineWithPreviousGlyph] && ![bufferManager hasDeletable]) {
        previousText = [self previousTextWithOffset:0];
    }
    NSString *commitString = [bufferManager outputForInput:string previousText:previousText];
    if (commitString) [client insertText:commitString replacementRange:[client selectedRange]];
    [self updateCandidates];
    return YES;
}

-(BOOL)handleBackspace {
    // If delete output or if more than one letter is selected then commit the string and let the client delete
    if ([DJLipikaUserSettings backspaceBehavior] == DJ_DELETE_OUTPUT || [client selectedRange].length > 0) {
        [self commit];
        return NO;
    }
    BOOL hasDeletable = [bufferManager hasDeletable];
    if (![DJLipikaUserSettings isCombineWithPreviousGlyph]) {
        [bufferManager delete];
        [self updateCandidates];
        return hasDeletable;
    }
    // The following logic is to combine with previous glyph
    if (!hasDeletable) {
        NSString *previousText = [self previousTextWithOffset:0];
        if (previousText) {
            if ([bufferManager outputForInput:@"" previousText:previousText]) {
                // This means that the previous character is either whitespace, stop character or non-reverse-mappable
                // Leave out one character and try the remaining
                previousText = [self previousTextWithOffset:1];
                if ([bufferManager outputForInput:@"" previousText:previousText]) {
                    // This means that the previous two characters are either whitespace, stop character or non-reverse-mappable
                    return NO;
                }
                // Because we left out the previous char, the following statement will remove it
                [candidateManager showCandidateWithInput:[bufferManager input] output:[bufferManager output] replacementLength:previousText.length+1];
                return YES;
            }
        }
        else {
            return NO;
        }
    }
    // At this point we have deletable
    [bufferManager delete];
    [self updateCandidates];
    // If there are no more deletables then pre-parse previous text
    if (![bufferManager hasDeletable]) {
        NSString *previousText = [self previousTextWithOffset:0];
        if (previousText) {
            [bufferManager outputForInput:@"" previousText:previousText];
            [self updateCandidates];
        }
    }
    return hasDeletable;
}

-(BOOL)handleCancel {
    [self revert];
    [candidateManager hide];
    return YES;
}

-(void)onFocus {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        // Activate sometimes gets called before deactivate
        [candidateManager hide];
        // updateCandidates on the next run-loop
        // IMK needs to do its thing on the current run-loop
        [self performSelector:@selector(updateCandidates) withObject:self afterDelay:0];
    }
}

-(void)onUnFocus {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_COMMIT_UNCOMMITTED) {
        [self commit];
    }
    else if ([DJLipikaUserSettings unfocusBehavior] == DJ_DISCARD_UNCOMMITTED) {
        [self revert];
    }
    else if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        [candidateManager hide];
    }
}

-(void)onEndSession {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        ++numCompositionCommits;
        /*
         * We are discarding uncommitted changes for DJ_RESTORE_UNCOMMITTED so as to
         * achieve consistent behavior on all controllers including background ones
         */
        [bufferManager flush];
    }
    else {
        [self commit];
    }
}

-(void)onCandidateSelected:(NSString *)candidateString {
    [client insertText:candidateString replacementRange:[client selectedRange]];
    [bufferManager flush];
    [candidateManager hide];
}

-(void)changeToSchemeWithName:(NSString *)schemeName forScript:scriptName type:(enum DJSchemeType)type {
    [self commit];
    [bufferManager changeToSchemeWithName:schemeName forScript:scriptName type:type];
}

-(NSString *)previousTextWithOffset:(int)offset {
    NSString *previousText = nil;
    NSRange currentPosition = [client selectedRange];
    if (currentPosition.location != NSNotFound) {
        currentPosition.location -= offset;
        if (currentPosition.location > 0) {
            unsigned long length = MIN(currentPosition.location, [bufferManager maxOutputLength]);
            previousText = [[client attributedSubstringFromRange:NSMakeRange(currentPosition.location - length, length)] string];
        }
    }
    return previousText;
}

-(void)updateCandidates {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED && numMyCompositionCommits < numCompositionCommits) {
        numMyCompositionCommits = numCompositionCommits;
        [bufferManager flush];
    }
    if ([bufferManager hasOutput]) {
        [candidateManager showCandidateWithInput:[bufferManager input] output:[bufferManager output] replacementLength:[bufferManager replacement].length];
    }
    else {
        [candidateManager hide];
    }
}

-(void)commit {
    NSString *commitString = [bufferManager flush];
    if (commitString) {
        [client insertText:commitString replacementRange:[client selectedRange]];
    }
    [candidateManager hide];
}

-(void)revert {
    NSString *previous = [bufferManager revert];
    if (previous) [client insertText:previous replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

@end
