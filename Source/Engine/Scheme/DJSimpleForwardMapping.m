/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJSimpleForwardMapping.h"
#import "DJLogger.h"

@implementation DJSimpleForwardMapping

-(NSDictionary*)parseTree {
    return parseTree;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    newNode.output = value;
    [self addMappingForTree:parseTree key:key newNode:newNode];
}

-(void)addMappingForTree:(NSMutableDictionary*)tree key:(NSString*)key newNode:(DJParseTreeNode*)newNode {
    // Holds the list of inputs
    NSMutableArray* path = charactersForString(key);
    // Merge path into the parseTree and set the output
    NSMutableDictionary* currentNode = tree;
    for (int i = 0; i < [path count]; i++) {
        NSString* input = path[i];
        BOOL isLast = (i == [path count] - 1);
        DJParseTreeNode* existing = [currentNode valueForKey:input];
        if (existing == nil) {
            existing = [[DJParseTreeNode alloc] init];
            [currentNode setValue:existing forKey:input];
        }
        if (isLast) {
            [self mergeNode:newNode existing:existing key:key];
        }
        else {
            // Make a next node if it is nil
            if (existing.next == nil) {
                existing.next = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            currentNode = existing.next;
        }
    }
}

-(void)mergeNode:(DJParseTreeNode *)newNode existing:(DJParseTreeNode *)existingNode key:(NSString*)key {
    if (newNode.output != nil) {
        if (existingNode.output != nil) {
            logWarning(@"Value: %@ for key: %@ being replaced by value: %@", existingNode.output, key, newNode.output);
        }
        existingNode.output = newNode.output;
    }
    // Merge the newNode's next into exising node
    if (newNode.next != nil) {
        if (existingNode.next == nil) {
            existingNode.next = newNode.next;
        }
        else {
            NSMutableDictionary* newTree = newNode.next;
            NSMutableDictionary* existingTree = existingNode.next;
            for (NSString* nextKey in [newTree keyEnumerator]) {
                DJParseTreeNode* nextExistingNode = [existingTree valueForKey:nextKey];
                DJParseTreeNode* nextNewNode = [newTree valueForKey:nextKey];
                if (nextExistingNode == nil) {
                    [existingTree setValue:nextNewNode forKey:nextKey];
                }
                else {
                    [self mergeNode:nextNewNode existing:nextExistingNode key:[NSString stringWithFormat:@"%@%@", key, nextKey]];
                }
            }
        }
    }
}

@end
