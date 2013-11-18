/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputSchemeUberFactory.h"
#import "DJInputMethodScheme.h"
#import "DJGoogleSchemeFactory.h"

@implementation DJInputSchemeUberFactory

+(BOOL)acceptsSchemeFile:(NSString*)filePath {
    if ([DJGoogleSchemeFactory acceptsSchemeFile:filePath]) {
        return YES;
    }
    return NO;
}

+(id<DJInputMethodScheme>)inputSchemeForSchemeFile:(NSString*)filePath {
    if ([DJGoogleSchemeFactory acceptsSchemeFile:filePath]) {
        return [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
    }
    return nil;
}

@end
