#import "DJLipikaInputController.h"
#import "DJInputEngineFactory.h"

@implementation DJLipikaInputController

- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
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

/*!
	@method     
    @abstract   Receive incoming text.
	@discussion This method receives key board input from the client application. The method receives the key input as an NSString. The string will have been created from the keydown event by the InputMethodKit.
*/
-(BOOL)inputText:(NSString*)string client:(id)sender {
    DJParseOutput* result = [engine executeWithInput:string];
    if (result == nil) {
        // Add the input as-is if there is no mapping for it
        [uncommittedOutput addObject:string];
        // And finalize all outputs
        finalizedIndex = uncommittedOutput.count;
    }
    else {
        if ([result output] != nil) {
            [uncommittedOutput addObject:[result output]];
            // This only makes sense if output is not nil
            if ([result isPreviousFinal]) {
                finalizedIndex = uncommittedOutput.count - 1;
            }
        }
        if ([result isFinal]) {
            // This includes any additions
            finalizedIndex = uncommittedOutput.count;
        }
    }
    NSString* commitString = [self flushUncommitted];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    return YES;
}

-(NSString*)flushUncommitted {
    NSMutableString* output = [[NSMutableString alloc] init];
    while (finalizedIndex > 0) {
        NSString* string = uncommittedOutput[0];
        [output appendString:string];
        [uncommittedOutput removeObjectAtIndex:0];
        --finalizedIndex;
    }
    return output;
}

@end
