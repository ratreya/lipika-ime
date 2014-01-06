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

@interface DJReadWriteTrie (Google)

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key atNode:(DJTrieNode *)atNode withPath:(NSString *)path;

@end

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

-(void)createClassMappingWithPreInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    [self createClassMappingForTrie:parseTrie preInput:preInput className:className postInput:postInput isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
}

-(void)createClassMappingForClass:(NSString *)containerClass preInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    DJReadWriteTrie *currentClass;
    if (!(currentClass = [classes objectForKey:containerClass])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", containerClass];
    }
    [self createClassMappingForTrie:currentClass preInput:preInput className:className postInput:postInput isWildcard:isWildcard preOutput:preOutput postOutput:postOutput];
}

-(void)createClassMappingForTrie:(DJReadWriteTrie *)trie preInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput {
    DJReadWriteTrie *classTrie = [classes objectForKey:className];
    if (classTrie == nil) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    // Clone the class trie and add postInput paths
    DJReadWriteTrie *clonedClassTrie = [classTrie cloneTrieUsingBlock:^DJTrieNode *(DJReadWriteTrie *clonedTrie, DJTrieNode *original) {
        DJTrieNode *clonedNode = [[DJTrieNode alloc] init];
        if (original.key) clonedNode.key = [preInput stringByAppendingString:original.key];
        if (original.value) {
            NSString *postKey = [clonedNode.key stringByAppendingString:postInput];
            NSString *postValue = isWildcard ? [NSString stringWithFormat:@"%@%@%@", preOutput, original.value, postOutput] : preOutput;
            [clonedTrie addValue: postValue forKey:postKey atNode:clonedNode withPath:postInput];
        }
        return clonedNode;
    }];
    // Merge the cloned trie at the preInput node
    DJTrieNode *atNode;
    if (preInput && preInput.length) atNode = [trie addValue:nil forKey:preInput];
    else atNode = trie.trieHead;
    [trie mergeTrieWithHead:clonedClassTrie.trieHead intoNode:atNode];
}

-(NSString *)classNameForInput:(NSString *)input {
    for (NSString *className in [classes keyEnumerator]) {
        DJReadWriteTrie *classTrie = [classes objectForKey:className];
        if ([classTrie nodeForKey:input] != nil) {
            return className;
        }
    }
    return nil;
}

-(DJReadWriteTrie *)classForName:(NSString *)className {
    return [classes objectForKey:className];
}

@end
