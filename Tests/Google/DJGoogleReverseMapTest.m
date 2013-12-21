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
#import "DJLipikaUserSettings.h"

@interface DJGoogleReverseMapTest : XCTestCase {
    id<DJInputMethodScheme> scheme;
}
@end

@implementation DJGoogleReverseMapTest

-(void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./Tests/Google/Schemes/TestHappyCase.scm"];
}

-(void)testHapyCase {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"ञी"];
    XCTAssertEqualObjects(result.output,  @"ञी", @"Unexpected output %@", result.output);
    XCTAssertEqualObjects(result.input, @"~jee", @"Unexpected output %@", result.input);
}

-(void)testCompletelyReversed {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"रि"];
    XCTAssertEqualObjects(result.output,  @"रि", @"Unexpected output %@", result.output);
    XCTAssertEqualObjects(result.input, @"ri", @"Unexpected output %@", result.input);
}

-(void)testPartiallyReversed {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"दैव"];
    XCTAssertEqualObjects(result.output,  @"व", @"Unexpected output %@", result.output);
    XCTAssertEqualObjects(result.input, @"va", @"Unexpected output %@", result.input);
}

@end
