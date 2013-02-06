#import "LipikaIMENestedClassTest.h"
#import "DJInputMethodScheme.h"
#import "DJInputMethodEngine.h"

@implementation LipikaIMENestedClassTest

- (void)setUp {
    [super setUp];
    scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestNestedClass.scm"];
    engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

- (void)tearDown {
    [engine executeWithInput:@" "];
    [super tearDown];
}

-(void)testHappyCase_Simple_NestedClass {
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
