/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleForwardMapping.h"
#import "DJGoogleInputScheme.h"
#import "DJTrieNode.h"
#import "DJLogger.h"

@implementation DJGoogleForwardMapping

-(id)initWithScheme:(DJGoogleInputScheme *)parentScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = parentScheme;
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

-(void)createClassWithName:(NSString *)className {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        currentClass = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
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
    [currentClass addValue:output forKey:input];
}

-(void)createClassMappingWithPreInput:(NSString *)preInput className:(NSString *)className isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    [self createClassMappingForTrie:parseTrie preInput:preInput className:className isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
}

-(void)createClassMappingForClass:(NSString *)containerClass preInput:(NSString *)preInput className:(NSString *)className isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:containerClass])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", containerClass];
    }
    [self createClassMappingForTrie:currentClass preInput:preInput className:className isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
}

-(void)createClassMappingForTrie:(DJReadWriteTrie *)trie preInput:(NSString *)preInput className:(NSString *)className isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    DJReadWriteTrie *classTrie = [classes objectForKey:className];
    if (classTrie == nil) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    // Clone the class trie and format it if needed
    DJTrieNode *nextNode;
    if (isWildcard) {
        // Output is nil and format is applied to all outputs of its subtrie
        NSString *format = [NSString stringWithFormat:@"%@%%@%@", preOutput, postOutput];
        // Set the formated output trie as this node's subtrie
        DJReadWriteTrie *clonedClassTrie = [classTrie cloneTrieUsingBlock:^DJTrieNode *(DJTrieNode *original) {
            DJTrieNode *clonedNode = [[DJTrieNode alloc] init];
            clonedNode.key = original.key;
            clonedNode.value = [NSString stringWithFormat:format, original.value];
            return clonedNode;
        }];
        nextNode = clonedClassTrie.trieHead;
    }
    else {
        // Append the named parse trie as-is since there is no wildcard formatting
        nextNode = classTrie.trieHead;
    }
    DJTrieNode *atNode = [parseTrie addValue:preOutput forKey:preInput];
    [parseTrie linkTrieWithHead:nextNode atNode:atNode];
}

-(NSString *)classNameForInput:(NSString *)input {
    for (NSString *className in [classes keyEnumerator]) {
        NSMutableDictionary *classMap = [classes objectForKey:className];
        if ([classMap objectForKey:input] != nil) {
            return className;
        }
    }
    return nil;
}

-(DJReadWriteTrie *)classForName:(NSString *)className {
    return [classes objectForKey:className];
}

@end
