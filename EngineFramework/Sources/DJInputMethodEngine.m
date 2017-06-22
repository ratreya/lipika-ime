/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputMethodEngine.h"
#import "DJInputSchemeFactory.h"
#import "DJSchemeHelper.h"
#import "DJLipikaMappings.h"

@implementation DJInputMethodEngine

@synthesize scheme;

+(DJInputMethodEngine *)inputEngineForScheme:(NSString *)schemeName scriptName:(NSString *)scriptName type:(enum DJSchemeType)type {
    // Initialize with the given scheme file
    id<DJInputMethodScheme> scheme = [DJInputSchemeFactory inputSchemeForScript:scriptName scheme:schemeName type:type];
    if (scheme == nil) {
        [NSException raise:@"Invalid selection" format:@"Unable to load script: %@, scheme: %@ for type: %u", scriptName, schemeName, type];
    }
    return [[DJInputMethodEngine alloc] initWithScheme:scheme];
}

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

-(NSArray *)executeWithInput:(NSString *)input {
    if (input.length > 1) {
        NSMutableArray *aggregate = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString *singleInput in charactersForString(input)) {
            [aggregate addObjectsFromArray:[self executeWithInput:singleInput]];
        }
        return aggregate;
    }
    DJParseOutput *result = [DJParseOutput alloc];
    // First handle stop character
    if ([input isEqualToString:scheme.stopChar]) {
        // Only include the stop character if it does nothing to the engine
        if ([self isAtRoot]) {
            result = [DJParseOutput sameInputOutput:input];
        }
        else {
            result = [DJParseOutput sameInputOutput:[[self inputsSinceLastOutput] componentsJoinedByString:@""]];
        }
        result.isPreviousFinal = YES;
        result.isFinal = YES;
        [self reset];
        return [NSArray arrayWithObject:result];
    }
    if (currentNode == nil) {
        // Look for mapping at root of trie
        currentNode = [self nextNodeFromNode:nil forInput:input];
    }
    else {
        // Look for mapping at current level of the trie
        DJTrieNode *nextNode = [self nextNodeFromNode:currentNode forInput:input];
        if (nextNode == nil) {
            // If we had any output since root, then replay all inputs since last output at root
            if ([self isOutputSinceRoot]) {
                // Search at root of trie
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
        result.output = currentNode.value;
        // If there cannot be another modification
        if (currentNode.next == nil) {
            result.isFinal = YES;
        }
    }
    return [[NSArray alloc] initWithObjects:result, nil];
}

-(NSArray *)replayAtRootWithInput:(NSArray *)remaining {
    [self reset];
    NSMutableArray *results;
    for (NSString *input in remaining) {
        NSArray *result = [self executeWithInput:input];
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

-(DJTrieNode *)nextNodeFromNode:(DJTrieNode *)node forInput:(NSString *)input {
    DJTrieNode *result = [scheme.forwardMappings nextNodeFromNode:node forInput:input];
    [inputsSinceRoot addObject:input];
    if (result != nil && result.value != nil) {
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

-(NSArray *)inputsSinceLastOutput {
    return [inputsSinceRoot subarrayWithRange:NSMakeRange(lastOutputIndex, inputsSinceRoot.count - lastOutputIndex)];
}

-(void)reset {
    currentNode = nil;
    lastOutputIndex = 0;
    [inputsSinceRoot removeAllObjects];
}

@end
