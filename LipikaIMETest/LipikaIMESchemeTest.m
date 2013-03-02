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
#import "DJParseTreeNode.h"

@implementation LipikaIMESchemeTest

- (void)setUp {
    [super setUp];
    scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestHappyCase.scm"];
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
    STAssertTrue([@"VowelSigns" isEqualToString:[scheme classNameForInput:@"A"]], @"Unexpected class name");
    STAssertTrue([[scheme classForName:@"VowelSigns"] count] == 12, @"Unexpected count of mappings: %d", [[scheme classForName:@"VowelSigns"] count]);
}

- (void)testMappingParsing {
    NSString* output = [[[[[scheme parseTree] valueForKey:@"~"] next] valueForKey:@"j"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[scheme parseTree] valueForKey:@"~"] next] valueForKey:@"j"] next] valueForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

-(void)testNonDefaultHeaders {
    DJInputMethodScheme* myScheme = [[DJInputMethodScheme alloc] initWithSchemeFile:@"/Users/ratreya/workspace/Lipika_IME/LipikaIMETest/TestITRANS.scm"];
    STAssertTrue([@"VowelSigns" isEqualToString:[myScheme classNameForInput:@"u"]], @"Unexpected output");
    NSString* output = [[[[[myScheme parseTree] valueForKey:@"~"] next] valueForKey:@"n"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[myScheme parseTree] valueForKey:@"~"] next] valueForKey:@"n"] next] valueForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

@end
