/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleSchemeFactory.h"
#import <XCTest/XCTest.h>
#import "DJGoogleInputScheme.h"

@interface DJGoogleSpecialCharsTest : XCTestCase {
    DJGoogleInputScheme* scheme;
}

@end

@implementation DJGoogleSpecialCharsTest

- (void)setUp {
    [super setUp];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"GoogleSchemes/TestSpecialChars.scm"];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
}

- (void)testSpecialCharacterParsing {
    XCTAssertTrue(scheme != nil, @"Unable to parse special characters");
}

- (void)testWindowsCRLF {
    XCTAssertTrue(scheme != nil, @"Unable to parse special characters");
}

@end
