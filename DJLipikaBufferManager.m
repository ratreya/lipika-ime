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

#import "DJLipikaBufferManager.h"
#import "DJInputEngineFactory.h"

@implementation DJLipikaBufferManager

static NSRegularExpression* whiteSpace;

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = [DJInputEngineFactory inputEngine];
    if (engine == nil) {
        return nil;
    }
    [self initialize];
    return self;
}

// Only for testing purposes and not exposed in the interface
-(id)initWithEngine:(DJInputMethodEngine*)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = myEngine;
    [self initialize];
    return self;
}

-(void)initialize {
    NSError* error;
    whiteSpace = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid whitespace regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finalizedIndex = 0;
}

-(NSString*)outputForInput:(NSString*)string {
    // The states beyond this entry point are not thread-safe
    @synchronized (self) {
        NSMutableString* output;
        NSRange theRange = {0, 1};
        for ( NSInteger i = 0; i < [string length]; i++) {
            theRange.location = i;
            NSString* singleInput = [string substringWithRange:theRange];
            NSString* singleOutput = [self outputForSingleInput:singleInput];
            if (singleOutput != nil) {
                if (output == nil) {
                    output = [[NSMutableString alloc] initWithCapacity:0];
                }
                [output appendString:singleOutput];
            }
        }
        return output;
    }
}

-(NSString*)outputForSingleInput:(NSString*)string {
    // Fush if stop character or whitespace
    BOOL isStopChar = [string isEqualToString:[[engine scheme] stopChar]];
    BOOL isWhiteSpace = [whiteSpace numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (isStopChar || isWhiteSpace) {
        // Only include the stop character if it does nothing to the engine
        if (!isStopChar || [engine isAtRoot]) {
            [uncommittedOutput addObject:string];
        }
        return [self flush];
    }

    NSArray* results = [engine executeWithInput:string];
    for (DJParseOutput* result in results) {
        if (result == nil) {
            // Add the input as-is if there is no mapping for it
            [uncommittedOutput addObject:string];
            // And finalize all outputs
            finalizedIndex = [uncommittedOutput count];
        }
        else {
            if ([result isPreviousFinal]) {
                finalizedIndex = [uncommittedOutput count];
            }
            else {
                // If there is a replacement then remove unfinalized
                if ([result output] != nil) {
                    [self removeUnfinalized];
                }
            }
            if ([result output] != nil) {
                [uncommittedOutput addObject:[result output]];
            }
            if ([result isFinal]) {
                // This includes any additions
                finalizedIndex = [uncommittedOutput count];
            }
        }
    }
    return [self finalizedOutput];
}

-(void)removeUnfinalized {
    while ([uncommittedOutput count] > finalizedIndex) {
        [uncommittedOutput removeObjectAtIndex:finalizedIndex];
    }
}

-(NSString*)finalizedOutput {
    if (finalizedIndex == 0) {
        return nil;
    }
    NSMutableString* output = [[NSMutableString alloc] init];
    while (finalizedIndex > 0) {
        [output appendString:[uncommittedOutput objectAtIndex:0]];
        [uncommittedOutput removeObjectAtIndex:0];
        --finalizedIndex;
    }
    return output;
}

-(BOOL)hasUnfinalizedOutput {
    return [uncommittedOutput count] > 0;
}

-(NSString*)unFinalizedOutput {
    if (finalizedIndex == [uncommittedOutput count]) {
        return nil;
    }
    unsigned long index = finalizedIndex;
    NSMutableString* output = [[NSMutableString alloc] init];
    while (index < [uncommittedOutput count]) {
        [output appendString:[uncommittedOutput objectAtIndex:index]];
        ++index;
    }
    return output;
}

-(NSString*)flush {
    [engine reset];
    finalizedIndex = [uncommittedOutput count];
    return [self finalizedOutput];
}

@end
