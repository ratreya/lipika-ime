#import "DJLipikaBufferManager.h"
#import "DJInputEngineFactory.h"

@implementation DJLipikaBufferManager

static NSRegularExpression* whiteSpace;

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = [DJInputEngineFactory inputEngine];
    if (engine == nil) {
        return nil;
    }
    [self initialize];
    return self;
}

// Only for testing purposes and not exposed in the interface
-(id)initWithEngine:(DJInputMethodEngine*)myEngine {
    self = [super init];
    if (self == nil) {
        return self;
    }
    engine = myEngine;
    [self initialize];
    return self;
}

-(void)initialize {
    NSError* error;
    whiteSpace = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid whitespace regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finalizedIndex = 0;
}

-(NSString*)outputForInput:(NSString*)string {
    NSMutableString* output;
    NSRange theRange = {0, 1};
    for ( NSInteger i = 0; i < [string length]; i++) {
        theRange.location = i;
        NSString* singleInput = [string substringWithRange:theRange];
        NSString* singleOutput = [self outputForSingleInput:singleInput];
        if (singleOutput != nil) {
            if (output == nil) {
                output = [[NSMutableString alloc] initWithCapacity:0];
            }
            [output appendString:singleOutput];
        }
    }
    return output;
}

-(NSString*)outputForSingleInput:(NSString*)string {
    // Fush if stop character or whitespace
    BOOL isStopChar = [string isEqualToString:[[engine scheme] stopChar]];
    BOOL isWhiteSpace = [whiteSpace numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (isStopChar || isWhiteSpace) {
        // Only include the stop character in ouput if there is nothing to flush
        if (!isStopChar || [uncommittedOutput count] <= 0) {
            [uncommittedOutput addObject:string];
        }
        return [self flush];
    }

    DJParseOutput* result = [engine executeWithInput:string];
    if (result == nil) {
        // Add the input as-is if there is no mapping for it
        [uncommittedOutput addObject:string];
        // Reset the engine as you don't want previous inputs carrying over
        [engine reset];
        // And finalize all outputs
        finalizedIndex = [uncommittedOutput count];
    }
    else {
        if ([result isPreviousFinal]) {
            finalizedIndex = [uncommittedOutput count];
        }
        else {
            [self removeUnfinalized];
        }
        if ([result output] != nil) {
            [uncommittedOutput addObject:[result output]];
        }
        if ([result isFinal]) {
            // This includes any additions
            finalizedIndex = [uncommittedOutput count];
        }
    }
    return [self finalizedOutput];
}

-(void)removeUnfinalized {
    while ([uncommittedOutput count] > finalizedIndex) {
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

-(NSString*)flush {
    [engine reset];
    finalizedIndex = [uncommittedOutput count];
    return [self finalizedOutput];
}

@end
