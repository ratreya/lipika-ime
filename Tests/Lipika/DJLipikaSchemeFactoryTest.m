/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJLipikaSchemeFactory.h"
#import "DJLipikaBufferManager.h"
#import "DJTestHelper.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString *)directory;

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@interface DJSimpleForwardMapping (Test)

-(NSDictionary *)parseTrie;

@end

@interface DJLipikaSchemeFactoryTest : XCTestCase

@end

@implementation DJLipikaSchemeFactoryTest

-(void)setUp {
    [super setUp];
    [DJLipikaSchemeFactory setSchemesDirectory:@"/Users/ratreya/workspace/Lipika_IME/Schemes"];
}

-(void)testHappyCase {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Devanagari" scheme:@"Baraha"];
    XCTAssertNotNil(scheme, @"Unexpected result");
    DJSimpleForwardMapping *forwardMappings = scheme.forwardMappings;
    NSString *output = [forwardMappings.parseTrie nodeForKey:@"~j"].value;
    XCTAssertEqualObjects(output,  @"ञ्", @"Unexpected output");
    output = [forwardMappings.parseTrie nodeForKey:@"~jI"].value;
    XCTAssertEqualObjects(output,  @"ञी", @"Unexpected output: %@", output);
}

-(void)testSchemeOverrides {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Devanagari" scheme:@"Baraha"];
    XCTAssertNotNil(scheme, @"Unexpected result");
    DJSimpleForwardMapping *forwardMappings = scheme.forwardMappings;
    NSString *output = [forwardMappings.parseTrie nodeForKey:@"~j"].value;
    XCTAssertEqualObjects(output,  @"ञ्", @"Unexpected output");
    output = [forwardMappings.parseTrie nodeForKey:@"~jI"].value;
    XCTAssertEqualObjects(output,  @"ञी", @"Unexpected output: %@", output);
}

-(void)XXXtestLoadingCurrentIMEs {
    for (NSString *schemeName in [DJLipikaSchemeFactory availableSchemes]) {
        for (NSString *scriptName in [DJLipikaSchemeFactory availableScripts]) {
            DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:scriptName scheme:schemeName];
            XCTAssertNotNil(scheme, @"Unexpected result");
            DJLipikaBufferManager *manager = [[DJLipikaBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
            NSString *fuzzInput = [[DJTestHelper genRandStringLength:10] stringByAppendingString:@" "];
            NSString *output = [manager outputForInput:fuzzInput];
            DJParseOutput *reverse = [scheme.reverseMappings inputForOutput:output];
            NSString *reversedInput = [reverse input];
            NSString *reversedOutput = [manager outputForInput:reversedInput];
            XCTAssertEqualObjects(output, reversedOutput, @"Fuzz test failed for input: %@", fuzzInput);
        }
    }
}

-(void)XXXtestBacktracking {
    [DJLipikaSchemeFactory setSchemesDirectory:@"/Users/ratreya/workspace/Lipika_IME/Tests/Lipika/Schemes"];
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"UsingBacktrack" scheme:@"UsingBacktrack"];
    DJInputMethodEngine *engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    DJLipikaBufferManager *manager = [[DJLipikaBufferManager alloc] initWithEngine:engine];
    [manager outputForInput:@"k"];
    XCTAssertEqualObjects([manager output], @"क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"ka"];
    XCTAssertEqualObjects([manager output], @"क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kk"];
    XCTAssertEqualObjects([manager output], @"क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kka"];
    XCTAssertEqualObjects([manager output], @"क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkk"];
    XCTAssertEqualObjects([manager output], @"क्क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkka"];
    XCTAssertEqualObjects([manager output], @"क्क्क", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kakki"];
    XCTAssertEqualObjects([manager output], @"कक्कि", @"Invalid output");
    [manager flush];
    [manager outputForInput:@"kkhg"];
    XCTAssertEqualObjects([manager output], @"क्ख्ग", @"Invalid output");
    [manager flush];
}

@end
