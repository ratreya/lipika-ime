#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "DJLipikaBufferManager.h"

@interface DJLipikaInputController : IMKInputController {
    DJLipikaBufferManager* manager;
}

-(id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient;
-(BOOL)inputText:(NSString*)string client:(id)sender;

@end
