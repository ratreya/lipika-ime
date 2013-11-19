/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJInputMethodEngine.h"
#import "Constants.h"

@interface DJInputEngineFactory : NSObject {
    NSString *scriptName;
    NSString *schemeName;
    enum DJSchemeType schemeType;
    NSMutableDictionary *schemesCache;
}

+(DJInputMethodEngine*)inputEngine;
+(void)setCurrentSchemeWithName:(NSString*)schemeName scriptName:(NSString*)scriptName type:(enum DJSchemeType)type;
+(enum DJSchemeType)currentSchemeType;
+(NSString*)currentScriptName;
+(NSString*)currentSchemeName;

@end
