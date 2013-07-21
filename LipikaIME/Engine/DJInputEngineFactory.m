/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DJInputEngineFactory.h"
#import "DJLipikaUserSettings.h"
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
    // Find script directories in schemes directory
    NSError *error;
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *dirFiles = [mgr contentsOfDirectoryAtPath:schemesDirectory error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
    logDebug(@"Files in scheme directory: %@", [dirFiles componentsJoinedByString:@", "]);
    NSMutableArray* scriptNames = [[NSMutableArray alloc] initWithCapacity:0];
    [dirFiles enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        BOOL isDir;
        NSString *path = [schemesDirectory stringByAppendingPathComponent: obj];
        if ([mgr fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            [scriptNames addObject:obj];
        }
    }];
    return scriptNames;
}

+(NSArray*)availableSchemesForScript:(NSString*)scriptName {
    // Find scheme files in schemes directory
    NSError *error;
    NSString *path = [schemesDirectory stringByAppendingPathComponent:scriptName];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
    logDebug(@"File in script %@: %@", scriptName, [dirFiles componentsJoinedByString:@", "]);
    NSArray *scmFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.scm'"]];
    NSMutableArray* schemeNames = [[NSMutableArray alloc] initWithCapacity:0];
    [scmFiles enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        [schemeNames addObject:[obj stringByDeletingPathExtension]];
    }];
    return schemeNames;
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

-(DJInputMethodScheme*)inputMethodScheme {
    // Initialize with the given scheme file
    DJInputMethodScheme* scheme;
    @synchronized(schemesCache) {
        NSString* filePath = [[[schemesDirectory stringByAppendingPathComponent:scriptName] stringByAppendingPathComponent:schemeName] stringByAppendingPathExtension:@"scm"];
        scheme = [schemesCache valueForKey:filePath];
        if (scheme == nil) {
            scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:filePath];
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
