/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJActiveBufferManager.h"

@interface DJCombinedBufferManager : NSObject {
    DJActiveBufferManager *manager;
    unsigned long currentPosition;
}

-(unsigned long)currentPosition;
-(void)setCurrentPosition:(unsigned long)thePosition;


@end
