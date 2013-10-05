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

#import "DJReverseMapping.h"
#import "DJInputMethodScheme.h"
#import "DJLogger.h"

@implementation DJReverseTreeNode

@synthesize outputMap;
@synthesize nextClass;

-(id)init {
    self = [super init];
    next = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

@end

@implementation DJReverseMapping

-(id)initWithScheme:(DJInputMethodScheme*)parentScheme {
    self = [super init];
    if (self == nil) return self;
    scheme = parentScheme;
    reverseTrieHead = [[DJReverseTreeNode alloc] init];
    reverseTrieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    maxOutputSizesPerClass = [NSMutableDictionary dictionaryWithCapacity:0];
    maxOutputSize = 0;
    return self;
}

-(int)maxOutputSize {
    return maxOutputSize;
}

-(DJParseOutput*)inputForOutput:(NSString*)output {
    NSMutableArray *outputs = charactersForString(output);
    int length = ((int)outputs.count)-1;
    if (length < 0) return nil;
    // Find the next node
    NSString *key = [outputs objectAtIndex:length];
    DJReverseTreeNode *nextNode = [reverseTrieHead.next objectForKey:key];
    if (!nextNode) {
        NSString *className = [self classNameForInput:key];
        if (className) {
            nextNode = [reverseTrieHead.nextClass objectForKey:className];
        }
    }
    if (nextNode) {
        return [self inputForOutput:outputs index:length node:nextNode];
    }
    else {
        return  nil;
    }
}

-(DJParseOutput*)inputForOutput:(NSArray*)outputs index:(int)index node:(DJReverseTreeNode*)node {
    NSString *key = [outputs objectAtIndex:index];
    NSString *classValue;
    if (index > 0) {
        // Store format value if any
        /*
         * TODO: outputMap is not a dictionary - its a trie!
         */
        if (node.outputMap) classValue = [node.outputMap objectForKey:key];
        // Recurse down the tree if there are child nodes
        NSString *nextKey = [outputs objectAtIndex:index-1];
        DJReverseTreeNode *nextNode = [node.next objectForKey:nextKey];
        DJParseOutput *nextResult;
        if (nextNode) {
            nextResult = [self inputForOutput:outputs index:--index node:nextNode];
        }
        else {
            NSString *className = [self classNameForInput:nextKey];
            if (className) {
                nextNode = [node.nextClass objectForKey:className];
                if (nextNode) nextResult = [self inputForOutput:outputs index:index node:nextNode];
            }
        }
        if (nextResult) {
            if (classValue && nextResult.input) nextResult.input = [NSString stringWithFormat:nextResult.input, classValue];
            return nextResult;
        }
        else {
            // First tail
            DJParseOutput *result = [[DJParseOutput alloc] init];
            result.output = [[outputs subarrayWithRange:NSMakeRange(index, [outputs count] - index)] componentsJoinedByString:@""];
            result.input = node.output;
            return result;
        }
    }
    else {
        // Second tail
        DJParseOutput *result = [[DJParseOutput alloc] init];
        result.output = [outputs componentsJoinedByString:@""];
        result.input = node.output;
        return result;
    }
}

-(void)createClassWithName:(NSString *)className {
    DJReverseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        currentClass = [[DJReverseTreeNode alloc] init];
        [classes setObject:currentClass forKey:className];
    }
    else {
        [NSException raise:@"Class redefined" format:@"Redefining existing class with name: %@", className];
    }
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    [self mergeIntoTrie:reverseTrieHead.next key:key value:value];
    int size = ((int)value.length);
    if (size > maxOutputSize) {
        maxOutputSize = size;
    }
}

-(void)createSimpleMappingForClass:(NSString *)className key:(NSString *)key value:(NSString *)value {
    DJReverseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    [self mergeIntoTrie:currentClass.next key:key value:value];
    // Update the maximum size of value per class
    int size = ((int)value.length);
    NSNumber *maxSize;
    if (!(maxSize = [maxOutputSizesPerClass valueForKey:className])) {
        [maxOutputSizesPerClass setValue:[NSNumber numberWithInt:size] forKey:className];
    }
    else if (size > [maxSize intValue]) {
        [maxOutputSizesPerClass setValue:[NSNumber numberWithInt:size] forKey:className];
    }
}

-(void)createClassMappingWithPreKey:(NSString *)preKey className:(NSString *)className isWildcard:(BOOL)isWildcard preValue:(NSString *)preValue postValue:(NSString *)postValue {
    [self createClassMappingForTrie:reverseTrieHead preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
    // Update maximum size
    NSNumber *classSize = [maxOutputSizesPerClass valueForKey:className];
    if (!classSize) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)preValue.length) + [classSize intValue] + ((int)postValue.length);
    if (size > maxOutputSize) {
        maxOutputSize = size;
    }
}

-(void)createClassMappingForClass:(NSString *)containerClass preKey:(NSString *)preKey className:(NSString *)className isWildcard:(BOOL)isWildcard preValue:(NSString *)preValue postValue:(NSString *)postValue {
    DJReverseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    [self createClassMappingForTrie:currentClass preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
    // Update maximum size
    NSNumber *classSize = [maxOutputSizesPerClass valueForKey:className];
    if (!classSize) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)preValue.length) + [classSize intValue] + ((int)postValue.length);
    NSNumber *maxSize;
    if (!(maxSize = [maxOutputSizesPerClass valueForKey:containerClass])) {
        [maxOutputSizesPerClass setValue:[NSNumber numberWithInt:size] forKey:containerClass];
    }
    else if (size > [maxSize intValue]) {
        [maxOutputSizesPerClass setValue:[NSNumber numberWithInt:size] forKey:containerClass];
    }
}

-(void)createClassMappingForTrie:(DJReverseTreeNode*)trieHead preKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    DJReverseTreeNode *node = trieHead;
    // Merge in all the post values
    if (postValue && postValue.length > 0) {
        node = [self mergeIntoTrie:trieHead.next key:nil value:postValue];
    }
    // Merge in the class hop
    if (!node.nextClass) node.nextClass = [NSMutableDictionary dictionaryWithCapacity:1];
    DJReverseTreeNode *nextNode = [node.nextClass objectForKey:className];
    if (!nextNode) {
        nextNode = [[DJReverseTreeNode alloc] init];
        nextNode.outputMap = [classes objectForKey:className];
        [node.nextClass setObject:nextNode forKey:className];
    }
    // Merge in the pre values
    NSString* format = [NSString stringWithFormat:@"%@%%@", preKey];
    if (preValue && preValue.length > 0) {
        [self mergeIntoTrie:nextNode.next key:format value:preValue];
    }
    else {
        if (nextNode.output) {
            logWarning(@"Reverse mapping %@ being replaced by %@", nextNode.output, format);
        }
        nextNode.output = format;
    }
}

-(DJReverseTreeNode*)mergeIntoTrie:(NSMutableDictionary*)next key:(NSString*)key value:(NSString*)value {
    NSMutableArray *inputs = charactersForString(value);
    NSEnumerator * inputsEnumerator = [inputs reverseObjectEnumerator];
    NSString *input;
    DJReverseTreeNode *nextNode;
    while (input = [inputsEnumerator nextObject]) {
        if (!(nextNode = [next objectForKey:input])) {
            nextNode = [[DJReverseTreeNode alloc] init];
            [next setValue:nextNode forKey:input];
        }
        next = nextNode.next;
    }
    if (key) {
        if (nextNode.output) {
            logWarning(@"Reverse mapping for %@: %@ being preferred to %@", value, nextNode.output, key);
        }
        else {
            nextNode.output = key;
        }
    }
    return nextNode;
}

/*
 * TODO: Reverse mapping trie is non-deterministic!!
 * Below function does not work in all cases.
 */
-(NSString *)classNameForInput:(NSString*)key {
    for (NSString* className in [classes keyEnumerator]) {
        DJReverseTreeNode* head = [classes valueForKey:className];
        DJReverseTreeNode* value = [head.next objectForKey:key];
        if (value != nil && value.output != nil) {
            return className;
        }
    }
    return nil;
}


@end
