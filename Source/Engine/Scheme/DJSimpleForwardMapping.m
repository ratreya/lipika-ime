/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJSimpleForwardMapping.h"
#import "DJSchemeHelper.h"
#import "DJLogger.h"

@implementation DJSimpleForwardMapping

-(id)init {
    self = [super init];
    if (!self) return self;
    parseTrie = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    return self;
}

-(DJTrieNode *)nextNodeFromNode:(DJTrieNode *)currentNode forInput:(NSString *)input {
    return [parseTrie nextNodeFromNode:currentNode forKey:input];
}

-(void)createSimpleMappingWithInput:(NSString *)input output:(NSString *)output {
    [parseTrie addValue:output forKey:input];
}

@end
