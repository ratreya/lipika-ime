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
#import "DJInputEngineFactory.h"

@interface DJGoogleNestedReverseTest : SenTestCase {
    DJGoogleInputScheme* scheme;
    DJInputMethodEngine* engine;
}
@end

@implementation DJGoogleNestedReverseTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestNestedClass.scm"];
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
