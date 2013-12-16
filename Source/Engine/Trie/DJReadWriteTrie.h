/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJReadOnlyTrie.h"

@interface DJReadWriteTrie : NSObject<DJReadOnlyTrie> {
    DJTrieNode *trieHead;
    BOOL isOverwrite;
}

-(id)initWithIsOverwrite:(BOOL)theIsOverwrite;
-(DJTrieNode *)addValue:(NSString *)value forKey:(NSString *)key;
-(NSArray *)mergeTrieWithHead:(DJTrieNode *)trieHead intoNode:(DJTrieNode *)atNode;
-(DJReadWriteTrie *)cloneTrieUsingBlock:(DJTrieNode*(^)(DJTrieNode *original))cloneNode;

@end
