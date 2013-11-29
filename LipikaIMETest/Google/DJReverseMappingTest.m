/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "DJGoogleSchemeFactory.h"
#import "DJLipikaUserSettings.h"

@interface DJReverseMappingTest : SenTestCase {
    id<DJInputMethodScheme> scheme;
}
@end

@implementation DJReverseMappingTest

-(void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/Google/Schemes/TestHappyCase.scm"];
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
