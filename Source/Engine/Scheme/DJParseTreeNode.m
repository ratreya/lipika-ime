/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJParseTreeNode.h"

@implementation DJParseTreeNode

@synthesize input;
@synthesize output;
@synthesize next;

-(NSString*)description {
    return [NSString stringWithFormat:@"Output: %@; Next: %@", output, [next description]];
}

extern NSMutableArray* charactersForString(NSString *string) {
    NSRange theRange = {0, 1};
    NSMutableArray* array = [NSMutableArray array];
    for ( NSInteger i = 0; i < [string length]; i++) {
        theRange.location = i;
        [array addObject:[string substringWithRange:theRange]];
    }
    return array;
}

@end
