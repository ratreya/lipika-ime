/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJTrieNode.h"

@protocol DJForwardMapping <NSObject>

-(DJTrieNode *)nextNodeFromNode:(DJTrieNode *)currentNode forInput:(NSString *)input;

@end
