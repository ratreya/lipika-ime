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

#import "LipikaIMEEngineTest.h"
#import "DJInputSchemeFactory.h"

@implementation LipikaIMEEngineTest

- (void)setUp {
    [super setUp];
    scheme = [DJInputSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestHappyCase.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testHappyCase_SingleChar_Mapping {
    NSArray* result = [engine executeWithInput:@"a"];
    STAssertTrue([@"अ" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"आ" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertTrue([result[0] isFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Chain_Mapping {
    NSArray* result = [engine executeWithInput:@"t"];
    STAssertTrue([@"त्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"r"];
    STAssertTrue([@"र्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertTrue([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"रे" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"री" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");    
}

- (void)testHappyCase_Simple_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ॡ" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertTrue([result[0] isFinal], @"Unexpected output");
}

- (void)testHappyCase_Intermediate_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"ञ" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"i"];
    STAssertTrue([@"ञै" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_IntermediateFinals_MultiChar_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"च्" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertTrue([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"च" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"चौ" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Class_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ञू" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_MultiChar_Class_Mapping {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result[0] output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ञॢ" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testStopCharacter {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\\"];
    STAssertTrue([@"\\" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
}

-(void)testWhitespace_Space {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@" "];
    STAssertTrue([@" " isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
}

-(void)testWhitespace_Tab {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\t"];
    STAssertTrue([@"\t" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
}

-(void)testWhitespace_Newline {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\n"];
    STAssertTrue([@"\n" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
}

-(void)testWhitespace_Return {
    NSArray* result = [engine executeWithInput:@"~"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result[0] output]], @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\r"];
    STAssertTrue([@"\r" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
}

@end
