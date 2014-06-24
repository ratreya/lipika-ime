/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJReadWriteTrie.h"
#import "DJSchemeHelper.h"
#import "DJLogger.h"

@implementation DJReadWriteTrie

-(id)initWithIsOverwrite:(BOOL)theIsOverwrite {
    self = [super init];
    if (self == nil) return self;
    isOverwrite = theIsOverwrite;
    trieHead = [[DJTrieNode alloc] init];
    return self;
}

-(DJTrieNode *)trieHead {
    return trieHead;
}

-(DJTrieNode *)nextNodeFromNode:(DJTrieNode *)currentNode forKey:(NSString *)key {
    if (!currentNode) currentNode = trieHead;
    return [currentNode.next objectForKey:key];
}

-(DJTrieNode *)nodeForKey:(NSString *)key {
    NSArray *keyChars = charactersForString(key);
    DJTrieNode *node = trieHead;
    for (NSString *keyChar in keyChars) {
        node = [node.next objectForKey:keyChar];
        if (!node) return nil;
    }
    return node;
}

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key {
    return [self addValue:value forKey:key atNode:trieHead withPath:key];
}

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key atNode:(DJTrieNode *)atNode withPath:(NSString *)path {
    NSMutableArray *pathChars = charactersForString(path);
    NSEnumerator * pathEnumerator = [pathChars objectEnumerator];
    NSString *pathChar;
    while (pathChar = [pathEnumerator nextObject]) {
        DJTrieNode *nextNode;
        if (!atNode.next) atNode.next = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!(nextNode = [atNode.next objectForKey:pathChar])) {
            nextNode = [[DJTrieNode alloc] init];
            [atNode.next setObject:nextNode forKey:pathChar];
        }
        atNode = nextNode;
    }
    atNode.key = key;
    [self setValue:value toNode:atNode];
    return atNode;
}

-(NSArray *)mergeTrieWithHead:(DJTrieNode *)fromTrieHead intoNode:(DJTrieNode *)atNode {
    NSMutableArray *leafNodes = [NSMutableArray arrayWithCapacity:0];
    [self mergeTrieFromNode:fromTrieHead intoTrieNode:atNode leafNodes:leafNodes];
    return leafNodes;
}

-(void)mergeTrieFromNode:(DJTrieNode *)fromTrieNode intoTrieNode:(DJTrieNode *)toTrieNode leafNodes:(NSMutableArray *)leafNodes {
    if (!toTrieNode.next && fromTrieNode.next.count) toTrieNode.next = [NSMutableDictionary dictionaryWithCapacity:fromTrieNode.next.count];
    for (NSString *fromKey in [fromTrieNode.next keyEnumerator]) {
        DJTrieNode *fromNode = [fromTrieNode.next objectForKey:fromKey];
        DJTrieNode *toNode;
        if (!(toNode = [toTrieNode.next objectForKey:fromKey])) {
            toNode = [[DJTrieNode alloc] init];
            [toTrieNode.next setObject:toNode forKey:fromKey];
        }
        if (fromNode.key) {
            toNode.key = fromNode.key;
        }
        [self setValue:fromNode.value toNode:toNode];
        if (fromNode.next && [fromNode.next count]) {
            [self mergeTrieFromNode:fromNode intoTrieNode:toNode leafNodes:leafNodes];
        }
        else {
            [leafNodes addObject:toNode];
        }
    }
}

-(DJReadWriteTrie *)cloneTrieUsingBlock:(DJTrieNode*(^)(DJReadWriteTrie *clonedTrie, DJTrieNode *original))cloneNode {
    DJReadWriteTrie *clonedTrie = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [self cloneToTrieNode:clonedTrie.trieHead forTrie:clonedTrie fromNode:trieHead usingBlock:cloneNode];
    return clonedTrie;
}

-(void)cloneToTrieNode:(DJTrieNode *)toNode forTrie:(DJReadWriteTrie *)clonedTrie fromNode:(DJTrieNode *)fromNode usingBlock:(DJTrieNode*(^)(DJReadWriteTrie *clonedTrie, DJTrieNode *original))cloneNode {
    for (NSString *key in [fromNode.next keyEnumerator]) {
        DJTrieNode *node = [fromNode.next objectForKey:key];
        if (node) {
            DJTrieNode *clonedNode = cloneNode(clonedTrie, node);
            if (!toNode.next) toNode.next = [NSMutableDictionary dictionaryWithCapacity:1];
            [toNode.next setObject:clonedNode forKey:key];
            [self cloneToTrieNode:clonedNode forTrie:clonedTrie fromNode:node usingBlock:cloneNode];
        }
    }
}

-(void)setValue:(NSString *)value toNode:(DJTrieNode *)toNode {
    if (toNode.value) {
        if (isOverwrite && value) {
            logWarning(@"Value: %@ for key: %@ being replaced by value: %@", toNode.value, toNode.key, value);
            toNode.value = value;
        }
    }
    else {
        toNode.value = value;
    }
}

@end
