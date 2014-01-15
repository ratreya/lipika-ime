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
    NSMutableDictionary *depScript = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"0CBF",   @"I",
                                      @"0CC1",   @"U", nil];
    NSMutableDictionary *conScript = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"0C95",    @"KA",
                                      @"0C96",    @"KHA",
                                      @"0C97",    @"GA",
                                      @"0C98",    @"GHA",
                                      @"0C99",    @"NGA", nil];
    NSMutableDictionary *signScript = [NSMutableDictionary dictionaryWithObject:@"0CCD" forKey:@"VIRAMA"];
    NSMutableDictionary *scriptTable = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        depScript, @"DEPENDENT",
                                        conScript, @"CONSONANT",
                                        signScript, @"SIGN",nil];
    
    NSMutableDictionary *depScheme = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"i",   @"I",
                                      @"u",   @"U", nil];
    NSMutableDictionary *conScheme = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"k",    @"KA",
                                      @"kh, K",    @"KHA",
                                      @"g",    @"GA",
                                      @"gh, G",    @"GHA",
                                      @"~N, N^",    @"NGA", nil];
    NSMutableDictionary *signScheme = [NSMutableDictionary dictionaryWithObject:@"q" forKey:@"VIRAMA"];
    NSMutableDictionary *schemeTable = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        depScheme, @"DEPENDENT",
                                        conScheme, @"CONSONANT",
                                        signScheme, @"SIGN",nil];

    NSArray *imeLines = [NSMutableArray arrayWithObjects:
                         @"{CONSONANT}	[CONSONANT][SIGN/VIRAMA]",
                         @"{CONSONANT}a	[CONSONANT]",
                         @"{CONSONANT}{DEPENDENT}	[CONSONANT][DEPENDENT]", nil];
    return [[DJLipikaInputScheme alloc] initWithSchemeTable:schemeTable scriptTable:scriptTable imeLines:imeLines];
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
