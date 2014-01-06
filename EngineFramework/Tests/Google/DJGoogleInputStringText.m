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
#import "DJLipikaBufferManager.h"

@interface DJGoogleInputStringText : XCTestCase {
    DJLipikaBufferManager* manager;
}

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@implementation DJGoogleInputStringText

-(void)setUp {
    [super setUp];
    DJGoogleInputScheme* scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./EngineFramework/Tests/Google/Schemes/TestMultipleReplay.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    manager = [[DJLipikaBufferManager alloc] initWithEngine:engine];
}

-(void)tearDown {
    [manager flush];
    [super tearDown];
}

-(void)testHappyCase_NilOutput {
    // abcdf should output pqs
    NSString* output = [manager outputForInput:@"a"];
    XCTAssertEqualObjects(@"a", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@"b"];
    XCTAssertEqualObjects(@"ab", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@"c"];
    XCTAssertEqualObjects(@"abc", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@"d"];
    XCTAssertEqualObjects(@"abcd", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@"f"];
    XCTAssertEqualObjects(@"abcdf", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@"g"];
    XCTAssertEqualObjects(@"abcdfg", [manager input], @"Unexpected input: %@", [manager input]);
    output = [manager outputForInput:@" "];
    XCTAssertEqualObjects(output, @"qs ", @"Unexpected output: %@", output);
}

@end
