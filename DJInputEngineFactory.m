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
#import "Constants.h"

@interface DJInputEngineFactory ()

@property NSString* inputSchemeName;

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

+(void)setCurrentSchemeWithName:(NSString *)schemeName {
    singletonFactory.inputSchemeName = schemeName;
}

+(NSString*)currentSchemeName {
    return singletonFactory.inputSchemeName;
}

+(NSArray*)availableSchemes {
    // Find scheme files in schemes directory
    NSError* error;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:schemesDirectory error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
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
    inputSchemeName = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_SCHEME_NAME_KEY];
    return self;
}

-(NSString*)inputSchemeName {
    return inputSchemeName;
}

-(void)setInputSchemeName:(NSString*)schemeName {
    inputSchemeName = schemeName;
}

-(DJInputMethodEngine*)inputEngine {
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:[self inputSchemeForName:inputSchemeName]];
    return engine;
}

-(DJInputMethodScheme*)inputSchemeForName:(NSString*)schemeName {
    // Initialize with the given scheme file
    DJInputMethodScheme* scheme;
    @synchronized(schemesCache) {
        scheme = [schemesCache valueForKey:schemeName];
        if (scheme == nil) {
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.scm", schemesDirectory, schemeName];
            scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:filePath];
            if (scheme == nil) {
                return nil;
            }
            else {
                [schemesCache setValue:scheme forKey:schemeName];
            }
        }
        return scheme;
    }
}

@end
