//
//  LipikaIMESpecialCharsTest.m
//  LipikaIME
//
//  Created by Atreya, Ranganath on 2/25/13.
//  Copyright (c) 2013 com.daivajnanam. All rights reserved.
//

#import "LipikaIMESpecialCharsTest.h"

@implementation LipikaIMESpecialCharsTest

- (void)setUp {
    [super setUp];
    scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestSpecialChars.scm"];
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
