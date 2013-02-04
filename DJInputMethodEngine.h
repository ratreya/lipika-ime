#import <Foundation/Foundation.h>
#import "DJInputMethodScheme.h"
#import "DJParseTreeNode.h"
#import "DJParseOutput.h"

@interface DJInputMethodEngine : NSObject {
@private
    DJInputMethodScheme* scheme;
    DJParseTreeNode* currentNode;
    NSString* currentOutput;
}

@property DJInputMethodScheme* scheme;

-(id)initWithScheme:(DJInputMethodScheme*)inputScheme;
-(DJParseOutput*)executeWithInput:(NSString*) input;

@end
