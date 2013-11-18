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

@interface DJForwardMapping : NSObject<DJSchemeMapping> {
    DJInputMethodScheme *scheme;
    // Input as NSString to DJParseTreeNode
    NSMutableDictionary *parseTree;
    // Class name as NSString to NSMutableDictionary of NSString to DJParseTreeNode
    NSMutableDictionary *classes;
}

@property NSDictionary *parseTree;
@property NSDictionary *classes;

-(NSString*)classNameForInput:(NSString*)input;
-(NSDictionary*)classForName:(NSString*)className;

@end
