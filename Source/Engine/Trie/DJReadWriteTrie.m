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
    trieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
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
    return [self nodeForKey:charactersForString(key) atIndex:0 atNode:trieHead];
}

-(DJTrieNode *)nodeForKey:(NSArray *)keyChars atIndex:(int)index atNode:(DJTrieNode *)node {
    NSString *key = [keyChars objectAtIndex:index];
    DJTrieNode *nextNode = [node.next objectForKey:key];
    if (!nextNode) {
        return nil;
    }
    if (index > 0) {
        DJTrieNode *nextResult = [self nodeForKey:keyChars atIndex:index-1 atNode:nextNode];
        if (nextResult) return nextResult;
    }
    return nextNode;
}

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key {
    return [self addValue:value forKey:key atNode:trieHead];
}

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key atNode:(DJTrieNode *)atNode {
    return [self addValue:value forKey:key atNode:atNode withPath:key];
}

-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key atNode:(DJTrieNode *)atNode withPath:(NSString *)path {
    NSMutableArray *inputs = charactersForString(path);
    NSEnumerator * inputsEnumerator = [inputs objectEnumerator];
    NSString *input;
    DJTrieNode *nextNode;
    while (input = [inputsEnumerator nextObject]) {
        if (!atNode.next) atNode.next = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!(nextNode = [atNode.next objectForKey:input])) {
            nextNode = [[DJTrieNode alloc] init];
            [atNode.next setObject:nextNode forKey:input];
        }
        atNode = nextNode;
    }
    atNode.key = key;
    if (atNode.value && isOverwrite) {
        logWarning(@"Value: %@ for key: %@ being replaced by value: %@", atNode.value, atNode.key, value);
        atNode.value = value;
    }
    return atNode;
}

-(NSArray *)mergeTrieWithHead:(DJTrieNode *)toTrieHead atNode:(DJTrieNode *)atNode {
    NSMutableArray *leafNodes = [NSMutableArray arrayWithCapacity:0];
    [self mergeTrieWithHead:toTrieHead intoTrie:toTrieHead leafNodes:leafNodes];
    return leafNodes;
}

-(void)mergeTrieWithHead:(DJTrieNode *)fromTrieHead intoTrie:(DJTrieNode *)toTrieHead leafNodes:(NSMutableArray *)leafNodes {
    for (NSString *key in [fromTrieHead.next keyEnumerator]) {
        DJTrieNode *node = [fromTrieHead.next objectForKey:key];
        DJTrieNode *nextNode;
        if ((nextNode = [toTrieHead.next objectForKey:key])) {
            nextNode.value = node.value;
        }
        else {
            nextNode = [[DJTrieNode alloc] init];
            nextNode.key = node.key;
            nextNode.value = node.value;
            if (!toTrieHead.next) toTrieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
            [toTrieHead.next setObject:nextNode forKey:key];
        }
        if (node.next && [node.next count]) {
            [self mergeTrieWithHead:node intoTrie:nextNode leafNodes:leafNodes];
        }
        else {
            [leafNodes addObject:nextNode];
        }
    }
}

-(void)linkTrieWithHead:(DJTrieNode *)theTrieHead atNode:(DJTrieNode *)atNode {
    atNode.next = theTrieHead.next;
}

-(DJReadWriteTrie *)cloneTrieUsingBlock:(DJTrieNode*(^)(DJTrieNode *original))cloneNode {
    DJReadWriteTrie *newTrie = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [self cloneToTrieNode:newTrie.trieHead fromNode:trieHead usingBlock:cloneNode];
    return newTrie;
}

-(void)cloneToTrieNode:(DJTrieNode *)toNode fromNode:(DJTrieNode *)fromNode usingBlock:(DJTrieNode*(^)(DJTrieNode *original))cloneNode {
    for (NSString *key in [fromNode.next keyEnumerator]) {
        DJTrieNode *node = [fromNode.next objectForKey:key];
        if (node) {
            DJTrieNode *clonedNode = cloneNode(node);
            if (!toNode.next) toNode.next = [NSMutableDictionary dictionaryWithCapacity:1];
            [toNode.next setObject:clonedNode forKey:key];
            [self cloneToTrieNode:clonedNode fromNode:node usingBlock:cloneNode];
        }
    }
}

@end
