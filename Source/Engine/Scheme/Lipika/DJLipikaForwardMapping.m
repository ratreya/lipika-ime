/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaForwardMapping.h"

@implementation DJLipikaForwardMapping

-(id)init {
    self = [super init];
    if (!self) return self;
    inputRegexs = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

-(void)addInputRegex:(NSString *)regex insertionValue:(NSString *)value {
    NSError *error;
    NSRegularExpression *regexObject = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
    if (error) {
        [NSException raise:@"Invalid regular expression" format:@"Description: %@", [error description]];
    }
    [inputRegexs setObject:value forKey:regexObject];
}

-(NSString *)preProcessInput:(NSString *)input withPreviousInput:(NSString *)previousInput {
    // Run all input regexs
    NSString *combinedInput = [previousInput stringByAppendingString:input];
    NSString *modifiedInput = nil;
    for (NSRegularExpression *regex in [inputRegexs allKeys]) {
        NSString *value = [inputRegexs objectForKey:regex];
        if ([regex numberOfMatchesInString:combinedInput options:0 range:NSMakeRange(0, combinedInput.length)]) {
            modifiedInput = [regex stringByReplacingMatchesInString:combinedInput options:0 range:NSMakeRange(0, combinedInput.length) withTemplate:value];
        }
    }
    return modifiedInput;
}

@end
