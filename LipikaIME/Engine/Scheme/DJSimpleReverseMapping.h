/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJReverseMapping.h"
#import "DJParseTreeNode.h"

@interface DJSimpleReverseMapping : NSObject<DJReverseMapping> {
    // Mapping of individual output character to a DJParseTreeNode
    DJParseTreeNode *reverseTrieHead;
    // Overall maximum output size of this scheme
    int maxOutputSize;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value;
-(DJParseTreeNode*)mergeIntoTrie:(DJParseTreeNode*)current key:(NSString*)key value:(NSString*)value;
-(DJParseTreeNode*)mergeIntoTrie:(DJParseTreeNode*)current key:(NSString*)key value:(NSString*)value path:(NSString*)path;

@end
