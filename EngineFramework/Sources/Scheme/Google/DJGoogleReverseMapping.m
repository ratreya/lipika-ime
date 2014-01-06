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
#import "DJSchemeHelper.h"
#import "DJLogger.h"

@interface DJSimpleReverseMapping (Google)

+(DJTrieNode *)createReverseMappingForTrie:(DJReadWriteTrie *)trie withInput:(NSString *)input output:(NSString *)output;

@end

@interface DJReadWriteTrie (Google)

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key atNode:(DJTrieNode *)atNode withPath:(NSString *)path;

@end

@implementation DJGoogleReverseMapping

-(id)initWithScheme:(DJGoogleInputScheme *)parentScheme {
    self = [super init];
    if (self == nil) return self;
    scheme = parentScheme;
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    maxOutputSizesPerClass = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

-(void)createClassWithName:(NSString *)className {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        currentClass = [[DJReadWriteTrie alloc] initWithIsOverwrite:NO];
        [classes setObject:currentClass forKey:className];
    }
    else {
        [NSException raise:@"Class redefined" format:@"Redefining existing class with name: %@", className];
    }
}

-(void)createSimpleMappingForClass:(NSString *)className input:(NSString *)input output:(NSString *)output {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)output.length);
    if (size > 0) [DJSimpleReverseMapping createReverseMappingForTrie:currentClass withInput:input output:output];
    // Update the maximum size of value per class
    NSNumber *maxSize;
    if (!(maxSize = [maxOutputSizesPerClass objectForKey:className])) {
        [maxOutputSizesPerClass setObject:[NSNumber numberWithInt:size] forKey:className];
    }
    else if (size > [maxSize intValue]) {
        [maxOutputSizesPerClass setObject:[NSNumber numberWithInt:size] forKey:className];
    }
}

-(void)createClassMappingWithPreInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    [self createClassMappingForTrie:parseTrie preInput:preInput className:className postInput:postInput isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
    // Update maximum size
    NSNumber *classSize = [maxOutputSizesPerClass objectForKey:className];
    if (!classSize) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)preOutput.length) + [classSize intValue] + ((int)postOutput.length);
    if (size > maxOutputSize) {
        maxOutputSize = size;
    }
}

-(void)createClassMappingForClass:(NSString *)containerClass preInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:containerClass])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", containerClass];
    }
    [self createClassMappingForTrie:currentClass preInput:preInput className:className postInput:postInput isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
    // Update the maximum size of value per class
    NSNumber *classSize = [maxOutputSizesPerClass objectForKey:className];
    if (!classSize) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    int size = ((int)preOutput.length) + [classSize intValue] + ((int)postOutput.length);
    NSNumber *maxSize;
    if (!(maxSize = [maxOutputSizesPerClass objectForKey:containerClass])) {
        [maxOutputSizesPerClass setObject:[NSNumber numberWithInt:size] forKey:containerClass];
    }
    else if (size > [maxSize intValue]) {
        [maxOutputSizesPerClass setObject:[NSNumber numberWithInt:size] forKey:containerClass];
    }
}

-(void)createClassMappingForTrie:(DJReadWriteTrie *)trie preInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    // Create postOutput node if any
    DJTrieNode *atNode = trie.trieHead;
    if (isWildcard && postOutput.length > 0) {
        atNode = [DJSimpleReverseMapping createReverseMappingForTrie:trie withInput:nil output:postOutput];
    }
    // Clone the class trie and add preOutput paths
    DJReadWriteTrie *classTrie = [classes objectForKey:className];
    if (classTrie == nil) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    DJReadWriteTrie *clonedClassTrie = [classTrie cloneTrieUsingBlock:^DJTrieNode *(DJReadWriteTrie *clonedTrie, DJTrieNode *original) {
        DJTrieNode *clonedNode = [[DJTrieNode alloc] init];
        NSString *reversePostOutput = reverseStringForString(postOutput);
        if (original.key) clonedNode.key = isWildcard ? [reversePostOutput stringByAppendingString:original.key] : reversePostOutput;
        if (original.value) {
            NSString *reversePreOutput = reverseStringForString(preOutput);
            NSString *fullKey = isWildcard ? [clonedNode.key stringByAppendingString:reversePreOutput] : reversePreOutput;
            NSString *fullValue = [NSString stringWithFormat:@"%@%@%@", preInput, original.value, postInput];
            [clonedTrie addValue: fullValue forKey:fullKey atNode:clonedNode withPath:reversePreOutput];
        }
        return clonedNode;
    }];
    // Merge the cloned trie at the postOutput node
    [trie mergeTrieWithHead:clonedClassTrie.trieHead intoNode:atNode];
}

@end
