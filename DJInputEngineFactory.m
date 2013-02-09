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
