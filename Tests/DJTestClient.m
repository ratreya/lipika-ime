/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJTestClient.h"

#pragma clang diagnostic ignored "-Wprotocol" // Only implementing methods that the application uses
@implementation DJTestClient

@synthesize committedString;
@synthesize attributes;

-(id)initWithCommittedString:(NSString *)theString {
    self = [super init];
    if (!self) return self;
    committedString = theString;
    markedString = @"";
    attributes = [NSDictionary dictionary];
    return self;
}

-(void)insertText:(id)string replacementRange:(NSRange)replacementRange {
    if ([string isKindOfClass:[NSAttributedString class]]) string = [string string];
    committedString = [committedString stringByReplacingCharactersInRange:replacementRange withString:string];
    markedString = @"";
}

-(void)setMarkedText:(id)string selectionRange:(NSRange)selectionRange replacementRange:(NSRange)replacementRange {
    if ([string isKindOfClass:[NSAttributedString class]]) string = [string string];
    if (replacementRange.location == NSNotFound) replacementRange = NSMakeRange(committedString.length, 0);
    else committedString = [committedString stringByReplacingCharactersInRange:replacementRange withString:@""];
    markedString = string;
}

-(NSRange)selectedRange {
    return NSMakeRange(committedString.length, 0);
}

-(NSString *)markedString {
    return [committedString stringByAppendingString:markedString];
}

-(void)setMarkedString:(NSString *)theMarkedString {
    markedString = theMarkedString;
}

-(NSAttributedString*)attributedSubstringFromRange:(NSRange)range {
    return [[NSAttributedString alloc] initWithString:[committedString substringWithRange:range]];
}

-(NSDictionary *)attributesForCharacterIndex:(NSUInteger)index lineHeightRectangle:(NSRect*)lineRect {
    return attributes;
}

-(void)handleBackspace {
    committedString = [committedString substringToIndex:committedString.length - 1];
}

@end
