/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJCombinedBufferManager.h"
#import "DJInputSchemeFactory.h"
#import "DJLipikaUserSettings.h"
#import "DJLipikaHelper.h"

@implementation DJCombinedBufferManager

@synthesize scriptPopup;
@synthesize schemePopup;
@synthesize originalTextView;
@synthesize composedTextView;

-(id)init {
    self = [super init];
    if (!self) return self;
    buffer = [NSMutableArray arrayWithCapacity:0];
    return self;
}

-(void)awakeFromNib {
    [scriptPopup addItemsWithTitles:[DJInputSchemeFactory availableScriptsForType:DJ_LIPIKA]];
    [schemePopup addItemsWithTitles:[DJInputSchemeFactory availableSchemesForType:DJ_LIPIKA]];
    [scriptPopup selectItemWithTitle:[DJLipikaUserSettings scriptName]];
    [schemePopup selectItemWithTitle:[DJLipikaUserSettings schemeName]];
}

-(unsigned long)indexForPositionInOriginal:(unsigned long)positionInOriginal {
    if (!buffer.count) return 0;
    unsigned long originalLength = positionInOriginal;
    unsigned long index;
    for (index = 0; index < buffer.count; index ++) {
        if (originalLength <= [buffer[index] input].length) break;
        originalLength -= [buffer[index] input].length;
    }
    return index;
}

-(unsigned long)indexForPositionInComposed:(unsigned long)positionInComposed {
    if (!buffer.count) return 0;
    unsigned long composedLength = positionInComposed;
    unsigned long index;
    for (index = 0; index < buffer.count; index ++) {
        if (composedLength <= [buffer[index] output].length) break;
        composedLength -= [buffer[index] output].length;
    }
    return index;
}

-(unsigned long)positionInComposedForPositionInOriginal:(unsigned long)positionInOriginal {
    if (!buffer.count) return 0;
    unsigned long composedLength = 0;
    unsigned long originalLength = positionInOriginal;
    unsigned long index;
    for (index = 0; index < buffer.count; index ++) {
        composedLength += [buffer[index] output].length;
        if (originalLength <= [buffer[index] input].length) break;
        originalLength -= [buffer[index] input].length;
    }
    return composedLength;
}

-(unsigned long)positionInOriginalForPositionInComposed:(unsigned long)positionInComposed {
    if (!buffer.count) return 0;
    unsigned long composedLength = positionInComposed;
    unsigned long originalLength = 0;
    unsigned long index;
    for (index = 0; index < buffer.count; index ++) {
        originalLength += [buffer[index] input].length;
        if (composedLength <= [buffer[index] output].length) break;
        composedLength -= [buffer[index] output].length;
    }
    return originalLength;
}

-(BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if ([aTextView isEqual:originalTextView]) {
        DJActiveBufferManager *manager = [[DJActiveBufferManager alloc] init];
        NSString *previousInput;
        NSString *nextInput;
        unsigned long startIndex = [self indexForPositionInOriginal:affectedCharRange.location];
        unsigned long endIndex = [self indexForPositionInOriginal:affectedCharRange.location + affectedCharRange.length];
        if (startIndex > 0) previousInput = [buffer[startIndex - 1] input];
        if (endIndex < buffer.count - 1) nextInput = [buffer[endIndex + 1] input];
        NSMutableString *input = [[NSMutableString alloc] init];
        NSRange replacementRange = NSMakeRange(startIndex, endIndex);
        if (!isWhitespace(previousInput)) {
            [input appendString:previousInput];
            replacementRange.location--;
        }
        [input appendString:replacementString];
        if (!isWhitespace(nextInput)) {
            [input appendString:nextInput];
            replacementRange.length++;
        }
        NSMutableArray *replacementBuffer = [NSMutableArray arrayWithCapacity:0];
        [replacementBuffer addObjectsFromArray:[manager outputForInput:input]];
        [replacementBuffer addObjectsFromArray:[manager uncommitted]];
        [buffer replaceObjectsInRange:replacementRange withObjectsFromArray:replacementBuffer];
    }
    else if ([aTextView isEqual:composedTextView]) {
        NSLog(@"textDidChange for composed");
    }
    else {
        NSLog(@"textDidChange for unknown");
    }
    return YES;
}

-(void)textViewDidChangeSelection:(NSNotification *)aNotification {
    if ([aNotification.object isEqual:originalTextView]) {
        NSLog(@"textViewDidChangeSelection for original");
    }
    else if ([aNotification.object isEqual:composedTextView]) {
        NSLog(@"textViewDidChangeSelection for composed");
    }
    else {
        NSLog(@"textViewDidChangeSelection for unknown");
    }
}

@end
