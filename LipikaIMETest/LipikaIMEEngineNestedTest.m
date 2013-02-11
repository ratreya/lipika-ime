#import "LipikaIMEEngineNestedTest.h"
#import "LipikaIMEEngineTest.h"
#import "DJInputMethodScheme.h"
#import "DJInputMethodEngine.h"

@implementation LipikaIMEEngineNestedTest

- (void)testNestedClassParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestNestedClass.scm"];
    STAssertTrue([@"test1" isEqualToString:[scheme getClassNameForInput:@"c"]], @"Unexpected class name");
    STAssertTrue([@"test2" isEqualToString:[scheme getClassNameForInput:@"f"]], @"Unexpected class name");
    STAssertTrue([[scheme getClassForName:@"test1"] count] == 3, @"Unexpected count of mappings");
    STAssertTrue([[scheme getClassForName:@"test2"] count] == 2, @"Unexpected count of mappings");
}

-(void)testHappyCase_Simple_NestedClass {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestNestedClass.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    DJParseOutput* result = [engine executeWithInput:@"z"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"c"];
    STAssertTrue([@"zfc" isEqualToString:[result output]], [NSString stringWithFormat: @"Unexpected output: %@", [result output]]);
    STAssertTrue([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}


-(void)testInvalidCase_Simple_NestedClass {
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestNestedClass.scm"];
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    DJParseOutput* result = [engine executeWithInput:@"z"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
    result = [engine executeWithInput:@"f"];
    STAssertTrue([result output] == nil, @"Unexpected output");
    STAssertFalse([result isFinal], @"Unexpected output");
    STAssertFalse([result isPreviousFinal], @"Unexpected output");
}

@end
