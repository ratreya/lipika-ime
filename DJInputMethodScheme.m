#import "DJInputMethodScheme.h"

@implementation DJInputMethodScheme

@synthesize parseTree;

-(void)initWithSchemeFile:(NSString*) fileName {
    schemeFileName = fileName;
    parseTree = [NSMutableDictionary dictionaryWithCapacity:0];
}

@end
