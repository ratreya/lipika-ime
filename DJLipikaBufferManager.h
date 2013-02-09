#import <Foundation/Foundation.h>
#import "DJInputMethodEngine.h"

@interface DJLipikaBufferManager : NSObject {
    // One instance of the engine per connection
    DJInputMethodEngine* engine;
    // Holds NSString outputs that need to be handed off to the client
    NSMutableArray* uncommittedOutput;
    // New output from the engine will replace all output after this index
    unsigned long finalizedIndex;
}

-(id)init;
-(NSString*)outputForInput:(NSString*)string;

@end
