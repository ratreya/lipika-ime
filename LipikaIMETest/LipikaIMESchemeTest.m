/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "LipikaIMESchemeTest.h"
#import "DJInputMethodScheme.h"
#import "DJParseTreeNode.h"

@implementation LipikaIMESchemeTest

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

- (void)testMappingParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
    NSString* output = [[[[[scheme parseTree] valueForKey:@"~"] next] valueForKey:@"j"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[scheme parseTree] valueForKey:@"~"] next] valueForKey:@"j"] next] valueForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

// Ignoring for now; @ symbol does not seem to work
- (void)XXXtestSpecialCharacterParsing {
    NSLog(@"%@", [[NSBundle mainBundle] bundlePath]);
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestSpecialChars.scm"];
    STAssertTrue(scheme != nil, @"Unable to parse special characters");
}


@end
