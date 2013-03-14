/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "LipikaIMEBufferReplayTest.h"

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine*)myEngine;

@end

@implementation LipikaIMEBufferReplayTest

-(void)setUp {
    [super setUp];
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestMultipleReplay.scm"];
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
