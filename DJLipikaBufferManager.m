#import "DJLipikaBufferManager.h"
#import "DJInputEngineFactory.h"

@implementation DJLipikaBufferManager

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = [DJInputEngineFactory inputEngine];
    if (engine == nil) {
        return nil;
    }
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finalizedIndex = 0;
    return self;
}

// Only for testing purposes and not exposed in the interface
-(id)initWithEngine:(DJInputMethodEngine*)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = myEngine;
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finalizedIndex = 0;
    return self;
}

-(NSString*)outputForInput:(NSString*)string {
    DJParseOutput* result = [engine executeWithInput:string];
    if (result == nil) {
        // Add the input as-is if there is no mapping for it
        [uncommittedOutput addObject:string];
        // And finalize all outputs
        finalizedIndex = uncommittedOutput.count;
    }
    else {
        if ([result output] != nil) {
            // This only makes sense if output is not nil
            if ([result isPreviousFinal]) {
                finalizedIndex = uncommittedOutput.count;
            }
            else {
                [self removeUnfinalized];
            }
            [uncommittedOutput addObject:[result output]];
        }
        if ([result isFinal]) {
            // This includes any additions
            finalizedIndex = uncommittedOutput.count;
        }
    }
    return [self finalizedOutput];
}

-(void)removeUnfinalized {
    while (uncommittedOutput.count > finalizedIndex) {
        [uncommittedOutput removeObjectAtIndex:finalizedIndex];
    }
}

-(NSString*)finalizedOutput {
    if (finalizedIndex == 0) {
        return nil;
    }
    NSMutableString* output = [[NSMutableString alloc] init];
    while (finalizedIndex > 0) {
        [output appendString:[uncommittedOutput objectAtIndex:0]];
        [uncommittedOutput removeObjectAtIndex:0];
        --finalizedIndex;
    }
    return output;
}

@end
