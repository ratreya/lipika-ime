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

@implementation LipikaIMEEngineTest

- (void)setUp {
    [super setUp];
    scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testHappyCase_SingleChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"a"];
    STAssertTrue([@"अ" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"आ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Chain_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"t"];
    STAssertTrue([@"त्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"r"];
    STAssertTrue([@"र्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"रे" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"री" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");    
}

- (void)testHappyCase_Simple_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ॡ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
}

- (void)testHappyCase_Intermediate_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"ञ" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"i"];
    STAssertTrue([@"ञै" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_IntermediateFinals_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"च्" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"च" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"चौ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Class_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ञू" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_MultiChar_Class_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ञॢ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testStopCharacter {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\\"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
}

-(void)testWhitespace_Space {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@" "];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
}

-(void)testWhitespace_Tab {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\t"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
}

-(void)testWhitespace_Newline {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\n"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
}

-(void)testWhitespace_Return {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\r"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
}

@end
