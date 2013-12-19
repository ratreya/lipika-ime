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
#import "DJInputMethodEngine.h"

@interface DJGoogleEngineTest : XCTestCase {
    DJGoogleInputScheme* scheme;
    DJInputMethodEngine* engine;
}

@end

@implementation DJGoogleEngineTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestHappyCase.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testHappyCase_SingleChar_Mapping {
    NSArray* result = [engine executeWithInput:@"a"];
    XCTAssertEqualObjects(@"अ", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    XCTAssertEqualObjects(@"आ", [result[0] output], @"Unexpected output");
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Chain_Mapping {
    NSArray* result = [engine executeWithInput:@"t"];
    XCTAssertEqualObjects(@"त्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"r"];
    XCTAssertEqualObjects(@"र्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertTrue([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    XCTAssertEqualObjects(@"रे", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    XCTAssertEqualObjects(@"री", [result[0] output], @"Unexpected output");
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");    
}

- (void)testHappyCase_Simple_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    XCTAssertEqualObjects(@"ॡ", [result[0] output], @"Unexpected output");
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
}

- (void)testHappyCase_Intermediate_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    XCTAssertEqualObjects(@"ञ", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"i"];
    XCTAssertEqualObjects(@"ञै", [result[0] output], @"Unexpected output");
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_IntermediateFinals_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    XCTAssertEqualObjects(@"च्", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertTrue([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    XCTAssertEqualObjects(@"च", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    XCTAssertEqualObjects(@"चौ", [result[0] output], @"Unexpected output");
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Class_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    XCTAssertEqualObjects(@"ञू", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_MultiChar_Class_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output: %@", [result[0] output]);
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output: %@", [result[0] output]);
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    XCTAssertEqualObjects(@"ञॢ", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    XCTAssertTrue([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testStopCharacter {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\\"];
    XCTAssertEqualObjects(@"", [result[0] output], @"Unexpected output: %@", [result[0] output]);
    result = [engine executeWithInput:@"\\"];
    XCTAssertEqualObjects(@"\\", [result[0] output], @"Unexpected output: %@", [result[0] output]);
}

-(void)testWhitespace_Space {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@" "];
    XCTAssertEqualObjects(@" ", [result[0] output], @"Unexpected output: %@", [result[0] output]);
}

-(void)testWhitespace_Tab {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\t"];
    XCTAssertEqualObjects(@"\t", [result[0] output], @"Unexpected output: %@", [result[0] output]);
}

-(void)testWhitespace_Newline {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\n"];
    XCTAssertEqualObjects(@"\n", [result[0] output], @"Unexpected output: %@", [result[0] output]);
}

-(void)testWhitespace_Return {
    NSArray* result = [engine executeWithInput:@"~"];
    XCTAssertTrue([result[0] output] == nil, @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    XCTAssertEqualObjects(@"ञ्", [result[0] output], @"Unexpected output");
    XCTAssertFalse([result[0] isFinal], @"Unexpected output");
    XCTAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\r"];
    XCTAssertEqualObjects(@"\r", [result[0] output], @"Unexpected output: %@", [result[0] output]);
}

@end
