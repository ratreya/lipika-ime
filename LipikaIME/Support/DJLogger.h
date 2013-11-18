/*
 * LipikaIME a userconfigurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "Constants.h"

extern void logDebug(NSString* format, ...);
extern void logWarning(NSString* format, ...);
extern void logError(NSString* format, ...);

extern NSString* startBatch();
extern NSArray* endBatch(NSString* batchId);
extern NSString* getUUIDString();