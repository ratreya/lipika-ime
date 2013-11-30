/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleReverseMapping.h"
#import "DJGoogleInputScheme.h"
#import "DJLogger.h"

@implementation DJGoogleReverseMapping

-(id)initWithScheme:(DJGoogleInputScheme*)parentScheme {
    self = [super init];
    if (self == nil) return self;
    scheme = parentScheme;
    reverseTrieHead = [[DJParseTreeNode alloc] init];
    reverseTrieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    maxOutputSizesPerClass = [NSMutableDictionary dictionaryWithCapacity:0];
    maxOutputSize = 0;
    return self;
}

-(void)createClassWithName:(NSString *)className {
    DJParseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        currentClass = [[DJParseTreeNode alloc] init];
        [classes setObject:currentClass forKey:className];
    }
    else {
        [NSException raise:@"Class redefined" format:@"Redefining existing class with name: %@", className];
    }
}

-(void)createSimpleMappingForClass:(NSString *)className key:(NSString *)key value:(NSString *)value {
    DJParseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)value.length);
    if (size > 0) [self mergeIntoTrie:currentClass key:key value:value];
    // Update the maximum size of value per class
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
    DJParseTreeNode *currentClass;
    if (!(currentClass = [classes objectForKey:containerClass])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", containerClass];
    }
    [self createClassMappingForTrie:currentClass preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
    // Update the maximum size of value per class
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

-(void)createClassMappingForTrie:(DJParseTreeNode*)trieHead preKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    DJParseTreeNode *node = trieHead;
    // Merge in all the post values
    if (postValue && postValue.length > 0) {
        node = [self mergeIntoTrie:trieHead key:nil value:postValue];
    }
    // Merge in the class hop
    NSArray *leafNodes = [self mergeClassWithName:className intoTrie:node];
    
    // Merge in the pre values
    for (DJParseTreeNode *leafNode in leafNodes) {
        NSString *key = [preKey stringByAppendingString:leafNode.output];
        NSString *value = [NSString stringWithFormat:@"%@%@%@", preValue, leafNode.input, postValue];
        if (preValue && preValue.length > 0) {
            [self mergeIntoTrie:leafNode key:key value:value path:preValue];
        }
        else {
            leafNode.input = value;
            leafNode.output = key;
        }
    }
}

-(NSArray*)mergeClassWithName:(NSString*)className intoTrie:(DJParseTreeNode*)trieHead {
    DJParseTreeNode *classNode = [classes objectForKey:className];
    if (!classNode) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    NSMutableArray *leafNodes = [NSMutableArray arrayWithCapacity:0];
    [self mergeTrieWithHead:classNode intoTrie:trieHead leafNodes:leafNodes];
    return leafNodes;
}

-(void)mergeTrieWithHead:(DJParseTreeNode*)classNode intoTrie:(DJParseTreeNode*)trieHead leafNodes:(NSMutableArray*)leafNodes {
    for (NSString *classKey in [classNode.next keyEnumerator]) {
        DJParseTreeNode *classValue = [classNode.next objectForKey:classKey];
        DJParseTreeNode *nextValue;
        if ((nextValue = [trieHead.next objectForKey:classKey])) {
            nextValue.output = classValue.output;
        }
        else {
            nextValue = [[DJParseTreeNode alloc] init];
            nextValue.input = classValue.input;
            nextValue.output = classValue.output;
            if (!trieHead.next) trieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
            [trieHead.next setObject:nextValue forKey:classKey];
        }
        if (classValue.next && [classValue.next count]) {
            [self mergeTrieWithHead:classValue intoTrie:nextValue leafNodes:leafNodes];
        }
        else {
            [leafNodes addObject:nextValue];
        }
    }
}

@end
