/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "DJLipikaBufferManager.h"
#import "DJLipikaUserSettings.h"
#import "DJGoogleSchemeFactory.h"

@interface LipikaIMEBufferManagerTest : SenTestCase {
    DJLipikaBufferManager* manager;
}

@end

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine*)myEngine;

@end

@implementation LipikaIMEBufferManagerTest

-(void)setUp {
    [super setUp];
    DJGoogleInputScheme* scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    manager = [[DJLipikaBufferManager alloc] initWithEngine:engine];
}

-(void)tearDown {
    [manager outputForInput:@" "];
    [super tearDown];
}

-(void)testHappyCase_Chain_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    result = [manager outputForInput:@" "];
    STAssertTrue([@"त्री " isEqualToString:result], @"Unexpected output: %@", result);
}

-(void)testHappyCase_Chain_Class_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    result = [manager outputForInput:@" "];
    STAssertTrue([@"ता " isEqualToString:result], @"Unexpected output: %@", result);
}

-(void)testHappyCase_Chain_Space_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    STAssertTrue([@"त्रे " isEqualToString:result], @"Unexpected output: %@", result);
}

-(void)testHappyCase_Special_Chain_Mapping {
    NSString* result = [manager outputForInput:@"r"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"रङ्ग "], @"Unexpected output: %@", result);
}

-(void)testHappyCase_Intermediate_Blank_Chain_Mapping {
    NSString* result = [manager outputForInput:@"j"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"j"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    STAssertTrue([@"ज्ञ " isEqualToString:result], @"Unexpected output: %@", result);
}

-(void)testStopCharacter {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\\"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    STAssertTrue([[manager output] isEqualToString:@"ञ्"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    result = [manager outputForInput:@"\\"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    STAssertTrue([[manager output] isEqualToString:@"ञ्\\"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ञ्\\ "], @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ऌ "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

-(void)testEchoNonOuputtingInput {
    NSString* result = [manager outputForInput:@"~~ "];
    STAssertTrue([@"~~ " isEqualToString:result], @"Unexpected output: %@", result);
}

-(void)testWhitespace_Space {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ञ् "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ऌ "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

-(void)testWhitespace_Tab {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\t"];
    STAssertTrue([result isEqualToString:@"ञ्\t"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ऌ "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

-(void)testWhitespace_Newline {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\n"];
    STAssertTrue([result isEqualToString:@"ञ्\n"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ऌ "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

-(void)testWhitespace_Return {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\r"];
    STAssertTrue([result isEqualToString:@"ञ्\r"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ऌ "], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

-(void)testDeleteInput {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    NSString* result = [manager outputForInput:@"rai"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    STAssertTrue([[manager output] isEqualToString:@"रै"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    STAssertTrue([[manager input] isEqualToString:@"ra"], [NSString stringWithFormat: @"Unexpected output: %@", [manager input]]);
    STAssertTrue([[manager output] isEqualToString:@"र"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    STAssertTrue([[manager input] isEqualToString:@"r"], [NSString stringWithFormat: @"Unexpected output: %@", [manager input]]);
    STAssertTrue([[manager output] isEqualToString:@"र्"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
}

-(void)testCombineAfterDelete {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"vRuddhi"];
    STAssertTrue([[manager output] isEqualToString:@"वृद्धि"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    STAssertTrue([[manager output] isEqualToString:@"वृद्ध्"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager outputForInput:@"k"];
    STAssertTrue([[manager output] isEqualToString:@"वृद्ध्क्"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    STAssertTrue([[manager output] isEqualToString:@"वृद्ध्"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager outputForInput:@"u"];
    STAssertTrue([[manager output] isEqualToString:@"वृद्धु"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
}

-(void)testCombineAfterDeleteNonMappableChar {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"guNavRi"];
    STAssertTrue([[manager output] isEqualToString:@"गुणव्Ri"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    [manager delete];
    [manager outputForInput:@"Ru"];
    STAssertTrue([[manager output] isEqualToString:@"गुणवृ"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
}

-(void)testPartialParseStopCharacter {
    [[NSUserDefaults standardUserDefaults] setObject:@"Input character" forKey:@"BackspaceDeletes"];
    [manager outputForInput:@"guNavRi"];
    STAssertTrue([[manager output] isEqualToString:@"गुणव्Ri"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
    [manager delete];
    [manager outputForInput:@"\\"];
    STAssertTrue([[manager output] isEqualToString:@"गुणव्R"], [NSString stringWithFormat: @"Unexpected output: %@", [manager output]]);
}

@end
