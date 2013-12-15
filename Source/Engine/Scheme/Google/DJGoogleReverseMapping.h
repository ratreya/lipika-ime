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
#import "DJSimpleReverseMapping.h"

@interface DJGoogleReverseMapping : DJSimpleReverseMapping<DJGoogleSchemeMapping> {
    DJGoogleInputScheme *scheme;
    // Class name as NSString to NSString
    NSMutableDictionary *classes;
    // Mapping of class name to DJReadWriteTrie
    NSMutableDictionary *maxOutputSizesPerClass;
}

@end
