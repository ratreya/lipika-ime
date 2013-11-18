/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJInputMethodScheme.h"

@interface DJInputSchemeUberFactory : NSObject

+(BOOL)acceptsSchemeFile:(NSString*)filePath;
+(id<DJInputMethodScheme>)inputSchemeForSchemeFile:(NSString*)filePath;

@end
