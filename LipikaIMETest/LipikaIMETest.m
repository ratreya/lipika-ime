#import "LipikaIMETest.h"
#import "DJInputMethodScheme.h"

@implementation LipikaIMETest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testHeaderParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    STAssertTrue([@"1.0" isEqualTo:[scheme version]], @"Version numbers don't match");
    STAssertTrue([@"Barahavat" isEqualTo:[scheme name]], @"Names don't match");
    STAssertTrue([@"\\" isEqualTo:[scheme stopChar]], @"Stop Characters dos't match");
    STAssertTrue([scheme usingClasses], @"Using Classes don't match");
    STAssertTrue([@"{" isEqualToString:[scheme classOpenDelimiter]], @"Class open delimiters don't match");
    STAssertTrue([@"}" isEqualToString:[scheme classCloseDelimiter]], @"Class close delimiters don't match");
    STAssertTrue([@"*" isEqualToString:[scheme wildcard]], @"Wildcards don't match");
}

- (void)testClassParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestClassHappy.scm"];
    STAssertTrue([@"test" isEqualToString:[scheme getClassNameForInput:@"c"]], @"Unexpected class name");
    STAssertTrue([[scheme getClassForName:@"test"] count] == 3, @"Unexpected count of mappings");
}

- (void)testNestedClassParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestNestedClass.scm"];
    STAssertTrue([@"test1" isEqualToString:[scheme getClassNameForInput:@"c"]], @"Unexpected class name");
    STAssertTrue([@"test2" isEqualToString:[scheme getClassNameForInput:@"f"]], @"Unexpected class name");
    STAssertTrue([[scheme getClassForName:@"test1"] count] == 3, @"Unexpected count of mappings");
    STAssertTrue([[scheme getClassForName:@"test2"] count] == 2, @"Unexpected count of mappings");
}

- (void)testSpecialCharacterParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestSpecialChars.scm"];
    STAssertTrue(scheme != nil, @"Unable to parse special characters");
}


@end
