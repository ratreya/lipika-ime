/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleSchemeFactory.h"
#import "DJInputMethodEngine.h"
#import <XCTest/XCTest.h>
#import "DJGoogleInputScheme.h"
#import "DJInputMethodEngine.h"

@interface DJGoogleNestedClassTest : XCTestCase {
    DJGoogleInputScheme* scheme;
    DJInputMethodEngine* engine;
}

@end

@interface DJInputMethodEngine (Test)

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;

@end

@implementation DJGoogleNestedClassTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./EngineFramework/Tests/Google/Schemes/TestNestedClass.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testNestedClassParsing {
    XCTAssertEqualObjects(@"test1", [scheme.forwardMappings classNameForInput:@"c"], @"Unexpected class name");
    XCTAssertEqualObjects(@"test2", [scheme.forwardMappings classNameForInput:@"f"], @"Unexpected class name");
    XCTAssertTrue([[scheme.forwardMappings classForName:@"test1"].trieHead.next count] == 3, @"Unexpected count of mappings");
    XCTAssertTrue([[scheme.forwardMappings classForName:@"test2"].trieHead.next count] == 3, @"Unexpected count of mappings");
}

-(void)testHappyCase_Simple_NestedClass {
    NSArray* result = [engine executeWithInput:@"z"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    XCTAssertNil([result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    XCTAssertEqualObjects(@"zfc", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testInvalidCase_Simple_NestedClass {
    NSArray* result = [engine executeWithInput:@"z"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    XCTAssertNil([result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    XCTAssertEqualObjects(@"zfc", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testNestedNoPrekey {
    NSArray* result = [engine executeWithInput:@"zhd"];
    XCTAssertEqualObjects(@"zdh", [result[2] output], @"Unexpected output: %@", [result[2] output]);
}

@end
