#import "LipikaIMEEngineTest.h"

@implementation LipikaIMEEngineTest

- (void)setUp {
    [super setUp];
    scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

- (void)testHappyCase_SingleChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"a"];
    STAssertTrue([@"अ" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"आ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Chain_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"t"];
    STAssertTrue([@"त्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"r"];
    STAssertTrue([@"र्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"रे" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"e"];
    STAssertTrue([@"री" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");    
}

- (void)testHappyCase_Simple_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ॡ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
}

- (void)testHappyCase_Intermediate_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"ञ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_IntermediateFinals_MultiChar_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"च्" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"a"];
    STAssertTrue([@"च" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_SingleChar_Class_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"U"];
    STAssertTrue([@"ञू" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

- (void)testHappyCase_MultiChar_Class_Mapping {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ञॢ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testStopCharacter {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\\"];
    STAssertTrue([[result output] isEqualToString: @"\\"], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ऌ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testWhitespace_Space {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@" "];
    STAssertTrue([[result output] isEqualToString: @" "], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ऌ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testWhitespace_Tab {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\t"];
    STAssertTrue([[result output] isEqualToString: @"\t"], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ऌ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testWhitespace_Newline {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\n"];
    STAssertTrue([[result output] isEqualToString: @"\n"], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ऌ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

-(void)testWhitespace_Return {
    DJParseOutput* result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"J"];
    STAssertTrue([@"ञ्" isEqualToString:[result output]], @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"\r"];
    STAssertTrue([[result output] isEqualToString: @"\r"], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertTrue([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"~"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"l"];
    STAssertTrue([result output] == nil, [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"u"];
    STAssertTrue([@"ऌ" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

@end
