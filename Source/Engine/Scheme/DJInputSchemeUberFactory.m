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
#import "DJLipikaSchemeFactory.h"

@implementation DJInputSchemeUberFactory

+(id<DJInputMethodScheme>)inputSchemeForScript:(NSString *)script scheme:(NSString *)scheme type:(enum DJSchemeType)type {
    switch (type) {
        case DJ_LIPIKA:
            return [DJLipikaSchemeFactory inputSchemeForScript:script scheme:scheme];
        case DJ_GOOGLE:
            return [DJGoogleSchemeFactory inputSchemeForScheme:scheme];
        default:
            return nil;
    }
}

+(NSArray *)availableScriptsForType:(enum DJSchemeType)type {
    switch (type) {
        case DJ_LIPIKA:
            return [DJLipikaSchemeFactory availableScripts];
        default:
            return nil;
    }
}

+(NSArray *)availableSchemesForType:(enum DJSchemeType)type {
    switch (type) {
        case DJ_LIPIKA:
            return [DJLipikaSchemeFactory availableSchemes];
        case DJ_GOOGLE:
            return [DJGoogleSchemeFactory availableSchemes];
        default:
            return nil;
    }
}

@end
