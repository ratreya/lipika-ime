/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleSchemeFactory.h"
#import <SenTestingKit/SenTestingKit.h>
#import "DJLipikaBufferManager.h"

@interface DJGoogleInputStringText : SenTestCase {
    DJLipikaBufferManager* manager;
}

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine(DJInputMethodEngine *)myEngine;

@end

@implementation DJGoogleInputStringText

-(void)setUp {
    [super setUp];
    DJGoogleInputScheme* scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestMultipleReplay.scm"];
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
    STAssertTrue([@"a" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@"b"];
    STAssertTrue([@"ab" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@"c"];
    STAssertTrue([@"abc" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@"d"];
    STAssertTrue([@"abcd" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@"f"];
    STAssertTrue([@"abcdf" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@"g"];
    STAssertTrue([@"abcdfg" isEqualToString:[manager input]], [NSString stringWithFormat:@"Unexpected input: %@", [manager input]]);
    output = [manager outputForInput:@" "];
    STAssertTrue([output isEqualToString:@"qs "], [NSString stringWithFormat:@"Unexpected output: %@", output]);
}

@end
