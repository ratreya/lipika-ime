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

/*
 * IMKServerInput protocol methods
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

@end
