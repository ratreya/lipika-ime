/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJParseOutput.h"

@implementation DJParseOutput

@synthesize input;
@synthesize output;
@synthesize isFinal;
@synthesize isPreviousFinal;

+(DJParseOutput*)sameInputOutput:(NSString*)input {
    DJParseOutput* result = [[DJParseOutput alloc] init];
    result.input = input;
    result.output = input;
    result.isFinal = YES;
    return result;
}

@end
