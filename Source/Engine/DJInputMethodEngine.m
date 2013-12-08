/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputMethodEngine.h"
#import "DJSchemeHelper.h"
#include <AppKit/AppKit.h>

@implementation DJInputMethodEngine

@synthesize scheme;

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = inputScheme;
    currentNode = nil;
    inputsSinceRoot = [[NSMutableArray alloc] initWithCapacity:0];
    lastOutputIndex = 0;
    return self;
}

-(NSArray*)executeWithInput:(NSString*)input {
    if (input.length > 1) {
        NSMutableArray* aggregate = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString* singleInput in charactersForString(input)) {
            [aggregate addObjectsFromArray:[self executeWithInput:singleInput]];
        }
        return aggregate;
    }
    DJParseOutput* result = [DJParseOutput alloc];
    if (currentNode == nil) {
        // Look for mapping at root of tree
        currentNode = [self getNodeForInput:input fromTree:scheme.forwardMappings.parseTree];
    }
    else {
        // Look for mapping at current level of the tree
        DJParseTreeNode* nextNode = [self getNodeForInput:input fromTree:[currentNode next]];
        if (nextNode == nil) {
            // If we had any output since root, then replay all inputs since last output at root
            if ([self isOutputSinceRoot]) {
                // Search at root of tree
                return [self replayAtRootWithInput:[self inputsSinceLastOutput]];
            }
            else {
                currentNode = nil;
            }
        }
        else {
            currentNode = nextNode;
        }
    }
    result.input = [inputsSinceRoot componentsJoinedByString:@""];
    if (currentNode == nil) {
        // We did not find any output mapping; echo all inputs
        result.output = result.input;
        [self reset];
        result.isFinal = true;
    }
    else {
        result.output = currentNode.output;
        // If there cannot be another modification
        if (currentNode.next == nil) {
            result.isFinal = YES;
        }
    }
    return [[NSArray alloc] initWithObjects:result, nil];
}

-(NSArray*)replayAtRootWithInput:(NSArray*)remaining {
    [self reset];
    NSMutableArray* results;
    for (NSString* input in remaining) {
        NSArray* result = [self executeWithInput:input];
        if (result != nil) {
            if (results == nil) {
                results = [[NSMutableArray alloc] initWithCapacity:1];
                // The first result should indicate that all previous inputs are final
                [result[0] setIsPreviousFinal:YES];
            }
            [results addObjectsFromArray:result];
        }
    }
    return results;
}

-(DJParseTreeNode*)getNodeForInput:(NSString*)input fromTree:(NSDictionary*)tree{
    DJParseTreeNode* result = [tree valueForKey:input];
    [inputsSinceRoot addObject:input];
    if (result != nil && [result output] != nil) {
        lastOutputIndex = inputsSinceRoot.count;
    }
    return result;
}

-(BOOL)hasDeletable {
    return lastOutputIndex != inputsSinceRoot.count;
}

-(BOOL)isAtRoot {
    return currentNode == nil;
}

-(BOOL)isOutputSinceRoot {
    return lastOutputIndex > 0;
}

-(NSArray*)inputsSinceLastOutput {
    return [inputsSinceRoot subarrayWithRange:NSMakeRange(lastOutputIndex, inputsSinceRoot.count - lastOutputIndex)];
}

-(void)reset {
    currentNode = nil;
    lastOutputIndex = 0;
    [inputsSinceRoot removeAllObjects];
}

@end
