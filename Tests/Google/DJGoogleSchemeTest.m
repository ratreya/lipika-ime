/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJParseTrieNode.h"
#import <SenTestingKit/SenTestingKit.h>
#import "DJGoogleSchemeFactory.h"

@interface DJGoogleForwardMapping (Test)

-(NSDictionary *)parseTrie;

@end

@interface DJGoogleSchemeTest : SenTestCase {
    DJGoogleInputScheme *scheme;
}

@end

@implementation DJGoogleSchemeTest

- (void)setUp {
    [super setUp];
    scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestHappyCase.scm"];
}

- (void)testHeaderParsing {
    STAssertTrue([@"1.0" isEqualTo:[scheme version]], @"Version numbers don't match");
    STAssertTrue([@"Barahavat" isEqualTo:[scheme name]], @"Names don't match");
    STAssertTrue([@"\\" isEqualTo:[scheme stopChar]], @"Stop Characters dos't match");
    STAssertTrue([scheme usingClasses], @"Using Classes don't match");
    STAssertTrue([@"{" isEqualToString:[scheme classOpenDelimiter]], @"Class open delimiters don't match");
    STAssertTrue([@"}" isEqualToString:[scheme classCloseDelimiter]], @"Class close delimiters don't match");
    STAssertTrue([@"*" isEqualToString:[scheme wildcard]], @"Wildcards don't match");
}

- (void)testClassParsing {
    STAssertTrue([@"VowelSigns" isEqualToString:[scheme.forwardMappings classNameForInput:@"A"]], @"Unexpected class name");
    STAssertTrue([[scheme.forwardMappings classForName:@"VowelSigns"] count] == 12, @"Unexpected count of mappings: %d", [[scheme.forwardMappings classForName:@"VowelSigns"] count]);
}

- (void)testMappingParsing {
    NSString* output = [[[[[scheme.forwardMappings parseTrie] objectForKey:@"~"] next] objectForKey:@"j"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[scheme.forwardMappings parseTrie] objectForKey:@"~"] next] objectForKey:@"j"] next] objectForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

-(void)testNonDefaultHeaders {
    DJGoogleInputScheme *myScheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/Tests/Google/Schemes/TestITRANS.scm"];
    STAssertTrue([@"VowelSigns" isEqualToString:[myScheme.forwardMappings classNameForInput:@"u"]], @"Unexpected output");
    NSString* output = [[[[[myScheme.forwardMappings parseTrie] objectForKey:@"~"] next] objectForKey:@"n"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[myScheme.forwardMappings parseTrie] objectForKey:@"~"] next] objectForKey:@"n"] next] objectForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

@end
