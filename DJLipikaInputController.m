#import "DJLipikaInputController.h"

@implementation DJLipikaInputController

-(id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self == nil) {
        return self;
    }
    manager = [[DJLipikaBufferManager alloc] init];
    return self;
}

-(BOOL)inputText:(NSString*)string client:(id)sender {
    NSString* commitString = [manager outputForInput:string];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    return YES;
}

-(void)commitComposition:(id)sender {
    NSString* commitString = [manager flush];
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    if (aSelector == @selector(insertNewline:)) {
        [self commitComposition:sender];
    }
    else if (aSelector == @selector(deleteBackward:)) {
        // If we deleted some uncommitted output then swallow the delete
        if([manager flush] != nil) {
            return YES;
        }
    }
    return NO;
}

@end
