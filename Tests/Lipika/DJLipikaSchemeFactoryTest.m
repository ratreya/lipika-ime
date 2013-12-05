/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "DJLipikaSchemeFactory.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString*)directory;

@end

@interface DJLipikaSchemeFactoryTest : SenTestCase

@end

@implementation DJLipikaSchemeFactoryTest

-(void)setUp {
    [super setUp];
    [DJLipikaSchemeFactory setSchemesDirectory:@"/Users/ratreya/workspace/Lipika_IME/Schemes"];
}

-(void)testHappyCase {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Devanagari" scheme:@"Baraha"];
    STAssertNotNil(scheme, @"Unexpected result");
    NSString* output = [[[[[scheme.forwardMappings parseTree] valueForKey:@"~"] next] valueForKey:@"j"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[scheme.forwardMappings parseTree] valueForKey:@"~"] next] valueForKey:@"j"] next] valueForKey:@"I"] output];
    STAssertTrue([output isEqualToString: @"ञी"], @"Unexpected output: %@", output);
}

-(void)testSchemeOverrides {
    DJLipikaInputScheme *scheme = [DJLipikaSchemeFactory inputSchemeForScript:@"Devanagari" scheme:@"Baraha"];
    STAssertNotNil(scheme, @"Unexpected result");
    NSString* output = [[[[[scheme.forwardMappings parseTree] valueForKey:@"~"] next] valueForKey:@"j"] output];
    STAssertTrue([output isEqualToString: @"ञ्"], @"Unexpected output");
    output = [[[[[[[scheme.forwardMappings parseTree] valueForKey:@"~"] next] valueForKey:@"j"] next] valueForKey:@"e"] output];
    STAssertTrue([output isEqualToString: @"ञे"], @"Unexpected output: %@", output);
}

@end
