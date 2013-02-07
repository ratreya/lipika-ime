#import <Foundation/Foundation.h>
#import "DJInputMethodEngine.h"

@interface DJInputEngineFactory : NSObject

+(DJInputMethodEngine*)inputEngine;
+(DJInputMethodEngine*)inputEngineWithSchemeFile:(NSString*)schemeFileName;

+(NSString*)schemeFileName;
+(void)setSchemeFileName:(NSString*)fileName;

@end
