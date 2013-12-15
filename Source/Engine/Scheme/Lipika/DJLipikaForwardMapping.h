/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJSimpleForwardMapping.h"

@interface DJLipikaForwardMapping : DJSimpleForwardMapping {
    NSMutableDictionary *inputRegexs;
}

-(id)init;
-(void)addInputRegex:(NSString *)regex insertionValue:(NSString *)value;

@end
