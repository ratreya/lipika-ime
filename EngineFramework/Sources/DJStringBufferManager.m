/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJStringBufferManager.h"

@interface DJActiveBufferManager (Private)

-(id)initWithEngine:(DJInputMethodEngine *)myEngine;

@end

@implementation DJStringBufferManager

-(id)init {
    self = [super init];
    if (!self) return self;
    delegate = [[DJActiveBufferManager alloc] init];
    return self;
}

// Only for testing purposes and not exposed in the interface
-(id)initWithEngine:(DJInputMethodEngine *)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    delegate = [[DJActiveBufferManager alloc] initWithEngine:myEngine];
    return self;
}

-(NSString *)outputForInput:(NSString *)string previousText:(NSString *)previousText {
    @synchronized(self) {
        if (!previousText) return [self outputForInput:string];
        DJParseOutput *previousResult = [delegate.reverseMappings inputForOutput:previousText];
        NSString *currentResult;
        if (previousResult) {
            replacement = previousResult.output;
            currentResult = [self outputForInput:[previousResult.input stringByAppendingString:string]];
        }
        else {
            currentResult = [self outputForInput:string];
        }
        return currentResult;
    }
}

-(NSString *)outputForInput:(NSString *)string {
    NSArray *results = [delegate outputForInput:string];
    return results ? [self outputFromBuffer:results] : nil;
}

-(void)delete {
    [delegate delete];
    // If there are no more glyphs then reset the replacement string
    if (![delegate hasDeletable]) {
        replacement = nil;
    }
}

-(BOOL)hasOutput {
    return delegate.uncommitted.count > 0;
}

-(NSString *)output {
    return [self outputFromBuffer:delegate.uncommitted];
}

-(NSString *)outputFromBuffer:(NSArray *)buffer {
    if (buffer.count <= 0) {
        return nil;
    }
    NSMutableString *word = [[NSMutableString alloc] init];
    for (DJParseOutput *bundle in buffer) {
        if (bundle.output) [word appendString:bundle.output];
    }
    return word;
}

-(NSString *)input {
    if (delegate.uncommitted.count <= 0) {
        return nil;
    }
    NSMutableString *word = [[NSMutableString alloc] init];
    for (DJParseOutput *bundle in delegate.uncommitted) {
        if (bundle.input) [word appendString:bundle.input];
    }
    return word;
}

-(int)maxOutputLength {
    return [delegate.reverseMappings maxOutputSize];
}

-(NSString *)replacement {
    return replacement;
}

-(NSString *)flush {
    replacement = nil;
    NSArray *results = [delegate flush];
    return results ? [self outputFromBuffer:results] : nil;
}

-(NSString *)revert {
    [self flush];
    return replacement;
}

-(void)changeToSchemeWithName:(NSString *)schemeName forScript:(id)scriptName type:(enum DJSchemeType)type {
    [delegate changeToSchemeWithName:schemeName forScript:scriptName type:type];
}

-(BOOL)hasDeletable {
    return [delegate hasDeletable];
}

-(id<DJReverseMapping>)reverseMappings {
    return delegate.reverseMappings;
}

@end
