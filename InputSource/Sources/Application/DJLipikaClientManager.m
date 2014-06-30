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
#import "DJLogger.h"

/*
 * Using this technique because for some unknown reason notifications don't work.
 * They either crash the app or are never delivered.
 */
static long numCompositionCommits = 0;

@implementation DJLipikaClientManager

-(id)initWithClient:(DJLipikaClientDelegate *)theClient {
    self = [super init];
    if (!self) return self;
    numMyCompositionCommits = 0;
    client = theClient;
    candidateManager = [[DJLipikaCandidates alloc] initWithClient:client];
    @try {
        bufferManager = [[DJStringBufferManager alloc] init];
    }
    @catch (NSException *exception) {
        logFatal(@"Error initializing. %@", [exception description]);
        NSBeep();
    }
    return self;
}

-(DJLipikaCandidates *)candidateManager {
    return candidateManager;
}

-(BOOL)inputText:(NSString *)string {
    if (!bufferManager) return NO;
    NSString *previousText;
    // If this is the first character and combine with previous glyph is enabled and client supports TSMDocumentAccess protocol
    if ([DJLipikaUserSettings isCombineWithPreviousGlyph] && [client isDocumentAccessSupported] && ![bufferManager hasDeletable]) {
        previousText = [client previousTextOfLength:[bufferManager maxOutputLength] withOffset:0];
    }
    NSString *commitString = [bufferManager outputForInput:string previousText:previousText];
    if (commitString) [client replaceTextAtCurrentSelection:commitString];
    [self updateCandidates];
    return YES;
}

-(BOOL)handleBackspace {
    if (!bufferManager) return NO;
    // If delete output or if more than one letter is selected then commit the string and let the client delete
    if ([DJLipikaUserSettings backspaceBehavior] == DJ_DELETE_OUTPUT || [client selectedRange].length > 0) {
        [self commit];
        return NO;
    }
    BOOL hasDeletable = [bufferManager hasDeletable];
    // Don't combine with previous character if user setting is off or if the client does not support TSMDocumentAccess protocol
    if (![DJLipikaUserSettings isCombineWithPreviousGlyph] || ![client isDocumentAccessSupported]) {
        [bufferManager delete];
        [self updateCandidates];
        return hasDeletable;
    }
    // The following logic is to combine with previous glyph
    if (!hasDeletable) {
        NSString *previousText = [client previousTextOfLength:[bufferManager maxOutputLength] withOffset:0];
        if (previousText) {
            if (![bufferManager.reverseMappings inputForOutput:previousText]) {
                // Leave out one character and try the remaining
                previousText = [client previousTextOfLength:[bufferManager maxOutputLength] withOffset:1];
                if (![bufferManager.reverseMappings inputForOutput:previousText]) {
                    // This means that the previous two characters are either whitespace, stop character or non-reverse-mappable
                    return NO;
                }
                [bufferManager outputForInput:@"" previousText:previousText];
                // Because we left out the previous char, the following statement will remove it
                [candidateManager showCandidateWithInput:bufferManager.input output:bufferManager.output replacementLength:bufferManager.replacement.length + 1];
                return YES;
            }
            // If previous is reverse mappable then prime the buffer with it and proceed as if you have deletable
            [bufferManager outputForInput:@"" previousText:previousText];
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
        NSString *previousText = [client previousTextOfLength:[bufferManager maxOutputLength] withOffset:0];
        if (previousText) {
            [bufferManager outputForInput:@"" previousText:previousText];
            [self updateCandidates];
        }
    }
    return hasDeletable;
}

-(BOOL)handleCancel {
    if (!bufferManager) return NO;
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
    [client replaceTextAtCurrentSelection:candidateString];
    [bufferManager flush];
    [candidateManager hide];
}

-(void)changeToSchemeWithName:(NSString *)schemeName forScript:scriptName type:(enum DJSchemeType)type {
    [self commit];
    if (!schemeName) schemeName = [DJLipikaUserSettings schemeName];
    if (!scriptName) scriptName = [DJLipikaUserSettings scriptName];
    [bufferManager changeToSchemeWithName:schemeName forScript:scriptName type:type];
    // If no exceptions then change the user settings
    if (type == DJ_GOOGLE) {
        [DJLipikaUserSettings setCustomSchemeName:schemeName];
    }
    else {
        [DJLipikaUserSettings setScriptName:scriptName];
        [DJLipikaUserSettings setSchemeName:schemeName];
    }
    [DJLipikaUserSettings setSchemeType:type];
}

-(void)updateCandidates {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED && numMyCompositionCommits < numCompositionCommits) {
        numMyCompositionCommits = numCompositionCommits;
        [bufferManager flush];
    }
    if ([bufferManager hasOutput]) {
        [candidateManager showCandidateWithInput:bufferManager.input output:bufferManager.output replacementLength:bufferManager.replacement.length];
    }
    else {
        [candidateManager hide];
    }
}

-(void)commit {
    NSString *commitString = [bufferManager flush];
    if (commitString) [client replaceTextAtCurrentSelection:commitString];
    [candidateManager hide];
}

-(void)revert {
    [candidateManager hide];
    NSString *previous = [bufferManager revert];
    if (previous) [client insertTextAtCurrentPosition:previous];
}

@end
