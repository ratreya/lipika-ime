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
#import "Constants.h"

@implementation DJLipikaInputController

extern IMKCandidates* candidates;

/*
 * Overridden methods of IMKInputController
 */
-(id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self == nil) {
        return self;
    }
    manager = [[DJLipikaBufferManager alloc] init];
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

/*
 * IMKServerInput and IMKStateSetting protocol methods
 */
-(BOOL)inputText:(NSString*)string client:(id)sender {
    NSString* commitString = [manager outputForInput:string];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self updateCandidates];
    return YES;
}

-(void)commitComposition:(id)sender {
    NSString* commitString = [manager flush];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [candidates hide];
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    if (aSelector == @selector(deleteBackward:)) {
        // If we deleted something then swallow the delete
        BOOL isDeleted =[manager hasCurrentWord];
        [manager delete];
        [self updateCandidates];
        return isDeleted;
    }
    else if (aSelector == @selector(cancelOperation:)) {
        [manager flush];
    }
    else {
        [self commitComposition:sender];
    }
    return NO;
}

-(NSArray*)candidates:(id)sender {
    NSArray* candidate = [[NSArray alloc] initWithObjects:[manager currentWord], nil];
    return candidate;
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

/*
 * DJLipikaInputController's instance methods
 */
-(void)updateCandidates {
    if ([manager hasCurrentWord]) {
        if (candidates) {
            [candidates updateCandidates];
            [candidates show:kIMKLocateCandidatesBelowHint];
        }
    }
    else {
        [candidates hide];
    }
}

-(void)changeInputScheme:(id)sender {
    // Turn off state for all menu items
    NSArray* peerItems = [[[sender parentItem] submenu] itemArray];
    [peerItems enumerateObjectsUsingBlock:^(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
        [obj setState:NSOffState];
    }];
    // Turn on state for the sender and set selected scheme
    [sender setState:NSOnState];
    [[NSUserDefaults standardUserDefaults] setValue:[sender title] forKey:DEFAULT_SCHEME_NAME_KEY];
    [self commitComposition:[self client]];
    [manager changeToSchemeWithName:[sender title]];
}

-(void)showPreferenceImplimentation:(id)sender {
    NSLog(@"showPreferences");
}

@end
