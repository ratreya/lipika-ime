/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJForwardMapping.h"
#import "DJParseTreeNode.h"

@interface DJSimpleForwardMapping : NSObject<DJForwardMapping> {
    // Input as NSString to DJParseTreeNode
    NSMutableDictionary *parseTree;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value;
-(void)addMappingForTree:(NSMutableDictionary*)tree key:(NSString*)key newNode:(DJParseTreeNode*)newNode;
-(void)mergeNode:(DJParseTreeNode *)newNode existing:(DJParseTreeNode *)existingNode key:(NSString*)key;

@end
