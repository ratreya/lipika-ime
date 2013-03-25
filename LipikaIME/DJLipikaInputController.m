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

#import "DJLipikaInputController.h"
#import "DJLipikaUserSettings.h"
#import "DJPreferenceController.h"
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
    [[self client] insertText:candidateString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [manager flush];
    [candidates hide];
}

-(NSMenu*)menu {
	return [[NSApp delegate] mainMenu];
}


#pragma mark - IMKServerInput and IMKStateSetting protocol methods

-(BOOL)inputText:(NSString*)string client:(id)sender {
    NSString* commitString = [manager outputForInput:string];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
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
        [self flush];
    }
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    if (aSelector == @selector(deleteBackward:)) {
        // If delete output then commit the string and let the client delete
        if ([DJLipikaUserSettings backspaceBehavior] == DJ_DELETE_OUTPUT) {
            [self flush];
            return NO;
        }
        // If we deleted something then swallow the delete
        BOOL isDeleted = [manager hasDeletable];
        [manager delete];
        [self updateCandidates];
        return isDeleted;
    }
    else if (aSelector == @selector(cancelOperation:)) {
        [manager flush];
        [candidates hide];
        return YES;
    }
    else {
        [self flush];
    }
    return NO;
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
        [self flush];
    }
    else if ([DJLipikaUserSettings unfocusBehavior] == DJ_DISCARD_UNCOMMITTED) {
        [manager flush];
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
    else if ([menuItem tag] > 1) { // Input Schemes
        [self changeInputScheme:menuItem];
    }
    else {
        [NSException raise:@"Unknown tag" format:@"Unknown menu tag: %ld", [menuItem tag]];
    }
}


#pragma mark - DJLipikaInputController's instance methods

-(void)updateCandidates {
    if ([DJLipikaUserSettings unfocusBehavior] == DJ_RESTORE_UNCOMMITTED
            && numMyCompositionCommits < numCompositionCommits) {
        numMyCompositionCommits = numCompositionCommits;
        [manager flush];
    }
    if ([manager hasOutput]) {
        [candidates showCandidateWithInput:[manager input] output:[manager output]];
    }
    else {
        [candidates hide];
    }
}

-(void)changeInputScheme:(NSMenuItem*)menuItem {
    // Turn off state for all menu items
    NSArray* peerItems = [[[menuItem parentItem] submenu] itemArray];
    [peerItems enumerateObjectsUsingBlock:^(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
        [obj setState:NSOffState];
    }];
    // Turn on state for the sender and set selected scheme
    [menuItem setState:NSOnState];
    [DJLipikaUserSettings setSchemeName:[menuItem title]];
    [self flush];
    [manager changeToSchemeWithName:[menuItem title]];
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

-(void)flush {
    NSString* commitString = [manager flush];
    if (commitString) {
        [[self client] insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    [candidates hide];
}

@end
