/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJReverseMapping.h"
#import "DJReadWriteTrie.h"

@interface DJSimpleReverseMapping : NSObject<DJReverseMapping> {
    DJReadWriteTrie *parseTrie;
    // Overall maximum output size of this scheme
    int maxOutputSize;
}

-(void)createSimpleMappingWithInput:(NSString *)input output:(NSString *)output;

@end
