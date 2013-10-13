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

#import "LipikaIMENestedClassTest.h"
#import "DJInputSchemeFactory.h"
#import "DJInputMethodEngine.h"

@implementation LipikaIMENestedClassTest

- (void)setUp {
    [super setUp];
    scheme = [DJInputSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestNestedClass.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testNestedClassParsing {
    STAssertTrue([@"test1" isEqualToString:[scheme.forwardMappings classNameForInput:@"c"]], @"Unexpected class name");
    STAssertTrue([@"test2" isEqualToString:[scheme.forwardMappings classNameForInput:@"f"]], @"Unexpected class name");
    STAssertTrue([[scheme.forwardMappings classForName:@"test1"] count] == 3, @"Unexpected count of mappings");
    STAssertTrue([[scheme.forwardMappings classForName:@"test2"] count] == 3, @"Unexpected count of mappings");
}

-(void)testHappyCase_Simple_NestedClass {
    NSArray* result = [engine executeWithInput:@"z"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"zfc" isEqualToString:[result[0] output]], [NSString stringWithFormat: @"Unexpected output: %@", [result[0] output]]);
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testInvalidCase_Simple_NestedClass {
    NSArray* result = [engine executeWithInput:@"z"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    STAssertTrue([result[0] output] == nil, @"Unexpected output");
    STAssertFalse([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"zfc" isEqualToString:[result[0] output]], @"Unexpected output: %@", [result[0] output]);
    STAssertTrue([result[0] isFinal], @"Unexpected output");
    STAssertFalse([result[0] isPreviousFinal], @"Unexpected output");
}

-(void)testNestedNoPrekey {
    NSArray* result = [engine executeWithInput:@"zhd"];
    STAssertTrue([@"zdh" isEqualToString:[result[2] output]], @"Unexpected output: %@", [result[2] output]);
}

@end
