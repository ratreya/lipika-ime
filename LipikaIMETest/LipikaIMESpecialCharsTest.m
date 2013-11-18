/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "LipikaIMESpecialCharsTest.h"
#import "DJGoogleSchemeFactory.h"

@implementation LipikaIMESpecialCharsTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestSpecialChars.scm"];
}

// Ignoring for now; @ symbol does not work; Issue: #1
- (void)XXXtestSpecialCharacterParsing {
    // Removed @ @ from TestSpecialChars.scm for the sake of running other tests
    // Add it back in after this bug is fixed
    STAssertTrue(scheme != nil, @"Unable to parse special characters");
}

- (void)testWindowsCRLF {
    STAssertTrue(scheme != nil, @"Unable to parse special characters");
}

@end
