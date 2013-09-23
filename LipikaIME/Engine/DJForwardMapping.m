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

#import "DJForwardMapping.h"
#import "DJInputMethodScheme.h"
#import "DJParseTreeNode.h"
#import "DJLogger.h"

@implementation DJForwardMapping

@synthesize parseTree;
@synthesize classes;

-(id)initWithScheme:(DJInputMethodScheme*)parentScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = parentScheme;
    parseTree = [NSMutableDictionary dictionaryWithCapacity:0];
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    isProcessingClassDefinition = NO;

    return self;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    newNode.output = value;
    [self addMappingForKey:key newNode:newNode];
}

-(void)createClassMappingWithPreKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    NSMutableDictionary* classTree = [classes valueForKey:className];
    if (classTree == nil) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@ at line: %d", className, currentLineNumber];
    }
    // Parse the value; may not have wildcards in it
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    if (isWildcard) {
        // Output is nil and format is applied to all outputs of its subtree
        NSString* format = [NSString stringWithFormat:@"%@%%@%@", preValue, postValue];
        // Set the formated output tree as this node's subtree
        newNode.next = [self applyFormat:format toTree:classTree];
    }
    else {
        newNode.output = preValue;
        // Append the named parse tree as-is since there is no wildcard formatting
        newNode.next = classTree;
    }
    [self addMappingForKey:preKey newNode:newNode];
}

-(void)startClassDefinitionWithName:(NSString*)className {
    isProcessingClassDefinition = YES;
    currentClassName = className;
    currentClass = [[NSMutableDictionary alloc] initWithCapacity:0];
    logDebug(@"Class name: %@", currentClassName);
}

-(void)endClassDefinition {
    isProcessingClassDefinition = NO;
    [classes setValue:currentClass forKey:currentClassName];
}

-(void)onDoneParsingAtLine:(int)lineNumber {
    if (isProcessingClassDefinition) {
        logWarning(@"Error parsing scheme file: %@; One or more class(es) not closed", scheme.name);
    }
}

-(void)addMappingForKey:(NSString*)key newNode:(DJParseTreeNode*)newNode {
    NSMutableDictionary *tree;
    if (isProcessingClassDefinition) {
        logDebug(@"Adding to class: %@", currentClassName);
        tree = currentClass;
    }
    else {
        logDebug(@"Adding to main parse tree");
        tree = parseTree;
    }
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

-(NSMutableDictionary*)applyFormat:(NSString*)format toTree:(NSMutableDictionary*)classTree {
    NSMutableDictionary* newTree = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (NSString* key in [classTree keyEnumerator]) {
        DJParseTreeNode* node = [classTree valueForKey:key];
        if (node != nil) {
            DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
            if (node.output != nil) {
                newNode.output = [NSString stringWithFormat:format, node.output];
            }
            if (node.next != nil) {
                newNode.next = [self applyFormat:format toTree:node.next];
            }
            [newTree setValue:newNode forKey:key];
        }
    }
    return newTree;
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

-(NSString *)classNameForInput:(NSString*)input {
    for (NSString* className in [classes keyEnumerator]) {
        NSMutableDictionary* classMap = [classes valueForKey:className];
        if ([classMap objectForKey:input] != nil) {
            return className;
        }
    }
    return nil;
}

-(NSDictionary *)classForName:(NSString *)className {
    return [classes valueForKey:className];
}

@end
