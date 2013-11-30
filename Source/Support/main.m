/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

// Global server so controllers can access it
IMKServer *server = nil;
IMKCandidates* candidates = nil;

int main(int argc, char *argv[]) {
    @autoreleasepool {
        // Initialize the IMK system
        NSString* kConnectionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InputMethodConnectionName"];
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        server = [[IMKServer alloc] initWithName:kConnectionName bundleIdentifier:identifier];
        candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKScrollingGridCandidatePanel];

        // Load the bundle explicitly because the input method is a background only application
        [[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication] topLevelObjects:nil];

        // Run everything
        [[NSApplication sharedApplication] run];
    }

    return 0;
}
