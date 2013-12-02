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

@interface DJGoogleBufferReplayTest : SenTestCase {
    DJLipikaBufferManager* manager;
}

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine*)myEngine;

@end

@implementation DJGoogleBufferReplayTest

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

-(void)testHappyCase_Replay {
    // abcdf should output pqs
    NSString* output = [manager outputForInput:@"a"];
    output = [manager outputForInput:@"b"];
    output = [manager outputForInput:@"c"];
    output = [manager outputForInput:@"d"];
    output = [manager outputForInput:@"f"];
    output = [manager outputForInput:@"g"];
    output = [manager outputForInput:@" "];
    STAssertTrue([output isEqualToString:@"qs "], [NSString stringWithFormat:@"Unexpected output: %@", output]);
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
    STAssertTrue([output isEqualToString:@"qt "], [NSString stringWithFormat:@"Unexpected output: %@", output]);
}

@end
