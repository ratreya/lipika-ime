/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJInputEngineFactory.h"
#import "DJLipikaUserSettings.h"
#import "DJInputSchemeUberFactory.h"
#import "DJLogger.h"

@interface DJInputEngineFactory ()

@property NSString *scriptName;
@property NSString *schemeName;
@property enum DJSchemeType schemeType;

@end

@implementation DJInputEngineFactory

@synthesize schemeType;
@synthesize schemeName;
@synthesize scriptName;

static DJInputEngineFactory* singletonFactory = nil;

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        singletonFactory = [[DJInputEngineFactory alloc] init];
    }
}

+(DJInputMethodEngine*)inputEngine {
    return [singletonFactory inputEngine];
}

+(void)setCurrentSchemeWithName:(NSString*)schemeName scriptName:(NSString*)scriptName type:(enum DJSchemeType)type; {
    singletonFactory.scriptName = scriptName;
    singletonFactory.schemeName = schemeName;
    singletonFactory.schemeType = type;
}

+(NSString*)currentScriptName {
    return singletonFactory.scriptName;
}

+(NSString*)currentSchemeName {
    return singletonFactory.schemeName;
}

+(enum DJSchemeType)currentSchemeType {
    return singletonFactory.schemeType;
}

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    schemesCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    scriptName = [DJLipikaUserSettings scriptName];
    schemeName = [DJLipikaUserSettings schemeName];
    schemeType = [DJLipikaUserSettings schemeType];
    return self;
}

-(NSString*)scriptName {
    return scriptName;
}

-(void)setScriptName:(NSString*)theScriptName {
    scriptName = theScriptName;
}

-(NSString*)schemeName {
    return schemeName;
}

-(void)setSchemeName:(NSString*)theSchemeName {
    schemeName = theSchemeName;
}

-(DJInputMethodEngine*)inputEngine {
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:[self inputMethodScheme]];
    return engine;
}

-(id<DJInputMethodScheme>)inputMethodScheme {
    // Initialize with the given scheme file
    id<DJInputMethodScheme> scheme;
    @synchronized(schemesCache) {
        NSString *key = [NSString stringWithFormat:@"%@-%@-%u", scriptName, schemeName, schemeType];
        scheme = [schemesCache valueForKey:key];
        if (scheme == nil) {
            scheme = [DJInputSchemeUberFactory inputSchemeForScript:scriptName scheme:schemeName type:schemeType];
            if (scheme == nil) {
                [NSException raise:@"Invalid selection" format:@"Unable to load script: %@, scheme: %@ for type: %u", scriptName, schemeName, schemeType];
            }
            else {
                [schemesCache setValue:scheme forKey:key];
            }
        }
        return scheme;
    }
}

@end
