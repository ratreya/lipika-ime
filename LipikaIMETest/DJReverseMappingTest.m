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
#import "DJLipikaUserSettings.h"

@interface DJReverseMappingTest : SenTestCase {
    DJInputMethodScheme* scheme;
}
@end

@implementation DJReverseMappingTest

-(void)setUp {
    [super setUp];
    scheme = [DJInputSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Schemes/TestHappyCase.scm"];
}

-(void)testHapyCase {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"ञी"];
    STAssertTrue([result.output isEqualToString: @"ञी"], [NSString stringWithFormat: @"Unexpected output %@", result.output]);
    STAssertTrue([result.input isEqualToString: @"~jI"] , [NSString stringWithFormat: @"Unexpected output %@", result.input]);
}

-(void)testCompletelyReversed {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"रि"];
    STAssertTrue([result.output isEqualToString: @"रि"], [NSString stringWithFormat: @"Unexpected output %@", result.output]);
    STAssertTrue([result.input isEqualToString: @"ri"] , [NSString stringWithFormat: @"Unexpected output %@", result.input]);
}

-(void)testPartiallyReversed {
    DJParseOutput *result = [scheme.reverseMappings inputForOutput:@"दैव"];
    STAssertTrue([result.output isEqualToString: @"व"], [NSString stringWithFormat: @"Unexpected output %@", result.output]);
    STAssertTrue([result.input isEqualToString: @"va"] , [NSString stringWithFormat: @"Unexpected output %@", result.input]);
}

@end
