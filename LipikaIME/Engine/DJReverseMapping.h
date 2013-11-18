/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJSchemeMapping.h"
#import "DJParseTreeNode.h"
#import "DJParseOutput.h"

@interface DJReverseMapping : NSObject<DJSchemeMapping> {
    DJInputMethodScheme *scheme;
    // Mapping of individual output character to a DJParseTreeNode
    DJParseTreeNode *reverseTrieHead;
    // Class name as NSString to NSString
    NSMutableDictionary *classes;
    // Mapping of class name to trie head (DJParseTreeNode)
    NSMutableDictionary *maxOutputSizesPerClass;
    // Overall maximum output size of this scheme
    int maxOutputSize;
}

-(int)maxOutputSize;
-(DJParseOutput*)inputForOutput:(NSString*)output;

@end
