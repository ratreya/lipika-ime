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

// This regular expression only has static elements
static NSRegularExpression* simpleMappingExpression;

+(void)initialize {
    NSString *const simpleMappingPattern = @"^\\s*(\\S+)\\s+(\\S+)\\s*$";
    NSError* error;
    simpleMappingExpression = [NSRegularExpression regularExpressionWithPattern:simpleMappingPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid simple mapping expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

-(id)initWithScheme:(DJInputMethodScheme*)parentScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = parentScheme;
    parseTree = [NSMutableDictionary dictionaryWithCapacity:0];
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    isProcessingClassDefinition = NO;

    // Regular expressions for matching mapping items
    NSError* error;
    NSString *const classDefinitionPattern = [NSString stringWithFormat:@"^\\s*class\\s+(\\S+)\\s+\\%@\\s*$", scheme.classOpenDelimiter];
    classDefinitionExpression = [NSRegularExpression regularExpressionWithPattern:classDefinitionPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class definition expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    /*
     * We only support one class per mapping
     */
    NSString *const classKeyPattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S+)\\%@(\\S*)\\s*$", scheme.classOpenDelimiter, scheme.classCloseDelimiter];
    classKeyExpression = [NSRegularExpression regularExpressionWithPattern:classKeyPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    /*
     * And hence only one wildcard value
     */
    NSString *const wildcardValuePattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S*)\\s*$", scheme.wildcard];
    wildcardValueExpression = [NSRegularExpression regularExpressionWithPattern:wildcardValuePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }

    return self;
}

-(void)createMappingWithLine:(NSString*)line lineNumber:(int)lineNumber {
    currentLineNumber = lineNumber;
    if ([simpleMappingExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
        logDebug(@"Found mapping expression");
        
        NSString* key = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
        NSString* value = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
        if (isProcessingClassDefinition) {
            logDebug(@"Adding to class: %@", currentClassName);
            [self parseMappingForTree:currentClass key:key value:value];
        }
        else {
            logDebug(@"Adding to main parse tree");
            [self parseMappingForTree:parseTree key:key value:value];
        }
    }
    else if ([classDefinitionExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
        logDebug(@"Found beginning of class definition");
        isProcessingClassDefinition = YES;
        currentClassName = [classDefinitionExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
        currentClass = [[NSMutableDictionary alloc] initWithCapacity:0];
        logDebug(@"Class name: %@", currentClassName);
    }
    else if ([line isEqualToString:scheme.classCloseDelimiter]) {
        logDebug(@"Found end of class definition");
        isProcessingClassDefinition = NO;
        [classes setValue:currentClass forKey:currentClassName];
    }
    else {
        [NSException raise:@"Invalid line" format:@"Invalid line %d", currentLineNumber+1];
    }
}

-(void)onDoneParsingAtLine:(int)lineNumber {
    if (isProcessingClassDefinition) {
        logWarning(@"Error parsing scheme file: %@; One or more class(es) not closed", scheme.name);
    }
}

-(void)parseMappingForTree:(NSMutableDictionary*)tree key:(NSString*)key value:(NSString*)value {
    // Holds the list of inputs
    NSMutableArray* path;
    // Output with format elemets
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    if ([classKeyExpression numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])]) {
        logDebug(@"Found class mapping");
        // Parse the key
        NSString* preClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$1"];
        NSString* className = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$2"];
        NSString* postClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$3"];
        logDebug(@"Parsed key with pre-class: %@; class: %@", preClass, className);
        if ([postClass length]) {
            [NSException raise:@"Class mapping not suffix" format:@"Class mapping: %@ has invalid suffix: %@ at line: %d", className, postClass, currentLineNumber];
        }
        NSMutableDictionary* classTree = [classes valueForKey:className];
        if (classTree == nil) {
            [NSException raise:@"Unknown class" format:@"Unknown class name: %@ at line: %d", className, currentLineNumber];
        }
        // Create path from key
        path = charactersForString(preClass);
        // Parse the value; may not have wildcards in it
        if ([wildcardValueExpression numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])]) {
            NSString* preWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$1"];
            NSString* postWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$2"];
            logDebug(@"Parsed value with pre-wildcard: %@; post-wildcard: %@", preWildcard, postWildcard);
            // Output is nil and format is applied to all outputs of its subtree
            NSString* format = [NSString stringWithFormat:@"%@%%@%@", preWildcard, postWildcard];
            // Set the formated output tree as this node's subtree
            newNode.next = [self applyFormat:format toTree:classTree];
        }
        else {
            newNode.output = value;
            // Append the named parse tree as-is since there is no wildcard formatting
            newNode.next = classTree;
        }
    }
    else {
        logDebug(@"Found key: %@; value: %@", key, value);
        path = charactersForString(key);
        newNode.output = value;
    }
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

-(NSMutableDictionary *)classForName:(NSString *)className {
    return [classes valueForKey:className];
}

@end
