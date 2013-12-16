/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJTrieNode.h"
#import <XCTest/XCTest.h>
#import "DJGoogleSchemeFactory.h"

@interface DJGoogleForwardMapping (Test)

-(DJReadWriteTrie *)parseTrie;

@end

@interface DJGoogleSchemeTest : XCTestCase {
    DJGoogleInputScheme *scheme;
}

@end

@implementation DJGoogleSchemeTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestHappyCase.scm"];
}

- (void)testHeaderParsing {
    XCTAssertTrue([@"1.0" isEqualTo:[scheme version]], @"Version numbers don't match");
    XCTAssertTrue([@"Barahavat" isEqualTo:[scheme name]], @"Names don't match");
    XCTAssertTrue([@"\\" isEqualTo:[scheme stopChar]], @"Stop Characters dos't match");
    XCTAssertTrue([scheme usingClasses], @"Using Classes don't match");
    XCTAssertEqualObjects(@"{", [scheme classOpenDelimiter], @"Class open delimiters don't match");
    XCTAssertEqualObjects(@"}", [scheme classCloseDelimiter], @"Class close delimiters don't match");
    XCTAssertEqualObjects(@"*", [scheme wildcard], @"Wildcards don't match");
}

- (void)testClassParsing {
    XCTAssertEqualObjects(@"VowelSigns", [scheme.forwardMappings classNameForInput:@"A"], @"Unexpected class name");
    XCTAssertTrue([[scheme.forwardMappings classForName:@"VowelSigns"].trieHead.next count] == 12, @"Unexpected count of mappings: %lu", (unsigned long)[[scheme.forwardMappings classForName:@"VowelSigns"].trieHead.next count]);
}

- (void)testMappingParsing {
    NSString* output = [scheme.forwardMappings.parseTrie nodeForKey:@"~j"].value;
    XCTAssertEqualObjects(output,  @"ञ्", @"Unexpected output");
    output = [scheme.forwardMappings.parseTrie nodeForKey:@"~jI"].value;
    XCTAssertEqualObjects(output,  @"ञी", @"Unexpected output: %@", output);
}

-(void)testNonDefaultHeaders {
    DJGoogleInputScheme *myScheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestITRANS.scm"];
    XCTAssertEqualObjects(@"VowelSigns", [myScheme.forwardMappings classNameForInput:@"u"], @"Unexpected output");
    NSString* output = [scheme.forwardMappings.parseTrie nodeForKey:@"~j"].value;
    XCTAssertEqualObjects(output,  @"ञ्", @"Unexpected output");
    output = [scheme.forwardMappings.parseTrie nodeForKey:@"~jI"].value;
    XCTAssertEqualObjects(output,  @"ञी", @"Unexpected output: %@", output);
}

@end
