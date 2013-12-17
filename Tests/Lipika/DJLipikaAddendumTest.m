/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJLipikaSchemeFactory.h"
#import "DJLipikaBufferManager.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString *)directory;

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@interface DJLipikaAddendumTest : XCTestCase

@end

@implementation DJLipikaAddendumTest

-(void)setUp {
    [super setUp];
    [DJLipikaSchemeFactory setSchemesDirectory:@"/Users/ratreya/workspace/Lipika_IME/Tests/Lipika/Schemes"];
}

-(void)testHappyCase {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Hindi" scheme:@"Hindi"];
    DJInputMethodEngine *engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    DJLipikaBufferManager *manager = [[DJLipikaBufferManager alloc] initWithEngine:engine];
    [manager outputForInput:@"k"];
    XCTAssertEqualObjects([manager output], @"क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"ka"];
    XCTAssertEqualObjects([manager output], @"क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kk"];
    XCTAssertEqualObjects([manager output], @"क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kka"];
    XCTAssertEqualObjects([manager output], @"क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkk"];
    XCTAssertEqualObjects([manager output], @"क्क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkka"];
    XCTAssertEqualObjects([manager output], @"क्क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kakki"];
    XCTAssertEqualObjects([manager output], @"कक्कि", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkhg"];
    XCTAssertEqualObjects([manager output], @"क्ख्ग", @"Invalid output");
    [manager flush];
}

@end
