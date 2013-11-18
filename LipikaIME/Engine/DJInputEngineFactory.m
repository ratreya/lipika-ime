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

@property NSString* scriptName;
@property NSString* schemeName;

@end

@implementation DJInputEngineFactory

static DJInputEngineFactory* singletonFactory = nil;
static NSString* schemesDirectory;

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        singletonFactory = [[DJInputEngineFactory alloc] init];
        schemesDirectory = [NSString stringWithFormat:@"%@/Contents/Resources/Schemes", [[NSBundle mainBundle] bundlePath]];
    }
}

+(DJInputMethodEngine*)inputEngine {
    return [singletonFactory inputEngine];
}

+(void)setCurrentSchemeWithName:(NSString *)schemeName scriptName:(NSString*)scriptName {
    singletonFactory.scriptName = scriptName;
    singletonFactory.schemeName = schemeName;
}

+(NSString*)currentScriptName {
    return singletonFactory.scriptName;
}

+(NSString*)currentSchemeName {
    return singletonFactory.schemeName;
}

+(NSString*)schemesDirectory {
    return schemesDirectory;
}

+(NSArray*)availableScripts {
    return [DJInputEngineFactory fileInSubdirectory:@"Script" withExternsion:@".map"];
}

+(NSArray*)availableSchemes {
    return [DJInputEngineFactory fileInSubdirectory:@"Transliteration" withExternsion:@".ltr"];
}

+(NSArray*)fileInSubdirectory:(NSString*)subDirectory withExternsion:(NSString*)extension {
    NSError *error;
    NSString *path = [schemesDirectory stringByAppendingPathComponent:subDirectory];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '%@'", extension]]];
    NSMutableArray* names = [[NSMutableArray alloc] initWithCapacity:0];
    [files enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        [names addObject:[obj stringByDeletingPathExtension]];
    }];
    return names;
}

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    schemesCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    scriptName = [DJLipikaUserSettings scriptName];
    schemeName = [DJLipikaUserSettings schemeName];
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
        NSString* filePath = [[[schemesDirectory stringByAppendingPathComponent:scriptName] stringByAppendingPathComponent:schemeName] stringByAppendingPathExtension:@"scm"];
        scheme = [schemesCache valueForKey:filePath];
        if (scheme == nil) {
            scheme = [DJInputSchemeUberFactory inputSchemeForSchemeFile:filePath];
            if (scheme == nil) {
                return nil;
            }
            else {
                [schemesCache setValue:scheme forKey:filePath];
            }
        }
        return scheme;
    }
}

@end
