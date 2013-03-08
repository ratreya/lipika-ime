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
#import "DJLipikaUserSettings.h"
#import "DJLogger.h"

@implementation DJLipikaBufferManager

static NSRegularExpression* whiteSpace;

+(void)initialize {
    NSError* error;
    whiteSpace = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid whitespace regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = [DJInputEngineFactory inputEngine];
    if (engine == nil) {
        return nil;
    }
    [self commonInit];
    return self;
}

// Only for testing purposes and not exposed in the interface
-(id)initWithEngine:(DJInputMethodEngine*)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = myEngine;
    [self commonInit];
    return self;
}

-(void)commonInit {
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finalizedIndex = 0;
}

-(void)changeToSchemeWithName:(NSString*)schemeName {
    @synchronized (self) {
        [DJInputEngineFactory setCurrentSchemeWithName:schemeName];
        engine = [DJInputEngineFactory inputEngine];
    }
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
    @synchronized(self) {
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
        return nil;
    }
}

-(void)removeUnfinalized {
    @synchronized(self) {
        while ([uncommittedOutput count] > finalizedIndex) {
            [uncommittedOutput removeObjectAtIndex:finalizedIndex];
        }
    }
}

-(BOOL)hasDeletable {
    return [uncommittedOutput count] > 0 || [engine hasDeletable];
}

-(void)delete {
    @synchronized(self) {
        if ([engine hasDeletable]) {
            // First clear out any inputs that have not produced output yet
            [engine reset];
        }
        else if ([uncommittedOutput count] > 0) {
            [engine reset];
            enum DJBackspaceBehavior behavior = [DJLipikaUserSettings backspaceBehavior];
            if (behavior == DJ_DELETE_MAPPING) {
                [uncommittedOutput removeLastObject];
            }
            else if (behavior == DJ_DELETE_OUTPUT) {
                NSString* lastOutput = [uncommittedOutput lastObject];
                [uncommittedOutput removeLastObject];
                if (lastOutput.length > 1) {
                    [uncommittedOutput addObject:[lastOutput substringToIndex:lastOutput.length - 1]];
                }
            }
            else {
                logError(@"Unrecognized backspace behavior");
            }
            if (finalizedIndex > [uncommittedOutput count]) {
                finalizedIndex = [uncommittedOutput count];
            }
        }
    }
}

-(BOOL)hasCurrentWord {
    return [uncommittedOutput count] > 0;
}

-(NSString*)currentWord {
    if ([uncommittedOutput count] <= 0) {
        return nil;
    }
    return [uncommittedOutput componentsJoinedByString:@""];
}

-(NSString*)flush {
    @synchronized(self) {
        [engine reset];
        NSString* result = [self currentWord];
        [self reset];
        return result;
    }
}

-(void)reset {
    @synchronized(self) {
        [uncommittedOutput removeAllObjects];
        finalizedIndex = 0;
    }
}

@end
