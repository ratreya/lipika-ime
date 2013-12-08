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
    reverseTrieHead = [[DJParseTreeNode alloc] init];
    reverseTrieHead.next = [NSMutableDictionary dictionaryWithCapacity:0];
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
    return [self inputForOutput:outputs index:length node:reverseTrieHead];
}

-(DJParseOutput*)inputForOutput:(NSArray*)outputs index:(int)index node:(DJParseTreeNode*)node {
    NSString *key = [outputs objectAtIndex:index];
    DJParseTreeNode *nextNode = [node.next objectForKey:key];
    if (!nextNode) {
        return nil;
    }
    if (index > 0) {
        DJParseOutput *nextResult = [self inputForOutput:outputs index:--index node:nextNode];
        if (nextResult) return nextResult;
    }
    DJParseOutput *result = [[DJParseOutput alloc] init];
    result.input = nextNode.output;
    result.output = nextNode.input;
    return result;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    int size = ((int)value.length);
    if (size > 0) [self mergeIntoTrie:reverseTrieHead key:key value:value];
    if (size > maxOutputSize) {
        maxOutputSize = size;
    }
}

-(DJParseTreeNode*)mergeIntoTrie:(DJParseTreeNode*)current key:(NSString*)key value:(NSString*)value {
    return [self mergeIntoTrie:current key:key value:value path:value];
}

-(DJParseTreeNode*)mergeIntoTrie:(DJParseTreeNode*)current key:(NSString*)key value:(NSString*)value path:(NSString*)path {
    NSMutableArray *inputs = charactersForString(path);
    NSEnumerator * inputsEnumerator = [inputs reverseObjectEnumerator];
    NSString *input;
    DJParseTreeNode *nextNode;
    while (input = [inputsEnumerator nextObject]) {
        if (!current.next) current.next = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!(nextNode = [current.next objectForKey:input])) {
            nextNode = [[DJParseTreeNode alloc] init];
            [current.next setValue:nextNode forKey:input];
        }
        current = nextNode;
    }
    current.input = value;
    if (key) {
        current.output = key;
    }
    return current;
}

@end
