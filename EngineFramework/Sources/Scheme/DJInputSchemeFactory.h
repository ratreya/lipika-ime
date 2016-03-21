/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputMethodScheme.h"
#import "Constants.h"

@interface DJInputSchemeFactory : NSObject

+(id<DJInputMethodScheme>)inputSchemeForScript:(NSString *)script scheme:(NSString *)scheme type:(enum DJSchemeType)type;
+(NSArray *)availableScriptsForType:(enum DJSchemeType)type;
+(NSArray *)availableSchemesForType:(enum DJSchemeType)type;

@end
