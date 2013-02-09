#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "DJInputMethodEngine.h"

@interface DJLipikaInputController : IMKInputController {
    // One instance of the engine per connection
    DJInputMethodEngine* engine;
    // Holds NSString outputs that need to be handed off to the client
    NSMutableArray* uncommittedOutput;
    // New output from the engine will replace all output after this index
    unsigned long finalizedIndex;
}

-(id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient;

@end
