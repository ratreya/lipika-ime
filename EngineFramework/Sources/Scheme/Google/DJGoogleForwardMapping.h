/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJGoogleSchemeMapping.h"
#import "DJForwardMapping.h"
#import "DJSimpleForwardMapping.h"

@interface DJGoogleForwardMapping : DJSimpleForwardMapping<DJGoogleSchemeMapping> {
    DJGoogleInputScheme *scheme;
    // Class name as NSString to DJReadWriteTrie
    NSMutableDictionary *classes;
}

-(NSString *)classNameForInput:(NSString *)input;
-(DJReadWriteTrie *)classForName:(NSString *)className;

@end
