/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJSimpleReverseMapping.h"
#import "DJSchemeHelper.h"

@implementation DJSimpleReverseMapping

-(id)init {
    self = [super init];
    if (self == nil) return self;
    parseTrie = [[DJReadWriteTrie alloc] initWithIsOverwrite:NO];
    maxOutputSize = 0;
    return self;
}

-(int)maxOutputSize {
    return maxOutputSize;
}

-(DJParseOutput *)inputForOutput:(NSString *)output {
    NSMutableArray *outputs = charactersForString(output);
    int length = ((int)outputs.count)-1;
    if (length < 0) return nil;
    return [self inputForOutput:outputs index:length node:parseTrie.trieHead];
}

-(DJParseOutput *)inputForOutput:(NSArray *)outputs index:(int)index node:(DJTrieNode *)node {
    NSString *key = [outputs objectAtIndex:index];
    DJTrieNode *nextNode = [parseTrie nextNodeFromNode:node forKey:key];
    if (!nextNode) {
        return nil;
    }
    if (index > 0) {
        DJParseOutput *nextResult = [self inputForOutput:outputs index:index-1 node:nextNode];
        if (nextResult) return nextResult;
    }
    DJParseOutput *result = [[DJParseOutput alloc] init];
    result.input = nextNode.value;
    result.output = nextNode.key;
    return result;
}

-(void)createSimpleMappingWithInput:(NSString *)input output:(NSString *)output {
    int size = ((int)output.length);
    if (size > maxOutputSize) {
        maxOutputSize = size;
    }
    if (size > 0) {
        [DJSimpleReverseMapping createReverseMappingForTrie:parseTrie withInput:input output:output];
    }
}

+(DJTrieNode *)createReverseMappingForTrie:(DJReadWriteTrie *)trie withInput:(NSString *)input output:(NSString *)output {
    NSMutableArray *reversedOutputArray = [NSMutableArray arrayWithCapacity:output.length];
    [charactersForString(output) enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [reversedOutputArray addObject:obj];
    }];
    return [trie addValue:input forKey:[reversedOutputArray componentsJoinedByString:@""]];
}

@end
