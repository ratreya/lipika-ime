/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaHelper.h"

@implementation DJLipikaHelper

static NSRegularExpression *whitespaceExpression;

+(void)initialize {
    NSString *const whitespacePattern = @"^\\s+$";
    NSError *error;
    whitespaceExpression = [NSRegularExpression regularExpressionWithPattern:whitespacePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

BOOL isWhitespace(NSString *string) {
    return [whitespaceExpression numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
}

@end
