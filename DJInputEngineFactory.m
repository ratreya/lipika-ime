#import "DJInputEngineFactory.h"

@implementation DJInputEngineFactory

static NSString* currentSchemeName = @"Barahavat.scm";

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
    // Initialize the engine with the given scheme
    NSString* filePath = [NSString stringWithFormat:@"%@/Content/Resources/Schemes/%@", [[NSBundle mainBundle] bundlePath], schemeFileName];
    DJInputMethodScheme* scheme = [[DJInputMethodScheme alloc] initWithSchemeFile:filePath];
    if (scheme == nil) {
        return nil;
    }
    DJInputMethodEngine* engine = [[DJInputMethodEngine alloc] initWithScheme:scheme];
    return engine;
}

@end
