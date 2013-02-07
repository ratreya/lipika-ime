#import "DJLipikaInputController.h"
#import "DJInputEngineFactory.h"

@implementation DJLipikaInputController

- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self == nil) {
        return self;
    }
    engine = [DJInputEngineFactory inputEngine];
    uncommittedOutput = [[NSMutableArray alloc] initWithCapacity:0];
    finilizedIndex = 0;
    return self;
}

/*!
	@method     
    @abstract   Receive incoming text.
	@discussion This method receives key board input from the client application. The method receives the key input as an NSString. The string will have been created from the keydown event by the InputMethodKit.
*/
-(BOOL)inputText:(NSString*)string client:(id)sender {
    [sender insertText:@"क" replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    return YES;
}

@end
