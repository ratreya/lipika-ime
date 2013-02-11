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

@implementation DJInputEngineFactory

static NSString* currentSchemeName = @"Barahavat.scm";
static NSMutableDictionary* schemesCache;

+(NSString*)schemeFileName {
    return currentSchemeName;
}

+(void)setSchemeFileName:(NSString*)fileName {
    currentSchemeName = fileName;
}

+(DJInputMethodEngine*)inputEngine {
    return [DJInputEngineFactory inputEngineWithSchemeFile:currentSchemeName];
}

+(DJInputMethodEngine*)inputEngineWithSchemeFile:(NSString*)schemeFileName {
    currentSchemeName = schemeFileName;
    // Initialize the cache once
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        schemesCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    });
    // Initialize with the given scheme file
    DJInputMethodScheme* scheme;
    @synchronized(schemesCache) {
        scheme = [schemesCache valueForKey:schemeFileName];
        if (scheme == nil) {
            NSString* filePath = [NSString stringWithFormat:@"%@/Contents/Resources/Schemes/%@", [[NSBundle mainBundle] bundlePath], schemeFileName];
            scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:filePath];
        }
        if (scheme == nil) {
            return nil;
        }
        else {
            [schemesCache setValue:scheme forKey:schemeFileName];
        }
    }
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    return engine;
}

@end
