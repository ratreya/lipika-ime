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
#import "DJStringBufferManager.h"
#import "DJTestHelper.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString *)directory;

@end

@interface DJStringBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@interface DJInputMethodEngine (Test)

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;

@end

@interface DJLipikaSchemeFactoryTest : XCTestCase

@end

@implementation DJLipikaSchemeFactoryTest

-(void)setUp {
    [super setUp];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Schemes"];
    [DJLipikaSchemeFactory setSchemesDirectory:filePath];
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

-(void)testLoadingMappingOverrides {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Gurmukhi" scheme:@"Barahavat"];
    XCTAssertNotNil(scheme, @"Unexpected result");
    DJSimpleForwardMapping *forwardMappings = scheme.forwardMappings;
    NSString *output = [forwardMappings.parseTrie nodeForKey:@".n"].value;
    XCTAssertEqualObjects(output,  @"ੰ", @"Unexpected output");
    output = [forwardMappings.parseTrie nodeForKey:@".m"].value;
    XCTAssertEqualObjects(output,  @"ਁ", @"Unexpected output: %@", output);
}

-(void)testLoadingCurrentIMEs {
    for (NSString *schemeName in [DJLipikaSchemeFactory availableSchemes]) {
        for (NSString *scriptName in [DJLipikaSchemeFactory availableScripts]) {
            DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:scriptName scheme:schemeName];
            XCTAssertNotNil(scheme, @"Unexpected result");
            DJStringBufferManager *manager = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
            NSString *fuzzInput = [DJTestHelper genRandStringLength:10];
            NSString *output = [manager outputForInput:fuzzInput];
            output = [manager flush];
            DJParseOutput *reverse = [scheme.reverseMappings inputForOutput:output];
            NSString *reversedInput = [reverse input];
            NSString *reversedOutput = [manager outputForInput:reversedInput];
            reversedOutput = [manager flush];
            if (!reversedOutput) continue;
            XCTAssertEqualObjects([output substringFromIndex:output.length - reversedOutput.length], reversedOutput, @"Fuzz test failed for input: %@", fuzzInput);
        }
    }
}

@end
