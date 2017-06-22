/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "OrderedDictionary.h"

@interface DJMap : NSObject {
    NSString *scheme;
    NSString *script;
}

@property NSString *scheme;
@property NSString *script;

-(id)initWithScript:(NSString *)script scheme:(NSString *)scheme;

@end

@interface DJLipikaMappings : NSObject {}

+(OrderedDictionary *) mappingsForScriptName:(NSString *)scriptName schemeName:(NSString *)schemeName;
+(void)storeMappings:(OrderedDictionary *)mappings scriptName:(NSString *)scriptName schemeName:(NSString *)schemeName;
+(void)storeMappingsContent:(NSString *)mappings scriptName:(NSString *)scriptName schemeName:(NSString *)schemeName;
+(double)fingerPrintForScript:(NSString *)scriptName scheme:(NSString *)schemeName;

@end
