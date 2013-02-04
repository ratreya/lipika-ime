#import "LipikaIMEEngineTest.h"
#import "DJInputMethodScheme.h"
#import "DJInputMethodEngine.h"

@implementation LipikaIMEEngineTest

- (void)testHappyCase_SingleCharMapping {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    DJParseOutput* result = [engine executeWithInput:@"a"];
    STAssertTrue([@"अ" isEqualToString:[result output]], @"Unexpected output");
    STAssertTrue([result isFinal], @"Unexpected output");
}

- (void)testHappyCase_Single_MultiCharMapping {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
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

- (void)testHappyCase_Intermediate_Output_MultiCharMapping {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
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

- (void)testHappyCase_Intermediate_Finals_MultiCharMapping {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
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

- (void)testHappyCase_ClassMapping {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
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

@end
