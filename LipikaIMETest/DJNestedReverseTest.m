/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
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
