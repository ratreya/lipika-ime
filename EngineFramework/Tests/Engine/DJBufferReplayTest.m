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
#import "DJStringBufferManager.h"

@interface DJGoogleBufferReplayTest : XCTestCase {
    DJStringBufferManager* manager;
}

@end

@interface DJStringBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@interface DJInputMethodEngine (Test)

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;

@end

@implementation DJGoogleBufferReplayTest

-(void)setUp {
    [super setUp];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"GoogleSchemes/TestMultipleReplay.scm"];
    DJGoogleInputScheme* scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    manager = [[DJStringBufferManager alloc] initWithEngine:engine];
}

-(void)tearDown {
    [manager flush];
    [super tearDown];
}

-(void)testHappyCase_Replay {
    // abcdf should output pqs
    NSString* output = [manager outputForInput:@"a"];
    output = [manager outputForInput:@"b"];
    output = [manager outputForInput:@"c"];
    output = [manager outputForInput:@"d"];
    output = [manager outputForInput:@"f"];
    output = [manager outputForInput:@"g"];
    output = [manager outputForInput:@" "];
    XCTAssertEqualObjects(output, @"qs ", @"Unexpected output: %@", output);
}

-(void)testHappyCase_Multiple_Replay {
    // abcdfh should output pqt
    NSString* output = [manager outputForInput:@"a"];
    output = [manager outputForInput:@"b"];
    output = [manager outputForInput:@"c"];
    output = [manager outputForInput:@"d"];
    output = [manager outputForInput:@"f"];
    output = [manager outputForInput:@"h"];
    output = [manager outputForInput:@" "];
    XCTAssertEqualObjects(output, @"qt ", @"Unexpected output: %@", output);
}

@end
