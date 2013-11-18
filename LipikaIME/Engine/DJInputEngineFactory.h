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

@interface DJInputEngineFactory : NSObject {
    NSString* scriptName;
    NSString* schemeName;
    NSMutableDictionary* schemesCache;
}

+(DJInputMethodEngine*)inputEngine;
+(void)setCurrentSchemeWithName:(NSString*)schemeName scriptName:(NSString*)scriptName;
+(NSString*)currentScriptName;
+(NSString*)currentSchemeName;
+(NSArray*)availableScripts;
+(NSArray*)availableSchemes;

@end
