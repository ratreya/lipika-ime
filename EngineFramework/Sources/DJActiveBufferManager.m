/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJActiveBufferManager.h"
#import "DJInputEngineFactory.h"
#import "DJLipikaUserSettings.h"
#import "DJSchemeHelper.h"
#import "DJLogger.h"

@implementation DJActiveBufferManager

static NSRegularExpression *whiteSpace;

+(void)initialize {
    NSError *error;
    whiteSpace = [NSRegularExpression regularExpressionWithPattern:@"^\\s+$" options:0 error:&error];
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
-(id)initWithEngine:(DJInputMethodEngine *)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = myEngine;
    [self commonInit];
    return self;
}

-(void)commonInit {
    uncommittedOutput = [NSMutableArray arrayWithCapacity:0];
    finalizedIndex = 0;
}

-(id<DJReverseMapping>)reverseMappings {
    return engine.scheme.reverseMappings;
}

-(void)changeToSchemeWithName:(NSString *)schemeName forScript:(NSString *)scriptName type:(enum DJSchemeType)type {
    @synchronized (self) {
        [DJInputEngineFactory setCurrentSchemeWithName:schemeName scriptName:scriptName type:type];
        engine = [DJInputEngineFactory inputEngine];
    }
}

-(NSArray *)outputForInput:(NSString *)string {
    @synchronized(self) {
        if (string.length < 1) return nil;
        // Handle non-character strings
        if (string.length > 1) {
            NSMutableArray *aggregate = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSString *singleInput in charactersForString(string)) {
                NSArray *output = [self outputForInput:singleInput];
                if (output) [aggregate addObjectsFromArray:output];
            }
            return aggregate.count ? aggregate : nil;
        }
        // Fush if whitespace
        BOOL isWhiteSpace = [whiteSpace numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
        if (isWhiteSpace) {
            [uncommittedOutput addObject:[DJParseOutput sameInputOutput:string]];
            return [self flush];
        }
        NSArray *results = [engine executeWithInput:string];
        [self handleResults:results];
        return nil;
    }
}

-(void)handleResults:(NSArray *)results {
    for (DJParseOutput *result in results) {
        if ([result isPreviousFinal]) {
            finalizedIndex = [uncommittedOutput count];
        }
        else {
            // If there is a replacement then remove unfinalized
            if ([result output] != nil) {
                [self removeUnfinalized];
            }
        }
        // Post-process the last two inputs
        if (uncommittedOutput.count > 0) {
            [engine.scheme postProcessResult:result withPreviousResult:[uncommittedOutput lastObject]];
        }
        if ([result output] != nil) {
            [uncommittedOutput addObject:result];
        }
        if ([result isFinal]) {
            // This includes any additions
            finalizedIndex = [uncommittedOutput count];
        }
    }
}

-(void)removeUnfinalized {
    @synchronized(self) {
        while ([uncommittedOutput count] > finalizedIndex) {
            [uncommittedOutput removeObjectAtIndex:finalizedIndex];
        }
    }
}

-(void)removeLastMapping {
    [uncommittedOutput removeLastObject];
    if (finalizedIndex > [uncommittedOutput count]) {
        finalizedIndex = [uncommittedOutput count];
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
            if ([uncommittedOutput count] > 0) {
                if (finalizedIndex == [uncommittedOutput count]) --finalizedIndex;
                DJParseOutput *lastBundle = [uncommittedOutput lastObject];
                if (lastBundle) [engine executeWithInput:lastBundle.input];
            }
        }
        else if ([uncommittedOutput count] > 0) {
            [engine reset];
            enum DJBackspaceBehavior behavior = [DJLipikaUserSettings backspaceBehavior];
            if (behavior == DJ_DELETE_MAPPING) {
                [self removeLastMapping];
            }
            else if (behavior == DJ_DELETE_INPUT) {
                DJParseOutput *lastBundle = [uncommittedOutput lastObject];
                [self removeLastMapping];
                if (lastBundle.input.length > 1) {
                    NSString *input = [lastBundle.input substringToIndex:lastBundle.input.length - 1];
                    if (input.length > 0) {
                        NSArray *results = [engine executeWithInput:input];
                        [self handleResults:results];
                    }
                }
                else if ([uncommittedOutput count] > 0) {
                    if (finalizedIndex == [uncommittedOutput count]) --finalizedIndex;
                    lastBundle = [uncommittedOutput lastObject];
                    if (lastBundle) [engine executeWithInput:lastBundle.input];
                }
            }
            else {
                logError(@"Unrecognized backspace behavior");
            }
        }
    }
}

-(NSArray *)flush {
    @synchronized(self) {
        [engine reset];
        NSArray *result = uncommittedOutput;
        [self reset];
        return result;
    }
}

-(NSArray *)uncommitted {
    NSMutableArray *results = [uncommittedOutput mutableCopy];
    // Add in the inputs that have gone into the engine which are yet to produce an output
    DJParseOutput *latestInput = [[DJParseOutput alloc] init];
    latestInput.input = [[engine inputsSinceLastOutput] componentsJoinedByString:@""];
    if (latestInput.input.length > 0) [results addObject:latestInput];
    return results;
}

-(void)reset {
    @synchronized(self) {
        uncommittedOutput = [NSMutableArray arrayWithCapacity:0];
        finalizedIndex = 0;
    }
}

@end
