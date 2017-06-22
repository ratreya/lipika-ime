/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputMethodScheme.h"
#import "DJSimpleForwardMapping.h"
#import "DJSimpleReverseMapping.h"
#import "OrderedDictionary.h"

@interface DJLipikaInputScheme : NSObject<DJInputMethodScheme> {
    DJSimpleForwardMapping *forwardMapping;
    DJSimpleReverseMapping *reverseMapping;
    DJReadWriteTrie *addMapping;
    OrderedDictionary *mappings;
    double fingerprint;
}

@property double fingerprint;

-(id)initWithMappings:(NSDictionary *)aMappings imeLines:(NSArray *)imeLines;
-(OrderedDictionary *)mappings;

@end
