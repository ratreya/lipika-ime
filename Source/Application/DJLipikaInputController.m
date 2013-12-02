/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaInputController.h"
#import "DJLipikaUserSettings.h"
#import "DJPreferenceController.h"
#import "DJInputEngineFactory.h"
#import "DJLipikaFileConvertor.h"
#import "DJLogger.h"
#import "Constants.h"

/*
 * Using this technique because for some unknown reason notifications don't work.
 * They either crash the app or are never delivered.
 */
static long numCompositionCommits = 0;

@implementation DJLipikaInputController

#pragma mark - Overridden methods of IMKInputController

-(id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self == nil) {
        return self;
    }
    manager = [[DJLipikaBufferManager alloc] init];
    candidates = [[DJLipikaCandidates alloc] initWithController:self];
    numMyCompositionCommits = 0;
    return self;
}

-(void)candidateSelected:(NSAttributedString*)candidateString {
    [[self client] insertText:candidateString replacementRange:[[self client] selectedRange]];
    [manager flush];
    [candidates hide];
}

-(NSMenu*)menu {
	return [[NSApp delegate] mainMenu];
}


#pragma mark - IMKServerInput and IMKStateSetting protocol methods

-(BOOL)inputText:(NSString*)string client:(id)sender {
    NSString *previousText;
    // If this is the first character and combine with previous glyph is enabled
    if ([DJLipikaUserSettings isCombineWithPreviousGlyph] && ![manager hasDeletable]) {
        previousText = [self previousText];
    }
    NSString *commitString = [manager outputForInput:string previousText:previousText];
    if (commitString) [sender insertText:commitString replacementRange:[sender selectedRange]];
    [self updateCandidates];
    return YES;
}

-(void)commitComposition:(id)sender {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        ++numCompositionCommits;
        /*
         * We are discarding uncommitted changes for DJ_RESTORE_UNCOMMITTED so as to
         * achieve consistent behavior on all controllers including background ones
         */
        [manager flush];
    }
    else {
        [self commit];
    }
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    if (aSelector == @selector(deleteBackward:)) {
        return [self handleBackspaceForSender:sender];
    }
    else if (aSelector == @selector(cancelOperation:)) {
        [self revert];
        [candidates hide];
        return YES;
    }
    else {
        [self commit];
    }
    return NO;
}

-(NSArray *)candidates:(id)sender {
    return [candidates candidates:sender];
}

// This message is sent when our client gains focus
-(void)activateServer:(id)sender {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        // Activate sometimes gets called before deactivate
        [candidates hide];
        // updateCandidates on the next run-loop
        // IMK needs to do its thing on the current run-loop
        [self performSelector:@selector(updateCandidates) withObject:self afterDelay:0];
    }
}

// This message is sent when our client looses focus
-(void)deactivateServer:(id)sender {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_COMMIT_UNCOMMITTED) {
        [self commit];
    }
    else if ([DJLipikaUserSettings unfocusBehavior] == DJ_DISCARD_UNCOMMITTED) {
        [self revert];
    }
    else if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED) {
        [candidates hide];
    }
}

-(IBAction)showPreferences:(id)sender {
/*
 sender is a NSDictionary object with the following keys:
 {
    IMKCommandClient = "<IMKInputSession>";
    IMKCommandMenuItem = "<NSMenuItem>";
    IMKMenuTitle = "<NSString>";
 }
 */
    NSMenuItem* menuItem = [sender valueForKey:@"IMKCommandMenuItem"];
    if ([menuItem tag] == 1) {     // Preferrence
        [self showPreferenceImplimentation:menuItem];
    }
    else if ([menuItem tag] == 2) { // Convert file
        [DJLipikaFileConvertor convert];
    }
    else if ([menuItem tag] > 2) { // Input Schemes
        [self changeInputScheme:menuItem];
    }
    else {
        [NSException raise:@"Unknown tag" format:@"Unknown menu tag: %ld", [menuItem tag]];
    }
}


#pragma mark - DJLipikaInputController's instance methods

-(BOOL)handleBackspaceForSender:(id)sender {
    // If delete output or if more than one letter is selected then commit the string and let the client delete
    if ([DJLipikaUserSettings backspaceBehavior] == DJ_DELETE_OUTPUT || [sender selectedRange].length > 0) {
        [self commit];
        return NO;
    }
    BOOL isHandled = [manager hasDeletable];
    if (!isHandled && [DJLipikaUserSettings isCombineWithPreviousGlyph]) {
        NSString *previousText = [self previousText];
        if (previousText) {
            if ([manager outputForInput:@"" previousText:previousText]) {
                // This means that the previous character is either whitespace, stop character or non-reverse-mappable
                NSRange replacementRange = [sender selectedRange];
                replacementRange.location -= 1;
                replacementRange.length += 1;
                [sender setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:replacementRange];
                isHandled = YES;
            }
            else {
                [self updateCandidates];
                return YES;
            }
        }
        else {
            return NO;
        }
    }
    [manager delete];
    [self updateCandidates];
    // If there are no more deletables then pre-parse previous text
    if (![manager hasDeletable] && [DJLipikaUserSettings isCombineWithPreviousGlyph]) {
        NSString *previousText = [self previousText];
        if (previousText) {
            [manager outputForInput:@"" previousText:previousText];
            [self updateCandidates];
        }
    }
    // If we deleted something then swallow the delete
    return isHandled;
}

-(NSString*)previousText {
    NSString *previousText = nil;
    NSRange currentPosition = [[self client] selectedRange];
    if (currentPosition.location != NSNotFound && currentPosition.location > 0) {
        int length = MIN(currentPosition.location, [manager maxOutputLength]);
        previousText = [[[self client] attributedSubstringFromRange:NSMakeRange(currentPosition.location - length, length)] string];
    }
    return previousText;
}

-(void)updateCandidates {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED && numMyCompositionCommits < numCompositionCommits) {
        numMyCompositionCommits = numCompositionCommits;
        [manager flush];
    }
    if ([manager hasOutput]) {
        [candidates showCandidateWithInput:[manager input] output:[manager output] replacement:[manager replacement]];
    }
    else {
        [candidates hide];
    }
}

-(void)clearAllOnStates:(NSMenu*)rootMenu {
    NSArray* peerItems = [rootMenu itemArray];
    [peerItems enumerateObjectsUsingBlock:^(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
        [obj setState:NSOffState];
        if ([obj hasSubmenu]) [self clearAllOnStates:[obj submenu]];
    }];
}

-(void)changeInputScheme:(NSMenuItem*)menuItem {
    BOOL isGoogleItem = [[[menuItem parentItem] title] isEqualToString:@"GoogleSubMenu"];
    BOOL isSchemeItem = [[[menuItem parentItem] title] isEqualToString:@"SchemeSubMenu"];
    BOOL isScriptItem = [[[menuItem parentItem] title] isEqualToString:@"ScriptSubMenu"];
    if (isGoogleItem) {
        [self clearAllOnStates:[NSApp mainMenu]];
    }
    else if (isScriptItem || isSchemeItem) {
        // Clear state of all sub-menus under "Input scheme" or "Output script" menu item
        [self clearAllOnStates:[[menuItem parentItem] submenu]];
    }
    else {
        [NSException raise:@"Unknown menu item" format:@"Menu parent title %@ not recognized", [[menuItem parentItem] title]];
    }
    // Turn on state for the script and scheme
    [menuItem setState:NSOnState];
    [self commit];
    NSString *name = [menuItem title];
    if (isSchemeItem) {
        [manager changeToSchemeWithName:name forScript:[DJInputEngineFactory currentScriptName] type:LIPIKA];
    }
    else if (isScriptItem) {
        [manager changeToSchemeWithName:[DJInputEngineFactory currentSchemeName] forScript:name type:LIPIKA];
    }
    else if (isGoogleItem) {
        [manager changeToSchemeWithName:name forScript:nil type:GOOGLE];
    }
}

-(void)showPreferenceImplimentation:(NSMenuItem*)menuItem {
    static DJPreferenceController* preference;
    if (!preference) {
        preference = [[DJPreferenceController alloc] initWithWindowNibName:@"Preferences"];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [[preference window] makeKeyAndOrderFront:self];
    [preference showWindow:self];
}

-(void)commit {
    NSString* commitString = [manager flush];
    if (commitString) {
        [[self client] insertText:commitString replacementRange:[[self client] selectedRange]];
    }
    [candidates hide];
}

-(void)revert {
    NSString *previous = [manager revert];
    if (previous) [[self client] insertText:previous replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

@end
