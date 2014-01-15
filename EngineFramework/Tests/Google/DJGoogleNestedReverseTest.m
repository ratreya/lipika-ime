/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJGoogleSchemeFactory.h"
#import "DJInputMethodEngine.h"

@interface DJInputMethodEngine (Test)

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;

@end

@interface DJGoogleNestedReverseTest : XCTestCase {
    DJGoogleInputScheme* scheme;
    DJInputMethodEngine* engine;
}
@end

@implementation DJGoogleNestedReverseTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./EngineFramework/Tests/Google/Schemes/TestNestedClass.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

-(void)testHappyCase {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"zfc"];
    XCTAssertEqualObjects(@"zfc",  result.input, @"Unexpected output: %@", result.input);
    XCTAssertEqualObjects(@"zfc",  result.output, @"Unexpected output: %@", result.output);
}

-(void)testNestedNoPrekey {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"zdh"];
    XCTAssertEqualObjects(@"zhd",  result.input, @"Unexpected output: %@", result.input);
    XCTAssertEqualObjects(@"zdh",  result.output, @"Unexpected output: %@", result.output);
}

@end
