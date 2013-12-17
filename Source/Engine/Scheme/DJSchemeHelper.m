/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJSchemeHelper.h"

@implementation DJSchemeHelper

extern NSMutableArray *charactersForString(NSString *string) {
    NSRange theRange = {0, 1};
    NSMutableArray *array = [NSMutableArray array];
    for ( NSInteger i = 0; i < [string length]; i++) {
        theRange.location = i;
        [array addObject:[string substringWithRange:theRange]];
    }
    return array;
}

extern NSArray *csvToArrayForString(NSString *csvLine) {
    NSArray *items = [csvLine componentsSeparatedByString:@","];
    if (items.count == 1) return items;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:items.count];
    [items enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[obj stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]]];
    }];
    return result;
}

extern NSString *stringForUnicode(NSString *unicodeString) {
    NSScanner *scanner = [NSScanner scannerWithString:unicodeString];
    unsigned unicode = 0;
    [scanner scanHexInt:&unicode];
    return [[NSString alloc] initWithBytes:&unicode length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

@end