/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaInputScheme.h"

@interface DJLipikaSchemeFactory : NSObject {
    DJLipikaInputScheme *scheme;
}

+(void)setSchemesDirectory:(NSString *)directory;
+(DJLipikaInputScheme *)inputSchemeForScript:script scheme:scheme;
+(NSArray *)availableScripts;
+(NSArray *)availableSchemes;

-(id)initWithScript:(NSString *)scriptName scheme:(NSString *)schemeName;
-(id<DJInputMethodScheme>)scheme;

@end
