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

#import "DJInputMethodEngine.h"
#include <AppKit/AppKit.h>

@implementation DJInputMethodEngine

@synthesize scheme;

-(id)initWithScheme:(DJInputMethodScheme*)inputScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = inputScheme;
    currentNode = nil;
    isOutputSinceRoot = NO;
    inputsSinceLastOutput = [[NSMutableArray alloc] initWithCapacity:0];
    return self;
}

-(NSArray*)executeWithInput:(NSString*)input {
    if ([input length] != 1) {
        [NSException raise:@"Number of characters in input not one" format:@"Expected one but input had %ld characters", [input length]];
    }
    DJParseOutput* result = [DJParseOutput alloc];
    if (currentNode == nil) {
        // Look for mapping at root of tree
        currentNode = [self getNodeForInput:input fromTree:[scheme parseTree]];
    }
    else {
        // Look for mapping at current level of the tree
        DJParseTreeNode* nextNode = [self getNodeForInput:input fromTree:[currentNode next]];
        if (nextNode == nil) {
            // If we had any output since root, then replay all inputs since last output at root
            if (isOutputSinceRoot) {
                // Search at root of tree
                NSArray* remaining = [[NSArray alloc] initWithArray:inputsSinceLastOutput];
                return [self replayAtRootWithInput:remaining];
            }
            else {
                currentNode = nil;
            }
        }
        else {
            currentNode = nextNode;
        }
    }
    if (currentNode == nil) {
        // We did not find any output mapping; echo all inputs
        result.output = [inputsSinceLastOutput componentsJoinedByString:@""];
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

-(DJParseTreeNode*)getNodeForInput:(NSString*)input fromTree:(NSMutableDictionary*)tree{
    DJParseTreeNode* result = [tree valueForKey:input];
    if (result != nil) {
        if ([result output] != nil) {
            isOutputSinceRoot = YES;
            [inputsSinceLastOutput removeAllObjects];
        }
        else {
            [inputsSinceLastOutput addObject:input];
        }
    }
    else {
        [inputsSinceLastOutput addObject:input];
    }
    return result;
}

-(BOOL)hasDeletable {
    return [inputsSinceLastOutput count] > 0;
}

-(BOOL)isAtRoot {
    return currentNode == nil;
}

-(void)reset {
    currentNode = nil;
    isOutputSinceRoot = NO;
    [inputsSinceLastOutput removeAllObjects];
}

@end
