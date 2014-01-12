/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJStringBufferManager.h"
#import "DJLipikaUserSettings.h"
#import "DJGoogleSchemeFactory.h"

@interface DJGoogleBufferManagerTest : XCTestCase {
    DJStringBufferManager* manager;
}

@end

@interface DJStringBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@implementation DJGoogleBufferManagerTest

-(void)setUp {
    [super setUp];
    DJGoogleInputScheme* scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./EngineFramework/Tests/Google/Schemes/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    manager = [[DJStringBufferManager alloc] initWithEngine:engine];
}

-(void)tearDown {
    [manager outputForInput:@" "];
    [super tearDown];
}

-(void)testHappyCase_Chain_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(@"त्री ", result, @"Unexpected output: %@", result);
}

-(void)testHappyCase_Chain_Class_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(@"ता ", result, @"Unexpected output: %@", result);
}

-(void)testHappyCase_Chain_Space_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(@"त्रे ", result, @"Unexpected output: %@", result);
}

-(void)testHappyCase_Special_Chain_Mapping {
    NSString* result = [manager outputForInput:@"r"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"रङ्ग ", @"Unexpected output: %@", result);
}

-(void)testHappyCase_Intermediate_Blank_Chain_Mapping {
    NSString* result = [manager outputForInput:@"j"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"j"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(@"ज्ञ ", result, @"Unexpected output: %@", result);
}

-(void)testStopCharacter {
    NSString* result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"\\"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    XCTAssertEqualObjects([manager output], @"ञ्", @"Unexpected output: %@", [manager output]);
    result = [manager outputForInput:@"\\"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    XCTAssertEqualObjects([manager output], @"ञ्\\", @"Unexpected output: %@", [manager output]);
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ञ्\\ ", @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"l"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ऌ ", @"Unexpected output: %@", result);
}

-(void)testEchoNonOuputtingInput {
    NSString* result = [manager outputForInput:@"~~ "];
    XCTAssertEqualObjects(@"~~ ", result, @"Unexpected output: %@", result);
}

-(void)testWhitespace_Space {
    NSString* result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ञ् ", @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"l"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ऌ ", @"Unexpected output: %@", result);
}

-(void)testWhitespace_Tab {
    NSString* result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"\t"];
    XCTAssertEqualObjects(result, @"ञ्\t", @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"l"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ऌ ", @"Unexpected output: %@", result);
}

-(void)testWhitespace_Newline {
    NSString* result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"\n"];
    XCTAssertEqualObjects(result, @"ञ्\n", @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"l"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ऌ ", @"Unexpected output: %@", result);
}

-(void)testWhitespace_Return {
    NSString* result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"\r"];
    XCTAssertEqualObjects(result, @"ञ्\r", @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"l"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    XCTAssertEqualObjects(result, @"ऌ ", @"Unexpected output: %@", result);
}

-(void)testDeleteInput {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    NSString* result = [manager outputForInput:@"rai"];
    XCTAssertNil(result, @"Unexpected output: %@", result);
    XCTAssertEqualObjects([manager output], @"रै", @"Unexpected output: %@", [manager output]);
    [manager delete];
    XCTAssertEqualObjects([manager input], @"ra", @"Unexpected output: %@", [manager input]);
    XCTAssertEqualObjects([manager output], @"र", @"Unexpected output: %@", [manager output]);
    [manager delete];
    XCTAssertEqualObjects([manager input], @"r", @"Unexpected output: %@", [manager input]);
    XCTAssertEqualObjects([manager output], @"र्", @"Unexpected output: %@", [manager output]);
}

-(void)testCombineAfterDelete {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"vRuddhi"];
    XCTAssertEqualObjects([manager output], @"वृद्धि", @"Unexpected output: %@", [manager output]);
    [manager delete];
    XCTAssertEqualObjects([manager output], @"वृद्ध्", @"Unexpected output: %@", [manager output]);
    [manager outputForInput:@"k"];
    XCTAssertEqualObjects([manager output], @"वृद्ध्क्", @"Unexpected output: %@", [manager output]);
    [manager delete];
    XCTAssertEqualObjects([manager output], @"वृद्ध्", @"Unexpected output: %@", [manager output]);
    [manager outputForInput:@"u"];
    XCTAssertEqualObjects([manager output], @"वृद्धु", @"Unexpected output: %@", [manager output]);
}

-(void)testCombineAfterDeleteNonMappableChar {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"guNavRi"];
    XCTAssertEqualObjects([manager output], @"गुणव्Ri", @"Unexpected output: %@", [manager output]);
    [manager delete];
    [manager delete];
    [manager outputForInput:@"Ru"];
    XCTAssertEqualObjects([manager output], @"गुणवृ", @"Unexpected output: %@", [manager output]);
}

-(void)testPartialParseStopCharacter {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"guNavRi"];
    XCTAssertEqualObjects([manager output], @"गुणव्Ri", @"Unexpected output: %@", [manager output]);
    [manager delete];
    [manager outputForInput:@"\\"];
    XCTAssertEqualObjects([manager output], @"गुणव्R", @"Unexpected output: %@", [manager output]);
}

@end
