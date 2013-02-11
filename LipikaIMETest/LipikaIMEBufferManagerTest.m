#import "LipikaIMEBufferManagerTest.h"

@interface DJLipikaBufferManager (Test)

-(id)initWithEngine:(DJInputMethodEngine*)myEngine;

@end

@implementation LipikaIMEBufferManagerTest

-(void)setUp {
    [super setUp];
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    manager = [[DJLipikaBufferManager alloc] initWithEngine:engine];
}

-(void)tearDown {
    [manager outputForInput:@" "];
    [super tearDown];
}

- (void)testHappyCase_Chain_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    STAssertTrue([@"त्" isEqualToString:result], @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    STAssertTrue([@"री" isEqualToString:result], @"Unexpected output: %@", result);
}

- (void)testHappyCase_Chain_Class_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue([@"ता" isEqualToString:result], @"Unexpected output: %@", result);
}

- (void)testHappyCase_Chain_Space_Mapping {
    NSString* result = [manager outputForInput:@"t"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"r"];
    STAssertTrue([@"त्" isEqualToString:result], @"Unexpected output: %@", result);
    result = [manager outputForInput:@"e"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    STAssertTrue([@"रे " isEqualToString:result], @"Unexpected output: %@", result);
}

- (void)testHappyCase_Special_Chain_Mapping {
    NSString* result = [manager outputForInput:@"r"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"~"];
    STAssertTrue([result isEqualToString:@"र"], @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@"g"];
    STAssertTrue([result isEqualToString:@"ङ्"], @"Unexpected output: %@", result);
    result = [manager outputForInput:@"a"];
    STAssertTrue(result == nil, @"Unexpected output: %@", result);
    result = [manager outputForInput:@" "];
    STAssertTrue([result isEqualToString:@"ग "], @"Unexpected output: %@", result);
}


-(void)testStopCharacter {
    NSString* result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, @"Unexpected output");
    result = [manager outputForInput:@"J"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\\"];
    STAssertTrue([result isEqualToString:@"ञ्"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"\\"];
    STAssertTrue([result isEqualToString:@"\\"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"~"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"l"];
    STAssertTrue(result == nil, [NSString stringWithFormat: @"Unexpected output: %@", result]);
    result = [manager outputForInput:@"u"];
    STAssertTrue([result isEqualToString:@"ऌ"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
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
    STAssertTrue([result isEqualToString:@"ऌ"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
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
    STAssertTrue([result isEqualToString:@"ऌ"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
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
    STAssertTrue([result isEqualToString:@"ऌ"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
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
    STAssertTrue([result isEqualToString:@"ऌ"], [NSString stringWithFormat: @"Unexpected output: %@", result]);
}

@end
