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
            break;
        case DJ_GOOGLE:
            return [DJGoogleSchemeFactory inputSchemeForScheme:scheme];
            break;
        default:
            return nil;
            break;
    }
}

+(NSArray *)availableScriptsForType:(enum DJSchemeType)type {
    switch (type) {
        case DJ_LIPIKA:
            return [DJLipikaSchemeFactory availableScripts];
            break;
        default:
            return nil;
            break;
    }
}

+(NSArray *)availableSchemesForType:(enum DJSchemeType)type {
    switch (type) {
        case DJ_LIPIKA:
            return [DJLipikaSchemeFactory availableSchemes];
            break;
        case DJ_GOOGLE:
            return [DJGoogleSchemeFactory availableSchemes];
            break;
        default:
            return nil;
            break;
    }
}

@end
