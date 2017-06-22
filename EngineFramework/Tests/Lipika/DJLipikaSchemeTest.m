/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJSchemeHelper.h"
#import "DJLipikaInputScheme.h"
#import "DJInputMethodEngine.h"
#import "DJLipikaMappings.h"

@interface DJLipikaInputScheme (Test)

-(NSArray *)parseMapString:(NSString *)mapString;
-(NSString *)stringForUnicode:(NSString *)unicodeString;

@end

@interface DJLipikaSchemeTest : XCTestCase

@end

@interface DJInputMethodEngine (Test)

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;

@end

@implementation DJLipikaSchemeTest

-(void)setUp {
    [super setUp];
}

-(DJLipikaInputScheme *)schemeWithDefaultData {
    NSMutableDictionary *dependents = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [[DJMap alloc] initWithScript:@"0CBF" scheme:@"i"],   @"I",
                                      [[DJMap alloc] initWithScript:@"0CC1" scheme:@"u"],   @"U", nil];
    NSMutableDictionary *consonants = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [[DJMap alloc] initWithScript:@"0C95" scheme:@"k"],    @"KA",
                                      [[DJMap alloc] initWithScript:@"0C96" scheme:@"kh, K"],    @"KHA",
                                      [[DJMap alloc] initWithScript:@"0C97" scheme:@"g"],    @"GA",
                                      [[DJMap alloc] initWithScript:@"0C98" scheme:@"gh, G"],    @"GHA",
                                      [[DJMap alloc] initWithScript:@"0C99" scheme:@"~N, N^"],    @"NGA", nil];
    NSMutableDictionary *signs = [NSMutableDictionary dictionaryWithObject:[[DJMap alloc] initWithScript:@"0CCD" scheme:@"q"] forKey:@"VIRAMA"];
    NSMutableDictionary *mappings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        dependents, @"DEPENDENT",
                                        consonants, @"CONSONANT",
                                        signs, @"SIGN",nil];

    NSArray *imeLines = [NSMutableArray arrayWithObjects:
                         @"{CONSONANT}	[CONSONANT][SIGN/VIRAMA]",
                         @"{CONSONANT}a	[CONSONANT]",
                         @"{CONSONANT}{DEPENDENT}	[CONSONANT][DEPENDENT]", nil];
    return [[DJLipikaInputScheme alloc] initWithMappings:mappings imeLines:imeLines];
}

-(void)testCharacterConversion {
    XCTAssertEqualObjects(stringForUnicode(@"0C95"), @"ಕ", @"Bad character");
}

-(void)testCSVSchemeParsing {
    DJLipikaInputScheme *scheme = [self schemeWithDefaultData];
    XCTAssertNotNil([scheme forwardMappings], @"Forward parse trie unexpectedly nil");
    DJInputMethodEngine *engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    NSArray *results = [engine executeWithInput:@"khi"];
    XCTAssertNotNil(results, @"Unexpected result");
    XCTAssertEqualObjects([results[0] output], @"ಕ್", @"Unexpected result: %@", [results[0] output]);
    XCTAssertEqualObjects([results[1] output], @"ಖ್", @"Unexpected result: %@", [results[1] output]);
    XCTAssertEqualObjects([results[2] output], @"ಖಿ", @"Unexpected result: %@", [results[2] output]);
    results = [engine executeWithInput:@"Ki"];
    XCTAssertNotNil(results, @"Unexpected result");
    XCTAssertEqualObjects([results[0] output], @"ಖ್", @"Unexpected result: %@", [results[0] output]);
    XCTAssertEqualObjects([results[1] output], @"ಖಿ", @"Unexpected result: %@", [results[1] output]);
    results = [engine executeWithInput:@"gha"];
    XCTAssertNotNil(results, @"Unexpected result");
    XCTAssertEqualObjects([results[0] output], @"ಗ್", @"Unexpected result: %@", [results[0] output]);
    XCTAssertEqualObjects([results[1] output], @"ಘ್", @"Unexpected result: %@", [results[1] output]);
    XCTAssertEqualObjects([results[2] output], @"ಘ", @"Unexpected result: %@", [results[2] output]);
}

@end
