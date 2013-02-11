#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "DJLipikaBufferManager.h"

@interface DJLipikaInputController : IMKInputController {
    DJLipikaBufferManager* manager;
}

@end
