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

#import <SenTestingKit/SenTestingKit.h>
#import "DJInputSchemeFactory.h"
#import "DJInputEngineFactory.h"

@interface DJNestedReverseTest : SenTestCase {
    DJInputMethodScheme* scheme;
    DJInputMethodEngine* engine;
}
@end

@implementation DJNestedReverseTest

- (void)setUp {
    [super setUp];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CombineWithPreviousGlyph"];
    scheme = [DJInputSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestNestedClass.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

-(void)testHappyCase {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"zfc"];
    STAssertTrue([@"zfc" isEqualToString: result.input], @"Unexpected output: %@", result.input);
    STAssertTrue([@"zfc" isEqualToString: result.output], @"Unexpected output: %@", result.output);
}

-(void)testNestedNoPrekey {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"zdh"];
    STAssertTrue([@"zhd" isEqualToString: result.input], @"Unexpected output: %@", result.input);
    STAssertTrue([@"zdh" isEqualToString: result.output], @"Unexpected output: %@", result.output);
}

@end
